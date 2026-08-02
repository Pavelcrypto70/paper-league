import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:paper_league/data/league_repository.dart';
import 'package:paper_league/data/local_league_client.dart';
import 'package:paper_league/data/supabase_client.dart';
import 'package:paper_league/services/analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthPhase { booting, needsGate, ready }

enum OnlineMode { demo, localApi, supabase }

class AuthController extends ChangeNotifier {
  AuthController({LeagueRepository? league, LocalLeagueClient? local})
      : _league = league ?? LeagueRepository(),
        _local = local ?? LocalLeagueClient();

  final LeagueRepository _league;
  final LocalLeagueClient _local;
  SharedPreferences? _prefs;
  StreamSubscription<AuthState>? _sub;

  AuthPhase phase = AuthPhase.booting;
  OnlineMode mode = OnlineMode.demo;
  String? error;
  bool busy = false;

  bool get onlineConfigured => mode != OnlineMode.demo;
  bool get isSignedIn => mode == OnlineMode.supabase
      ? supabaseOrNull?.auth.currentUser != null
      : mode == OnlineMode.localApi && _local.token != null;
  bool get isAnonymous => mode == OnlineMode.supabase
      ? (supabaseOrNull?.auth.currentUser?.isAnonymous ?? false)
      : _local.isAnonymous;
  String? get userId => mode == OnlineMode.supabase
      ? supabaseOrNull?.auth.currentUser?.id
      : _local.userId;

  LeagueRepository get league => _league;
  LocalLeagueClient get local => _local;

  Future<void> bootstrap() async {
    phase = AuthPhase.booting;
    notifyListeners();
    _prefs = await SharedPreferences.getInstance();

    final supabaseOk = await initSupabase();
    if (supabaseOk) {
      mode = OnlineMode.supabase;
      _league.attachSupabase();
      final client = supabaseOrNull!;
      _sub = client.auth.onAuthStateChange.listen((state) {
        if (state.session != null) {
          phase = AuthPhase.ready;
          unawaited(_league.flushPending());
        }
        notifyListeners();
      });
      if (client.auth.currentSession != null) {
        phase = AuthPhase.ready;
        Analytics.log('auth_ok', {'mode': 'supabase'});
        unawaited(_league.flushPending());
      } else {
        final skipped = _prefs?.getBool('authGateSkipped') ?? false;
        phase = skipped ? AuthPhase.ready : AuthPhase.needsGate;
      }
      notifyListeners();
      return;
    }

    await _local.restoreSession();
    final apiUp = await _local.ping();
    if (apiUp) {
      mode = OnlineMode.localApi;
      _league.attachLocal(_local);
      if (_local.token != null) {
        phase = AuthPhase.ready;
        Analytics.log('auth_ok', {'mode': 'local_api'});
      } else {
        final skipped = _prefs?.getBool('authGateSkipped') ?? false;
        phase = skipped ? AuthPhase.ready : AuthPhase.needsGate;
      }
      notifyListeners();
      return;
    }

    mode = OnlineMode.demo;
    phase = AuthPhase.ready;
    Analytics.log('auth_demo_mode');
    notifyListeners();
    _startDemoRescue();
  }

  Timer? _demoRescue;

  void _startDemoRescue() {
    _demoRescue?.cancel();
    _demoRescue = Timer.periodic(const Duration(seconds: 12), (_) async {
      if (mode != OnlineMode.demo) {
        _demoRescue?.cancel();
        return;
      }
      final apiUp = await _local.ping();
      if (!apiUp) return;
      mode = OnlineMode.localApi;
      _league.attachLocal(_local);
      Analytics.log('auth_rescue_local');
      _demoRescue?.cancel();
      if (_local.token == null) {
        phase = AuthPhase.needsGate;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _demoRescue?.cancel();
    _sub?.cancel();
    unawaited(_league.dispose());
    super.dispose();
  }

  Future<void> continueAsGuest() async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      if (mode == OnlineMode.supabase) {
        final res = await supabaseOrNull!.auth.signInAnonymously();
        if (res.user == null) throw StateError('anonymous failed');
        Analytics.log('auth_ok', {'mode': 'guest_supabase'});
      } else if (mode == OnlineMode.localApi) {
        final ok = await _local.continueAsGuest();
        if (!ok) throw StateError('local guest failed');
        Analytics.log('auth_ok', {'mode': 'guest_local'});
      }
      await _prefs?.setBool('authGateSkipped', true);
      phase = AuthPhase.ready;
    } catch (e) {
      error = e.toString();
      await _prefs?.setBool('authGateSkipped', true);
      phase = AuthPhase.ready;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signInEmail(String email, String password) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      if (mode == OnlineMode.supabase) {
        await supabaseOrNull!.auth.signInWithPassword(email: email.trim(), password: password);
      } else if (mode == OnlineMode.localApi) {
        final ok = await _local.signIn(email.trim(), password);
        if (!ok) throw StateError('login failed');
      } else {
        throw StateError('offline demo — start league API or set Supabase');
      }
      phase = AuthPhase.ready;
      Analytics.log('auth_ok', {'mode': 'email'});
    } catch (e) {
      error = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signUpEmail(String email, String password, {String? nickname}) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      if (mode == OnlineMode.supabase) {
        await supabaseOrNull!.auth.signUp(
          email: email.trim(),
          password: password,
          data: {'nickname': ?nickname},
        );
      } else if (mode == OnlineMode.localApi) {
        final ok = await _local.signUp(email.trim(), password, nickname: nickname);
        if (!ok) throw StateError('signup failed');
      } else {
        throw StateError('offline demo — start league API or set Supabase');
      }
      phase = AuthPhase.ready;
      Analytics.log('auth_ok', {'mode': 'signup'});
    } catch (e) {
      error = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      if (mode == OnlineMode.supabase) {
        await supabaseOrNull?.auth.signOut();
      } else {
        await _local.signOut();
      }
    } catch (_) {}
    phase = onlineConfigured ? AuthPhase.needsGate : AuthPhase.ready;
    notifyListeners();
  }

  Future<void> syncProfile({
    required String nickname,
    required int hue,
    String? avatarUrl,
  }) async {
    if (mode == OnlineMode.localApi) {
      await _local.upsertProfile(nickname: nickname, hue: hue);
    } else {
      await _league.upsertProfile(nickname: nickname, hue: hue, avatarUrl: avatarUrl);
    }
  }
}
