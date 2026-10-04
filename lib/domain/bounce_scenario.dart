import 'dart:math' as math;

import 'package:paper_league/domain/models.dart';

enum _BounceShape { sharpV, doubleBottom, pullback, stairs, flush, wideBase, lateSpike }

/// Procedural “bounce up” teaching charts that look like real 5m BTC candles.
class BounceScenario {
  const BounceScenario({
    required this.id,
    required this.buyIndex,
    required this.closes,
  });

  final int id;
  /// Index where the bounce / BUY line sits.
  final int buyIndex;
  /// Close path in normalized space (higher = higher price).
  final List<double> closes;

  static BounceScenario forDay(int day, {int salt = 0}) {
    final id = ((day - 1) + salt).abs() % 7;
    final rng = math.Random(0xB0A7CE ^ id ^ (salt * 17));
    return switch (id) {
      0 => _build(id: 0, rng: rng, shape: _BounceShape.sharpV),
      1 => _build(id: 1, rng: rng, shape: _BounceShape.doubleBottom),
      2 => _build(id: 2, rng: rng, shape: _BounceShape.pullback),
      3 => _build(id: 3, rng: rng, shape: _BounceShape.stairs),
      4 => _build(id: 4, rng: rng, shape: _BounceShape.flush),
      5 => _build(id: 5, rng: rng, shape: _BounceShape.wideBase),
      _ => _build(id: 6, rng: rng, shape: _BounceShape.lateSpike),
    };
  }

  double buyClose() => closes[buyIndex.clamp(0, closes.length - 1)];

  double buyPrice({required double base}) {
    final (lo, hi) = _priceBand(base);
    return lo + buyClose() * (hi - lo);
  }

  /// Realistic OHLC around [base], seeded so the same day looks stable.
  List<Candle> candles({required double base, int? seed}) {
    final rng = math.Random(seed ?? (0xCAAD1E ^ id ^ (base * 100).round()));
    final (lo, hi) = _priceBand(base);
    final span = hi - lo;
    final now = DateTime.now().toUtc();
    final out = <Candle>[];
    var prevClose = lo + closes.first * span;

    for (var i = 0; i < closes.length; i++) {
      final target = lo + closes[i] * span;
      // Open near previous close with a small gap (real crypto).
      final gap = (rng.nextDouble() - 0.48) * span * 0.012;
      final open = prevClose + gap;
      final close = target + (rng.nextDouble() - 0.5) * span * 0.008;

      final bodyTop = math.max(open, close);
      final bodyBot = math.min(open, close);
      // Longer wicks on impulse / bounce bars.
      final nearBuy = (i - buyIndex).abs() <= 2;
      final wickUp = span * (nearBuy ? 0.018 : 0.01) * (0.4 + rng.nextDouble());
      final wickDn = span * (nearBuy ? 0.022 : 0.012) * (0.4 + rng.nextDouble());
      var high = bodyTop + wickUp;
      var low = bodyBot - wickDn;
      // Occasional rejection wick.
      if (rng.nextDouble() < 0.18) {
        if (close >= open) {
          low -= span * 0.015 * rng.nextDouble();
        } else {
          high += span * 0.015 * rng.nextDouble();
        }
      }
      // Pin the bounce low on the buy bar.
      if (i == buyIndex) {
        low = math.min(low, buyPrice(base: base) - span * 0.004);
      }

      final vol = 80 + rng.nextDouble() * 140 + (nearBuy ? 90 : 0);
      out.add(
        Candle(
          openTime: now.subtract(Duration(minutes: 5 * (closes.length - i))),
          open: open,
          high: high,
          low: low,
          close: close,
          volume: vol,
        ),
      );
      prevClose = close;
    }
    return out;
  }

  static (double, double) _priceBand(double base) {
    final span = base * 0.028;
    return (base - span, base + span * 0.55);
  }

  static BounceScenario _build({
    required int id,
    required math.Random rng,
    required _BounceShape shape,
  }) {
    const n = 48;
    final closes = <double>[];
    final buy = switch (shape) {
      _BounceShape.sharpV => 26,
      _BounceShape.doubleBottom => 32,
      _BounceShape.pullback => 30,
      _BounceShape.stairs => 30,
      _BounceShape.flush => 29,
      _BounceShape.wideBase => 34,
      _BounceShape.lateSpike => 36,
    };

    for (var i = 0; i < n; i++) {
      final t = i / (n - 1);
      var y = switch (shape) {
        _BounceShape.sharpV => t < 0.55 ? 0.78 - t * 0.95 : 0.22 + (t - 0.55) * 1.35,
        _BounceShape.doubleBottom => () {
            if (t < 0.3) return 0.75 - t * 1.4;
            if (t < 0.42) return 0.32 + (t - 0.3) * 1.6;
            if (t < 0.58) return 0.52 - (t - 0.42) * 1.5;
            if (t < 0.66) return 0.28;
            return 0.28 + (t - 0.66) * 1.55;
          }(),
        _BounceShape.pullback => () {
            if (t < 0.4) return 0.35 + t * 0.9;
            if (t < 0.62) return 0.72 - (t - 0.4) * 1.55;
            return 0.38 + (t - 0.62) * 1.2;
          }(),
        _BounceShape.stairs => () {
            if (t < 0.62) {
              final step = (t * 6).floor();
              return 0.82 - step * 0.1 - (t * 6 - step) * 0.02;
            }
            return 0.28 + (t - 0.62) * 1.25;
          }(),
        _BounceShape.flush => () {
            if (t < 0.52) return 0.7 - t * 0.35;
            if (t < 0.6) return 0.52 - (t - 0.52) * 3.2;
            if (t < 0.66) return 0.22;
            return 0.22 + (t - 0.66) * 1.6;
          }(),
        _BounceShape.wideBase => () {
            if (t < 0.28) return 0.8 - t * 1.7;
            if (t < 0.7) {
              return 0.3 + math.sin((t - 0.28) * 22) * 0.05 + (rng.nextDouble() - 0.5) * 0.02;
            }
            return 0.32 + (t - 0.7) * 1.5;
          }(),
        _BounceShape.lateSpike => () {
            if (t < 0.68) return 0.72 - t * 0.45 + math.sin(i * 0.7) * 0.03;
            if (t < 0.74) return 0.4 - (t - 0.68) * 2.8;
            return 0.22 + (t - 0.74) * 1.9;
          }(),
      };
      // Microstructure noise — looks like real prints, not a sine toy.
      y += (rng.nextDouble() - 0.5) * 0.035;
      if (rng.nextDouble() < 0.12 && (i - buy).abs() > 3) {
        y += (rng.nextDouble() - 0.5) * 0.06;
      }
      closes.add(y.clamp(0.08, 0.94));
    }

    // Flatten a small base at the buy index.
    final buyY = closes[buy];
    for (var j = math.max(0, buy - 1); j <= math.min(n - 1, buy + 1); j++) {
      closes[j] = buyY + (closes[j] - buyY) * 0.35;
    }
    return BounceScenario(id: id, buyIndex: buy, closes: closes);
  }
}
