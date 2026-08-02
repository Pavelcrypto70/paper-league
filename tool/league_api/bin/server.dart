import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

/// Local Paper League API — real shared ranking without cloud Supabase.
/// Run: dart run tool/league_api/bin/server.dart
void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8787;
  final store = LeagueStore();
  final app = Router();

  app.get('/health', (Request req) => Response.ok(jsonEncode({'ok': true, 'mode': 'local'})));

  app.post('/auth/guest', (Request req) async {
    final user = store.createGuest();
    return Response.ok(jsonEncode(user), headers: _json);
  });

  app.post('/auth/signup', (Request req) async {
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final password = body['password'] as String? ?? '';
    final nickname = (body['nickname'] as String?)?.trim();
    if (email.isEmpty || password.length < 4) {
      return Response(400, body: jsonEncode({'error': 'invalid credentials'}));
    }
    final user = store.signUp(email: email, password: password, nickname: nickname);
    return Response.ok(jsonEncode(user), headers: _json);
  });

  app.post('/auth/login', (Request req) async {
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final password = body['password'] as String? ?? '';
    final user = store.login(email: email, password: password);
    if (user == null) return Response(401, body: jsonEncode({'error': 'bad login'}));
    return Response.ok(jsonEncode(user), headers: _json);
  });

  app.put('/profiles/me', (Request req) async {
    final uid = _uid(req);
    if (uid == null) return Response.forbidden(jsonEncode({'error': 'auth'}));
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    store.updateProfile(
      uid,
      nickname: body['nickname'] as String?,
      hue: body['hue'] as int?,
    );
    return Response.ok(jsonEncode(store.profile(uid)), headers: _json);
  });

  app.get('/seasons/current', (Request req) {
    return Response.ok(jsonEncode(store.currentSeason()), headers: _json);
  });

  app.put('/seasons/<n|[0-9]+>/scores/me', (Request req, String n) async {
    final uid = _uid(req);
    if (uid == null) return Response.forbidden(jsonEncode({'error': 'auth'}));
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final season = int.parse(n);
    final row = store.upsertScore(
      season: season,
      userId: uid,
      discipline: (body['discipline'] as num?)?.toDouble() ?? 0,
      maxDd: (body['max_dd'] as num?)?.toDouble() ?? 0,
      retPct: (body['ret_pct'] as num?)?.toDouble() ?? 0,
      score: (body['score'] as num?)?.toDouble() ?? 0,
    );
    return Response.ok(jsonEncode(row), headers: _json);
  });

  app.get('/seasons/<n|[0-9]+>/scores', (Request req, String n) {
    final season = int.parse(n);
    return Response.ok(jsonEncode(store.leaderboard(season)), headers: _json);
  });

  app.get('/seasons/titles', (Request req) {
    return Response.ok(jsonEncode(store.titles()), headers: _json);
  });

  app.post('/seasons/<n|[0-9]+>/freeze', (Request req, String n) {
    store.freeze(int.parse(n));
    return Response.ok(jsonEncode({'ok': true}), headers: _json);
  });

  app.post('/presence', (Request req) async {
    final uid = _uid(req);
    if (uid == null) return Response.forbidden(jsonEncode({'error': 'auth'}));
    store.heartbeat(uid);
    return Response.ok(jsonEncode({'ok': true, 'online': store.onlineCount}), headers: _json);
  });

  app.get('/presence', (Request req) {
    return Response.ok(
      jsonEncode({
        'online': store.onlineCount,
        'peers': store.onlinePeers(),
      }),
      headers: _json,
    );
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(app.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln('Paper League API on http://127.0.0.1:${server.port}');
}

const _json = {'content-type': 'application/json'};

String? _uid(Request req) {
  final h = req.headers['authorization'];
  if (h == null || !h.startsWith('Bearer ')) return null;
  return h.substring(7).trim();
}

Middleware _cors() {
  return (inner) {
    return (req) async {
      if (req.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'Authorization, Content-Type',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, OPTIONS',
        });
      }
      final res = await inner(req);
      return res.change(headers: {
        ...res.headers,
        'Access-Control-Allow-Origin': '*',
      });
    };
  };
}

class LeagueStore {
  final _rng = Random();
  final Map<String, _User> users = {};
  final Map<String, String> emailToId = {};
  final Map<String, Map<String, _Score>> scores = {}; // season -> userId -> score
  final List<Map<String, dynamic>> titleRows = [];
  final Map<String, DateTime> lastSeen = {};

  static final epoch = DateTime.utc(2026, 1, 5);
  static const presenceTtl = Duration(seconds: 20);

  int get onlineCount => onlinePeers().length;

  void heartbeat(String uid) {
    lastSeen[uid] = DateTime.now().toUtc();
  }

  List<Map<String, dynamic>> onlinePeers() {
    final now = DateTime.now().toUtc();
    final out = <Map<String, dynamic>>[];
    for (final e in lastSeen.entries) {
      if (now.difference(e.value) > presenceTtl) continue;
      final u = users[e.key];
      out.add({
        'user_id': e.key,
        'nickname': u?.nickname ?? 'trader',
        'hue': u?.hue ?? 188,
        'last_seen': e.value.toIso8601String(),
      });
    }
    return out;
  }

