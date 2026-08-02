import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:paper_league/data/league_api_config.dart';
import 'package:paper_league/domain/league_remote.dart';
import 'package:paper_league/domain/season.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HTTP client for the local Paper League API (real multi-user on LAN).
class LocalLeagueClient {
  LocalLeagueClient({http.Client? client}) : _http = client ?? http.Client();

  final http.Client _http;
  String? token;
  String? userId;
  String nickname = 'trader';
  int hue = 188;
  bool isAnonymous = true;

  static const _tokenKey = 'local_league_token';
  static const _uidKey = 'local_league_uid';

  Uri _u(String path) => Uri.parse('${LeagueApiConfig.url}$path');

  Map<String, String> get _authHeaders => {
        'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
      };

  Future<bool> ping() async {
    try {
      final res = await _http.get(_u('/health')).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> restoreSession() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString(_tokenKey);
    userId = p.getString(_uidKey);
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    if (token == null) {
      await p.remove(_tokenKey);
      await p.remove(_uidKey);
    } else {
      await p.setString(_tokenKey, token!);
      await p.setString(_uidKey, userId ?? '');
    }
  }

  Future<bool> continueAsGuest() async {
    final res = await _http.post(_u('/auth/guest'), headers: _authHeaders);
    if (res.statusCode >= 300) return false;
    _applyAuth(jsonDecode(res.body) as Map<String, dynamic>);
    await _persist();
    return true;
  }

  Future<bool> signUp(String email, String password, {String? nickname}) async {
    final res = await _http.post(
      _u('/auth/signup'),
      headers: _authHeaders,
      body: jsonEncode({'email': email, 'password': password, 'nickname': nickname}),
    );
    if (res.statusCode >= 300) return false;
    _applyAuth(jsonDecode(res.body) as Map<String, dynamic>);
    await _persist();
    return true;
  }

  Future<bool> signIn(String email, String password) async {
    final res = await _http.post(
      _u('/auth/login'),
      headers: _authHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode >= 300) return false;
    _applyAuth(jsonDecode(res.body) as Map<String, dynamic>);
    await _persist();
    return true;
  }

  Future<void> signOut() async {
    token = null;
    userId = null;
    await _persist();
  }

  void _applyAuth(Map<String, dynamic> m) {
    userId = m['user_id'] as String?;
    token = m['token'] as String?;
    nickname = m['nickname'] as String? ?? 'trader';
    hue = m['hue'] as int? ?? 188;
    isAnonymous = m['is_anonymous'] as bool? ?? true;
  }

  Future<void> upsertProfile({required String nickname, required int hue}) async {
    if (token == null) return;
    this.nickname = nickname;
    this.hue = hue;
    await _http.put(
      _u('/profiles/me'),
      headers: _authHeaders,
      body: jsonEncode({'nickname': nickname, 'hue': hue}),
    );
  }

  Future<void> upsertScore(ScoreUpsert payload) async {
    if (token == null) return;
    final res = await _http.put(
      _u('/seasons/${payload.seasonNumber}/scores/me'),
      headers: _authHeaders,
      body: jsonEncode({
        'discipline': payload.discipline,
        'max_dd': payload.maxDd,
        'ret_pct': payload.retPct,
        'score': payload.score,
      }),
    );
    if (res.statusCode >= 300) {
      debugPrint('local upsertScore ${res.statusCode} ${res.body}');
    }
  }

  Future<List<RemoteScoreRow>> fetchLeaderboard(int season) async {
    final res = await _http.get(_u('/seasons/$season/scores'), headers: _authHeaders);
    if (res.statusCode >= 300) return const [];
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['user_id'] as String;
      return RemoteScoreRow(
        userId: id,
        nickname: m['nickname'] as String? ?? 'trader',
        hue: m['hue'] as int? ?? 188,
        score: (m['score'] as num).toDouble(),
        discipline: (m['discipline'] as num).toDouble(),
        maxDd: (m['max_dd'] as num).toDouble(),
        retPct: (m['ret_pct'] as num).toDouble(),
        division: LeagueDivisionX.parse(m['division'] as String?),
        updatedAt: DateTime.tryParse(m['updated_at'] as String? ?? '') ?? DateTime.now(),
        isYou: id == userId,
      );
    }).toList();
  }

  Future<List<SeasonTitleRow>> fetchTitles() async {
    final res = await _http.get(_u('/seasons/titles'), headers: _authHeaders);
    if (res.statusCode >= 300) return const [];
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      return SeasonTitleRow(
        seasonNumber: m['season_number'] as int,
        userId: m['user_id'] as String,
        rank: m['rank'] as int,
        titleKey: m['title_key'] as String,
        nickname: m['nickname'] as String?,
      );
    }).toList();
  }

  Future<void> ensureSeason() async {
    await _http.get(_u('/seasons/current'), headers: _authHeaders);
    // Soft-freeze previous season for titles.
    final cur = SeasonClock.of(DateTime.now()).number;
    if (cur > 1) {
      try {
        await _http.post(_u('/seasons/${cur - 1}/freeze'), headers: _authHeaders);
      } catch (_) {}
    }
  }

  Future<int> heartbeat() async {
    if (token == null) return 0;
    try {
      final res = await _http.post(_u('/presence'), headers: _authHeaders).timeout(const Duration(seconds: 2));
      if (res.statusCode >= 300) return 0;
      final m = jsonDecode(res.body) as Map<String, dynamic>;
      return (m['online'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> fetchOnlineCount() async {
    try {
      final res = await _http.get(_u('/presence'), headers: _authHeaders).timeout(const Duration(seconds: 2));
      if (res.statusCode >= 300) return 0;
      final m = jsonDecode(res.body) as Map<String, dynamic>;
      return (m['online'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
