import 'dart:math' as math;

import 'package:paper_league/domain/models.dart';

enum DrillDecision { long, short, skip }

enum DrillOutcome { stop, tp, time, skip }

class TapeDrillRound {
  TapeDrillRound({
    required this.symbol,
    required this.candles,
    required this.hideFrom,
    required this.horizon,
  });

  final String symbol;
  final List<Candle> candles;
  /// Index where future is hidden (decision bar).
  final int hideFrom;
  final int horizon;

  List<Candle> get revealed => candles.sublist(0, hideFrom + 1);
  List<Candle> get future =>
      candles.sublist(hideFrom + 1, math.min(candles.length, hideFrom + 1 + horizon));

  Candle get decisionBar => candles[hideFrom];
}

class TapeDrillResult {
  const TapeDrillResult({
    required this.decision,
    required this.outcome,
    required this.processScore,
    required this.rMultiple,
    required this.hadStop,
    required this.tipEn,
    required this.tipRu,
  });

  final DrillDecision decision;
  final DrillOutcome outcome;
  final int processScore;
  final double rMultiple;
  final bool hadStop;
  final String tipEn;
  final String tipRu;

  String tip(bool ru) => ru ? tipRu : tipEn;
}

TapeDrillRound buildDrillRound(List<Candle> full, {required String symbol, int? seed}) {
  final rng = math.Random(seed ?? DateTime.now().millisecondsSinceEpoch);
  if (full.length < 90) {
    return TapeDrillRound(symbol: symbol, candles: full, hideFrom: full.length ~/ 2, horizon: 24);
  }
  final hideFrom = 50 + rng.nextInt(full.length - 80);
  final horizon = 18 + rng.nextInt(16);
  return TapeDrillRound(
    symbol: symbol,
    candles: full,
    hideFrom: hideFrom.clamp(40, full.length - 25),
    horizon: horizon,
  );
}

/// Score process: stop plan, RR, skip discipline — not candle guessing.
TapeDrillResult gradeDrill({
  required TapeDrillRound round,
  required DrillDecision decision,
  required double? stop,
  double? tp,
}) {
  if (decision == DrillDecision.skip) {
    return const TapeDrillResult(
      decision: DrillDecision.skip,
      outcome: DrillOutcome.skip,
      processScore: 2,
      rMultiple: 0,
      hadStop: false,
      tipEn: 'Skip counted. Process > FOMO.',
      tipRu: 'Скип засчитан. Процесс важнее FOMO.',
    );
  }

  final entry = round.decisionBar.close;
  final side = decision == DrillDecision.long ? Side.long : Side.short;
  final stopPx = stop;
  final hadStop = stopPx != null && stopPx > 0 && (entry - stopPx).abs() > 0;
  var score = 0;
  if (hadStop) score += 3;

  double r = 0;
  var outcome = DrillOutcome.time;
  final risk = hadStop ? (entry - stopPx).abs() : entry * 0.01;
  final target = tp ??
      (side == Side.long ? entry + risk * 2 : entry - risk * 2);

  if (hadStop && risk > 0) {
    final rr = (target - entry).abs() / risk;
    if (rr >= 1.5) {
      score += 2;
    } else if (rr >= 1.0) {
      score += 1;
    }
  }

  for (final c in round.future) {
    if (side == Side.long) {
      if (hadStop && c.low <= stopPx) {
        outcome = DrillOutcome.stop;
        r = -1;
        break;
      }
      if (c.high >= target) {
        outcome = DrillOutcome.tp;
        r = (target - entry) / risk;
        break;
      }
    } else {
      if (hadStop && c.high >= stopPx) {
        outcome = DrillOutcome.stop;
        r = -1;
        break;
      }
      if (c.low <= target) {
        outcome = DrillOutcome.tp;
        r = (entry - target) / risk;
        break;
      }
    }
  }

  if (outcome == DrillOutcome.time && round.future.isNotEmpty) {
    final last = round.future.last.close;
    r = (side == Side.long ? last - entry : entry - last) / risk;
  }

  // Outcome is feedback, not the main grade — small nudge only.
  if (outcome == DrillOutcome.tp) score += 1;
  if (!hadStop) score = math.max(0, score - 2);

  String tipEn;
  String tipRu;
  if (!hadStop) {
    tipEn = 'No stop = no process points. Plan risk first.';
    tipRu = 'Без стопа нет очков процесса. Сначала риск.';
  } else if (outcome == DrillOutcome.stop) {
    tipEn = 'Stop hit. Plan held — that is the drill win.';
    tipRu = 'Стоп сработал. План держался — это победа дрилла.';
  } else if (outcome == DrillOutcome.tp) {
    tipEn = 'Target landed. Keep the same R structure.';
    tipRu = 'Тейк дошёл. Держи ту же структуру R.';
  } else {
    tipEn = 'Time exit. Review if entry was late to impulse.';
    tipRu = 'Выход по времени. Проверь, не поздний ли вход.';
  }

  return TapeDrillResult(
    decision: decision,
    outcome: outcome,
    processScore: score.clamp(0, 8),
    rMultiple: r,
    hadStop: hadStop,
    tipEn: tipEn,
    tipRu: tipRu,
  );
}