  Map<String, dynamic> currentSeason() {
    final now = DateTime.now().toUtc();
    final elapsed = now.difference(epoch).inDays;
    final number = (elapsed ~/ 28) + 1;
    final day = (elapsed % 28) + 1;
    final start = epoch.add(Duration(days: (number - 1) * 28));
    final end = start.add(const Duration(days: 28));
    final phase = day <= 21 ? 'grow' : day <= 26 ? 'contest' : 'finals';
    return {
      'number': number,
      'day': day,
      'starts_at': start.toIso8601String(),
      'ends_at': end.toIso8601String(),
      'phase': phase,
    };
  }

  Map<String, dynamic> createGuest() {
    final id = 'g_${_rng.nextInt(1 << 32).toRadixString(16)}';
    final token = id;
    users[id] = _User(id: id, token: token, nickname: 'trader', hue: 188, email: null, password: null);
    return _authPayload(users[id]!);
  }

  Map<String, dynamic> signUp({required String email, required String password, String? nickname}) {
    if (emailToId.containsKey(email)) {
      final existing = users[emailToId[email]!]!;
      if (existing.password == password) return _authPayload(existing);
    }
    final id = 'u_${_rng.nextInt(1 << 32).toRadixString(16)}';
    final u = _User(
      id: id,
      token: id,
      nickname: (nickname == null || nickname.length < 2) ? email.split('@').first : nickname,
      hue: 188,
      email: email,
      password: password,
    );
    users[id] = u;
    emailToId[email] = id;
    return _authPayload(u);
  }

  Map<String, dynamic>? login({required String email, required String password}) {
    final id = emailToId[email];
    if (id == null) return null;
    final u = users[id]!;
    if (u.password != password) return null;
    return _authPayload(u);
  }

  void updateProfile(String uid, {String? nickname, int? hue}) {
    final u = users[uid];
    if (u == null) return;
    if (nickname != null && nickname.trim().length >= 2) u.nickname = nickname.trim().substring(0, min(18, nickname.trim().length));
    if (hue != null) u.hue = hue % 360;
  }

  Map<String, dynamic> profile(String uid) {
    final u = users[uid]!;
    return {'id': u.id, 'nickname': u.nickname, 'hue': u.hue};
  }

  Map<String, dynamic> upsertScore({
    required int season,
    required String userId,
    required double discipline,
    required double maxDd,
    required double retPct,
    required double score,
  }) {
    final clamped = score.clamp(0, 100).toDouble();
    final map = scores.putIfAbsent(season.toString(), () => {});
    final prev = map[userId]?.score;
    var next = clamped;
    if (prev != null && (next - prev).abs() > 25) {
      next = prev + (next > prev ? 25 : -25);
    }
    final division = next >= 92
        ? 'masters'
        : next >= 85
            ? 'elite'
            : next >= 75
                ? 'pro'
                : 'rookie';
    final row = _Score(
      userId: userId,
      discipline: discipline,
      maxDd: maxDd,
      retPct: retPct,
      score: next,
      division: division,
      updatedAt: DateTime.now().toUtc(),
    );
    map[userId] = row;
    lastSeen[userId] = DateTime.now().toUtc();
    return _scoreJson(row);
  }

  List<Map<String, dynamic>> leaderboard(int season) {
    final map = scores[season.toString()] ?? {};
    final list = map.values.toList()..sort((a, b) => b.score.compareTo(a.score));
    return list.map((s) {
      final u = users[s.userId];
      return {
        ..._scoreJson(s),
        'nickname': u?.nickname ?? 'trader',
        'hue': u?.hue ?? 188,
      };
    }).toList();
  }

  void freeze(int season) {
    titleRows.removeWhere((t) => t['season_number'] == season);
    final board = leaderboard(season);
    for (var i = 0; i < board.length && i < 20; i++) {
      final r = board[i];
      titleRows.add({
        'season_number': season,
        'user_id': r['user_id'],
        'rank': i + 1,
        'title_key': i == 0
            ? 'desk_captain'
            : i == 1
                ? 'senior_risk'
                : i == 2
                    ? 'tape_control'
                    : 'contender',
        'nickname': r['nickname'],
      });
    }
  }

  List<Map<String, dynamic>> titles() => List.from(titleRows);

  Map<String, dynamic> _authPayload(_User u) => {
        'user_id': u.id,
        'token': u.token,
        'nickname': u.nickname,
        'hue': u.hue,
        'is_anonymous': u.email == null,
      };

  Map<String, dynamic> _scoreJson(_Score s) => {
        'user_id': s.userId,
        'discipline': s.discipline,
        'max_dd': s.maxDd,
        'ret_pct': s.retPct,
        'score': s.score,
        'division': s.division,
        'updated_at': s.updatedAt.toIso8601String(),
      };
}

class _User {
  _User({
    required this.id,
    required this.token,
    required this.nickname,
    required this.hue,
    required this.email,
    required this.password,
  });
  final String id;
  final String token;
  String nickname;
  int hue;
  final String? email;
  final String? password;
}

class _Score {
  _Score({
    required this.userId,
    required this.discipline,
    required this.maxDd,
    required this.retPct,
    required this.score,
    required this.division,
    required this.updatedAt,
  });
  final String userId;
  final double discipline;
  final double maxDd;
  final double retPct;
  final double score;
  final String division;
  final DateTime updatedAt;
}

int min(int a, int b) => a < b ? a : b;
