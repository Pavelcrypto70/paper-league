import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local analytics + crash ring (RuStore-ready baseline, no third-party SDK).
abstract final class Analytics {
  static const _key = 'analytics_events';
  static const _crashKey = 'analytics_crashes';
  static SharedPreferences? _prefs;
  static bool _hooksInstalled = false;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _installHooks();
  }

  static void _installHooks() {
    if (_hooksInstalled) return;
    _hooksInstalled = true;
    final prev = FlutterError.onError;
    FlutterError.onError = (details) {
      unawaited(logCrash(details.exceptionAsString(), details.stack?.toString()));
      prev?.call(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(logCrash(error.toString(), stack.toString()));
      return false;
    };
  }

  static Future<void> log(String name, [Map<String, Object?> props = const {}]) async {
    await init();
    final entry = {
      't': DateTime.now().toUtc().toIso8601String(),
      'e': name,
      'p': props,
    };
    debugPrint('analytics $name $props');
    final raw = _prefs?.getStringList(_key) ?? <String>[];
    raw.add(jsonEncode(entry));
    while (raw.length > 300) {
      raw.removeAt(0);
    }
    await _prefs?.setStringList(_key, raw);
  }

  static Future<void> logCrash(String error, [String? stack]) async {
    await init();
    final entry = {
      't': DateTime.now().toUtc().toIso8601String(),
      'e': 'crash',
      'err': error,
      if (stack != null) 's': stack.length > 1200 ? stack.substring(0, 1200) : stack,
    };
    debugPrint('crash $error');
    final raw = _prefs?.getStringList(_crashKey) ?? <String>[];
    raw.add(jsonEncode(entry));
    while (raw.length > 40) {
      raw.removeAt(0);
    }
    await _prefs?.setStringList(_crashKey, raw);
    await log('crash', {'err': error.length > 80 ? error.substring(0, 80) : error});
  }

  static Future<List<String>> recentEvents({int limit = 80}) async {
    await init();
    final raw = _prefs?.getStringList(_key) ?? <String>[];
    if (raw.length <= limit) return List.from(raw);
    return raw.sublist(raw.length - limit);
  }

  static Future<List<String>> recentCrashes({int limit = 20}) async {
    await init();
    final raw = _prefs?.getStringList(_crashKey) ?? <String>[];
    if (raw.length <= limit) return List.from(raw);
    return raw.sublist(raw.length - limit);
  }

  static Future<String> exportText() async {
    final events = await recentEvents();
    final crashes = await recentCrashes();
    final buf = StringBuffer('Paper League telemetry\n');
    buf.writeln('events=${events.length} crashes=${crashes.length}');
    buf.writeln('--- crashes ---');
    for (final c in crashes) {
      buf.writeln(c);
    }
    buf.writeln('--- events ---');
    for (final e in events) {
      buf.writeln(e);
    }
    return buf.toString();
  }
}
