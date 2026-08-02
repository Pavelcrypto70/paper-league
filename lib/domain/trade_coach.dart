import 'dart:math' as math;

import 'package:paper_league/domain/models.dart';

class TradeAnalysis {
  const TradeAnalysis({
    required this.headline,
    required this.points,
    required this.mfeR,
    required this.maeR,
  });

  final String headline;
  final List<String> points;
  final double mfeR;
  final double maeR;
}

/// Mini coach from tape + MFE/MAE — rule-based, bilingual.
TradeAnalysis analyzeTrade(ClosedTrade trade, {required bool ru}) {
  final risk = (trade.entry - (trade.stop ?? trade.entry)).abs();
  final mfeR = risk > 0 ? trade.mfe / risk : 0.0;
  final maeR = risk > 0 ? trade.mae / risk : 0.0;
  final r = trade.rMultiple;
  final win = trade.pnl >= 0;
  final leftOnTable = mfeR - r;

  final points = <String>[];

  if (!win) {
    if (trade.exitKind == TradeExitKind.stop && mfeR >= 0.8) {
      points.add(
        ru
            ? 'До стопа цена ходила в плюс до +${mfeR.toStringAsFixed(1)}R. В следующий раз — частичное закрытие или трейл после +1R.'
            : 'Price ran +${mfeR.toStringAsFixed(1)}R in your favor before the stop. Next time: partial at +1R or trail the stop.',
      );
    } else if (mfeR < 0.25) {
      points.add(
        ru
            ? 'Сделка почти не уходила в плюс (MFE ${mfeR.toStringAsFixed(1)}R). Вход против импульса — дождись отката или подтверждения.'
            : 'Trade barely went green (MFE ${mfeR.toStringAsFixed(1)}R). Entry fought momentum — wait for a pullback or confirmation.',
      );
    } else if (trade.exitKind == TradeExitKind.manual) {
      points.add(
        ru
            ? 'Ручное закрытие в минус. Ок, если сломан тезис; иначе лучше дать отработать стопу по плану.'
            : 'Manual cut in the red. Fine if the thesis broke; otherwise let the planned stop do its job.',
      );
    }

    if (trade.widenedStop) {
      points.add(
        ru
            ? 'Стоп отодвигали после входа — это бьёт по дисциплине сильнее, чем сам минус.'
            : 'Stop was widened after entry — that hurts discipline more than the loss itself.',
      );
    }

    if (maeR > 1.15 && trade.exitKind == TradeExitKind.stop) {
      points.add(
        ru
            ? 'Просадка дошла до стопа (${maeR.toStringAsFixed(1)}R) — защита сработала. Не мсти рынку следующей сделкой.'
            : 'Drawdown hit the stop (${maeR.toStringAsFixed(1)}R) — protection worked. Don’t revenge the next ticket.',
      );
    }

    if (points.isEmpty) {
      points.add(
        ru
            ? 'Минус по правилам — нормальный исход. Повтори процесс, не размер.'
            : 'A rules-based loss is a valid outcome. Repeat the process, not the size.',
      );
    }
  } else {
    if (trade.exitKind == TradeExitKind.tp) {
      points.add(
        ru
            ? 'Тейк отработал по плану. Зафиксируй сетап: тот же стоп-дистанс и риск.'
            : 'Take-profit hit as planned. Lock the setup: same stop distance and risk.',
      );
    }
    if (leftOnTable >= 0.6) {
      points.add(
        ru
            ? 'На пике было +${mfeR.toStringAsFixed(1)}R, закрыли +${r.toStringAsFixed(1)}R. Оставили ~${leftOnTable.toStringAsFixed(1)}R — после +1R подтягивай стоп.'
            : 'Peak was +${mfeR.toStringAsFixed(1)}R, you banked +${r.toStringAsFixed(1)}R. ~${leftOnTable.toStringAsFixed(1)}R left on the table — trail after +1R.',
      );
    } else if (leftOnTable < 0.25 && r >= 1) {
      points.add(
        ru
            ? 'Выход близко к пику — сильный exit craft. Так и держи.'
            : 'Exit near the peak — strong exit craft. Keep that muscle.',
      );
    }
    if (r > 0 && r < 0.7 && mfeR < 1) {
      points.add(
        ru
            ? 'Маленький плюс. Можно масштабировать выход: 50% на +1R, остаток на трейле.'
            : 'Small win. Scale next time: 50% at +1R, trail the runner.',
      );
    }
    if (trade.exitKind == TradeExitKind.partial) {
      points.add(
        ru
            ? 'Частичное закрытие — правильно. Не забудь подтянуть стоп на остаток.'
            : 'Partial booked — good. Tighten the stop on the runner.',
      );
    }
    if (points.isEmpty) {
      points.add(
        ru
            ? 'Чистый плюс. Повтори процесс, не догоняй дофамин.'
            : 'Clean green. Repeat the process, not the dopamine.',
      );
    }
  }

  final tapeHint = _tapeStructure(trade, ru);
  if (tapeHint != null) points.add(tapeHint);

  final headline = win
      ? (ru ? 'Что усилить в плюсовой' : 'How to bank more next win')
      : (ru ? 'Почему ушли в минус' : 'Why this closed red');

  return TradeAnalysis(
    headline: headline,
    points: points.take(3).toList(),
    mfeR: mfeR,
    maeR: maeR,
  );
}

String? _tapeStructure(ClosedTrade trade, bool ru) {
  final tape = trade.tape;
  if (tape.length < 8) return null;
  final ei = trade.entryIndex.clamp(0, tape.length - 1);
  final start = math.max(0, ei - 6);
  final before = tape.sublist(start, ei);
  if (before.length < 3) return null;

  var up = 0;
  var down = 0;
  for (final c in before) {
    if (c.isBull) {
      up++;
    } else {
      down++;
    }
  }

  if (trade.side == Side.long && down >= 4 && trade.pnl < 0) {
    return ru
        ? 'Перед входом шли медвежьи свечи — long против локального тренда.'
        : 'Bearish candles into the entry — long fought the local trend.';
  }
  if (trade.side == Side.short && up >= 4 && trade.pnl < 0) {
    return ru
        ? 'Перед входом шли бычьи свечи — short против локального тренда.'
        : 'Bullish candles into the entry — short fought the local trend.';
  }
  if (trade.side == Side.long && up >= 4 && trade.pnl >= 0) {
    return ru
        ? 'Вход по бычьему импульсу — структура на графике совпала с направлением.'
        : 'Long with bullish impulse — tape structure matched your side.';
  }
  if (trade.side == Side.short && down >= 4 && trade.pnl >= 0) {
    return ru
        ? 'Вход по медвежьему импульсу — структура на графике совпала с направлением.'
        : 'Short with bearish impulse — tape structure matched your side.';
  }
  return null;
}
