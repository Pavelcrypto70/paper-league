import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:paper_league/data/local_league_client.dart';
import 'package:paper_league/data/supabase_client.dart';
import 'package:paper_league/domain/league_remote.dart';
import 'package:paper_league/domain/season.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum LeagueBackendKind { none, supabase, local }

/// Remote league board + throttled score upserts + offline queue.
class LeagueRepository {
  LeagueRepository();

  static const _queueKey = 'league_upsert_queue';
  static const _minUpsertGap = Duration(seconds: 45);

  LeagueBackendKind kind = LeagueBackendKind.none;
  LocalLeagueClient? _local;

  DateTime? _lastUpsertAt;
  RealtimeChannel? _channel;
  final _boardController = StreamController<List<RemoteScoreRow>>.broadcast();
  List<RemoteScoreRow> _latest = const [];
  Timer? _poll;
  Timer? _heartbeat;
  bool _watching = false;
  int onlinePeers = 0;

  Stream<List<RemoteScoreRow>> get boardStream => _boardController.stream;
  List<RemoteScoreRow> get latestBoard => _latest;

  bool get isLive {
    if (kind == LeagueBackendKind.local) return _local?.token != null;
    if (kind == LeagueBackendKind.supabase) {
      return supabaseOrNull?.auth.currentUser != null;
    }
    return false;
  }

  void attachSupabase() {
    kind = LeagueBackendKind.supabase;
    _local = null;
  }

  void attachLocal(LocalLeagueClient client) {
    kind = LeagueBackendKind.local;
    _local = client;
  }

  Future<void> ensureSeasonSeeded() async {
    if (kind == LeagueBackendKind.local) {
      await _local?.ensureSeason();
      return;
    }
    final client = supabaseOrNull;
    if (client == null) return;
    final info = SeasonClock.of(DateTime.now());
    try {
      await client.from('seasons').upsert({
        'number': info.number,
        'starts_at': info.startedAt.toIso8601String(),
        'ends_at': info.endsAt.toIso8601String(),
        'phase': info.phase.name,
      });
    } catch (e) {
      debugPrint('ensureSeasonSeeded: $e');
    }
  }

