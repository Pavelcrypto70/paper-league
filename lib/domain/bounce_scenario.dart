import 'dart:math' as math;

import 'package:paper_league/domain/models.dart';

/// Procedural “bounce up” teaching charts — each day looks different.
class BounceScenario {
  const BounceScenario({
    required this.id,
    required this.buyIndex,
    required this.points,
  });

  final int id;
  /// Index in [points] where the buy / bounce line sits.
  final int buyIndex;
  /// Normalized price path 0..1 (0 = top of chart, 1 = bottom) — inverted for candles.
  final List<double> points;

  /// Seven distinct bounce shapes, then cycles.
  static BounceScenario forDay(int day, {int salt = 0}) {
    final id = ((day - 1) + salt).abs() % 7;
    return switch (id) {
      0 => _sharpV(),
      1 => _doubleBottom(),
      2 => _shallowPullback(),
      3 => _stairsDownBounce(),
      4 => _flushAndRecover(),
      5 => _wideBase(),
      _ => _lateSpikeBounce(),
    };
  }

  double buyNorm() => points[buyIndex.clamp(0, points.length - 1)];

  /// Build absolute candles around [base] (e.g. current BTC mark).
  List<Candle> candles({required double base, int bars = 36}) {
    final path = _resample(points, bars);
    final buyN = buyNorm();
    // Map norm 0(top/high) .. 1(bottom/low) → price. Bounce low near buy.
    final span = base * 0.035;
    final now = DateTime.now().toUtc();
    final out = <Candle>[];
    for (var i = 0; i < path.length; i++) {
      final mid = base + (0.5 - path[i]) * span * 2;
      final prev = i == 0 ? mid : base + (0.5 - path[i - 1]) * span * 2;
      final open = prev;
      final close = mid;
      final high = math.max(open, close) + span * 0.04;
      final low = math.min(open, close) - span * 0.04;
      out.add(
        Candle(
          openTime: now.subtract(Duration(minutes: 5 * (path.length - i))),
          open: open,
          high: high,
          low: low,
          close: close,
          volume: 12 + (i % 5) * 3.0,
        ),
      );
    }
    // Ensure buy level is a visible swing low near buyIndex.
    final bi = (buyIndex / points.length * (bars - 1)).round().clamp(0, out.length - 1);
    final level = base + (0.5 - buyN) * span * 2;
    final c = out[bi];
    out[bi] = Candle(
      openTime: c.openTime,
      open: c.open,
      high: c.high,
      low: math.min(c.low, level - span * 0.01),
      close: c.close,
      volume: c.volume,
    );
    return out;
  }

  double buyPrice({required double base}) {
    final span = base * 0.035;
    return base + (0.5 - buyNorm()) * span * 2;
  }

  static List<double> _resample(List<double> src, int n) {
    if (src.length == n) return List<double>.from(src);
    final out = <double>[];
    for (var i = 0; i < n; i++) {
      final t = i / (n - 1);
      final x = t * (src.length - 1);
      final a = x.floor().clamp(0, src.length - 1);
      final b = (a + 1).clamp(0, src.length - 1);
      final f = x - a;
      out.add(src[a] * (1 - f) + src[b] * f);
    }
    return out;
  }

  static BounceScenario _sharpV() {
    final p = <double>[];
    for (var i = 0; i < 28; i++) {
      final t = i / 27;
      double y;
      if (t < 0.42) {
        y = 0.25 + t * 1.15;
      } else if (t < 0.5) {
        y = 0.74;
      } else {
        y = 0.74 - (t - 0.5) * 1.05;
      }
      y += math.sin(i * 1.9) * 0.015;
      p.add(y.clamp(0.1, 0.9));
    }
    return BounceScenario(id: 0, buyIndex: 13, points: p);
  }

  static BounceScenario _doubleBottom() {
    final p = <double>[];
    for (var i = 0; i < 30; i++) {
      final t = i / 29;
      double y;
      if (t < 0.28) {
        y = 0.22 + t * 1.6;
      } else if (t < 0.4) {
        y = 0.72 - (t - 0.28) * 1.1;
      } else if (t < 0.52) {
        y = 0.58 + (t - 0.4) * 1.2;
      } else if (t < 0.58) {
        y = 0.72;
      } else {
        y = 0.72 - (t - 0.58) * 1.15;
      }
      y += math.sin(i * 1.3) * 0.012;
      p.add(y.clamp(0.1, 0.9));
    }
    return BounceScenario(id: 1, buyIndex: 16, points: p);
  }

  static BounceScenario _shallowPullback() {
    final p = <double>[];
    for (var i = 0; i < 28; i++) {
      final t = i / 27;
      double y;
      if (t < 0.35) {
        y = 0.55 - t * 0.55; // drift up
      } else if (t < 0.55) {
        y = 0.35 + (t - 0.35) * 1.1; // pullback
      } else {
        y = 0.57 - (t - 0.55) * 0.85; // bounce continue up
      }
      y += math.sin(i * 2.1) * 0.018;
      p.add(y.clamp(0.12, 0.85));
    }
    return BounceScenario(id: 2, buyIndex: 15, points: p);
  }

  static BounceScenario _stairsDownBounce() {
    final p = <double>[];
    for (var i = 0; i < 32; i++) {
      final t = i / 31;
      double y;
      if (t < 0.55) {
        final step = (t * 5).floor();
        y = 0.28 + step * 0.09 + (t * 5 - step) * 0.02;
      } else {
        y = 0.72 - (t - 0.55) * 1.0;
      }
      y += math.sin(i * 0.9) * 0.01;
      p.add(y.clamp(0.12, 0.88));
    }
    return BounceScenario(id: 3, buyIndex: 18, points: p);
  }

  static BounceScenario _flushAndRecover() {
    final p = <double>[];
    for (var i = 0; i < 28; i++) {
      final t = i / 27;
      double y;
      if (t < 0.5) {
        y = 0.3 + t * 0.4;
      } else if (t < 0.58) {
        y = 0.5 + (t - 0.5) * 3.2; // flush
      } else if (t < 0.64) {
        y = 0.78;
      } else {
        y = 0.78 - (t - 0.64) * 1.35;
      }
      y += math.sin(i * 1.5) * 0.014;
      p.add(y.clamp(0.1, 0.92));
    }
    return BounceScenario(id: 4, buyIndex: 17, points: p);
  }

  static BounceScenario _wideBase() {
    final p = <double>[];
    for (var i = 0; i < 34; i++) {
      final t = i / 33;
      double y;
      if (t < 0.3) {
        y = 0.25 + t * 1.4;
      } else if (t < 0.65) {
        y = 0.68 + math.sin((t - 0.3) * 18) * 0.04;
      } else {
        y = 0.68 - (t - 0.65) * 1.2;
      }
      p.add(y.clamp(0.12, 0.88));
    }
    return BounceScenario(id: 5, buyIndex: 20, points: p);
  }

  static BounceScenario _lateSpikeBounce() {
    final p = <double>[];
    for (var i = 0; i < 30; i++) {
      final t = i / 29;
      double y;
      if (t < 0.62) {
        y = 0.32 + t * 0.55 + math.sin(i * 0.8) * 0.03;
      } else if (t < 0.7) {
        y = 0.7 + (t - 0.62) * 1.4;
      } else {
        y = 0.82 - (t - 0.7) * 1.5;
      }
      p.add(y.clamp(0.12, 0.9));
    }
    return BounceScenario(id: 6, buyIndex: 20, points: p);
  }
}