  Future<void> upsertProfile({
    required String nickname,
    required int hue,
    String? avatarUrl,
  }) async {
    if (kind == LeagueBackendKind.local) {
      await _local?.upsertProfile(nickname: nickname, hue: hue);
      return;
    }
    final client = supabaseOrNull;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return;
    await client.from('profiles').upsert({
      'id': uid,
      'nickname': nickname,
      'hue': hue,
      'avatar_url': ?avatarUrl,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> upsertMyScore(ScoreUpsert payload, {bool force = false}) async {
    if (!isLive) {
      await _enqueue(payload);
      return;
    }

    final now = DateTime.now();
    if (!force && _lastUpsertAt != null && now.difference(_lastUpsertAt!) < _minUpsertGap) {
      await _enqueue(payload);
      return;
    }

    try {
      await ensureSeasonSeeded();
      await _writeScore(payload);
      _lastUpsertAt = now;
      await _flushQueue();
    } catch (e) {
      debugPrint('upsertMyScore: $e');
      await _enqueue(payload);
    }
  }

  Future<void> _writeScore(ScoreUpsert payload) async {
    if (kind == LeagueBackendKind.local) {
      await _local!.upsertScore(payload);
      return;
    }
    final client = supabaseOrNull!;
    final uid = client.auth.currentUser!.id;
    await client.from('season_scores').upsert({
      'season_number': payload.seasonNumber,
      'user_id': uid,
      'discipline': payload.discipline,
      'max_dd': payload.maxDd,
      'ret_pct': payload.retPct,
      'score': payload.score,
    });
  }

  Future<List<RemoteScoreRow>> fetchLeaderboard(int seasonNumber) async {
    try {
      if (kind == LeagueBackendKind.local) {
        final list = await _local!.fetchLeaderboard(seasonNumber);
        _latest = list;
        if (!_boardController.isClosed) _boardController.add(list);
        return list;
      }

      final client = supabaseOrNull;
      final uid = client?.auth.currentUser?.id;
      if (client == null) return const [];

      final rows = await client
          .from('season_scores')
          .select(
            'user_id, discipline, max_dd, ret_pct, score, division, updated_at, '
            'profiles(nickname, hue, avatar_url)',
          )
          .eq('season_number', seasonNumber)
          .order('score', ascending: false)
          .limit(50);

      final list = <RemoteScoreRow>[];
      for (final raw in rows as List) {
        final m = Map<String, dynamic>.from(raw as Map);
        final profile = m['profiles'];
        Map<String, dynamic>? p;
        if (profile is Map) p = Map<String, dynamic>.from(profile);
        final id = m['user_id'] as String;
        list.add(
          RemoteScoreRow(
            userId: id,
            nickname: (p?['nickname'] as String?) ?? 'trader',
            hue: (p?['hue'] as int?) ?? 188,
            avatarUrl: p?['avatar_url'] as String?,
            score: (m['score'] as num).toDouble(),
            discipline: (m['discipline'] as num).toDouble(),
            maxDd: (m['max_dd'] as num).toDouble(),
            retPct: (m['ret_pct'] as num).toDouble(),
            division: LeagueDivisionX.parse(m['division'] as String?),
            updatedAt: DateTime.tryParse(m['updated_at'] as String? ?? '') ?? DateTime.now(),
            isYou: id == uid,
          ),
        );
      }
      _latest = list;
      if (!_boardController.isClosed) _boardController.add(list);
      return list;
    } catch (e) {
      debugPrint('fetchLeaderboard: $e');
      return _latest;
    }
  }

  Future<List<SeasonTitleRow>> fetchTitles({int limitSeasons = 4}) async {
    if (kind == LeagueBackendKind.local) {
      return _local?.fetchTitles() ?? const [];
    }
    final client = supabaseOrNull;
    if (client == null) return const [];
    final cur = SeasonClock.of(DateTime.now()).number;
    try {
      final rows = await client
          .from('season_titles')
          .select('season_number, user_id, rank, title_key, profiles(nickname)')
          .gte('season_number', cur - limitSeasons)
          .order('season_number', ascending: false)
          .order('rank', ascending: true)
          .limit(40);
      return (rows as List).map((raw) {
        final m = Map<String, dynamic>.from(raw as Map);
        final profile = m['profiles'];
        String? nick;
        if (profile is Map) nick = profile['nickname'] as String?;
        return SeasonTitleRow(
          seasonNumber: m['season_number'] as int,
          userId: m['user_id'] as String,
          rank: m['rank'] as int,
          titleKey: m['title_key'] as String,
          nickname: nick,
        );
      }).toList();
    } catch (e) {
      debugPrint('fetchTitles: $e');
      return const [];
    }
  }

  Future<void> startWatching(int seasonNumber) async {
    if (_watching) return;
    _watching = true;
    await fetchLeaderboard(seasonNumber);

    if (kind == LeagueBackendKind.local) {
      _poll = Timer.periodic(const Duration(seconds: 2), (_) {
        fetchLeaderboard(seasonNumber);
      });
      _heartbeat = Timer.periodic(const Duration(seconds: 8), (_) async {
        onlinePeers = await _local?.heartbeat() ?? 0;
      });
      onlinePeers = await _local?.heartbeat() ?? 0;
      return;
    }

    final client = supabaseOrNull;
    if (client == null) {
      _poll = Timer.periodic(const Duration(seconds: 10), (_) {
        fetchLeaderboard(seasonNumber);
      });
      return;
    }

    _channel?.unsubscribe();
    _channel = client
        .channel('season_scores_$seasonNumber')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'season_scores',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'season_number',
            value: seasonNumber,
          ),
          callback: (_) => fetchLeaderboard(seasonNumber),
        )
        .subscribe();

    _poll = Timer.periodic(const Duration(seconds: 12), (_) {
      fetchLeaderboard(seasonNumber);
    });
  }

  Future<void> stopWatching() async {
    _watching = false;
    _poll?.cancel();
    _poll = null;
    _heartbeat?.cancel();
    _heartbeat = null;
    await _channel?.unsubscribe();
    _channel = null;
  }

  Future<void> _enqueue(ScoreUpsert payload) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_queueKey) ?? [];
    raw.add(jsonEncode({
      'season': payload.seasonNumber,
      'discipline': payload.discipline,
      'max_dd': payload.maxDd,
      'ret_pct': payload.retPct,
      'score': payload.score,
      'at': DateTime.now().toUtc().toIso8601String(),
    }));
    while (raw.length > 20) {
      raw.removeAt(0);
    }
    await prefs.setStringList(_queueKey, raw);
  }

  Future<void> _flushQueue() async {
    if (!isLive) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_queueKey) ?? [];
    if (raw.isEmpty) return;

    Map<String, dynamic>? last;
    for (final s in raw) {
      try {
        last = jsonDecode(s) as Map<String, dynamic>;
      } catch (_) {}
    }
    await prefs.remove(_queueKey);
    if (last == null) return;
    final payload = ScoreUpsert(
      seasonNumber: last['season'] as int,
      discipline: (last['discipline'] as num).toDouble(),
      maxDd: (last['max_dd'] as num).toDouble(),
      retPct: (last['ret_pct'] as num).toDouble(),
      score: (last['score'] as num).toDouble(),
    );
    try {
      await ensureSeasonSeeded();
      await _writeScore(payload);
      _lastUpsertAt = DateTime.now();
    } catch (e) {
      debugPrint('flushQueue: $e');
      await prefs.setStringList(_queueKey, [jsonEncode(last)]);
    }
  }

  Future<void> flushPending() => _flushQueue();

  Future<void> dispose() async {
    await stopWatching();
    await _boardController.close();
  }
}
