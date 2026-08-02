import 'dart:math' as math;

import 'package:paper_league/domain/models.dart';

class WeeklyPatternReport {
  const WeeklyPatternReport({
    required this.trades,
    required this.wins,
    required this.losses,
    required this.avgR,
    required this.widenPct,
    required this.avgLeftOnTableR,
    required this.revengeCount,
    required this.stopExits,
    required this.tpExits,
    required this.bestR,
    required this.worstR,
    required this.headlineEn,
    required this.headlineRu,
    required this.bulletsEn,
    required this.bulletsRu,
  });

  final int trades;
  final int wins;
  final int losses;
  final double avgR;
  final double widenPct;
  final double avgLeftOnTableR;
  final int revengeCount;
  final int stopExits;
  final int tpExits;
  final double bestR;
  final double worstR;
  final String headlineEn;
  final String headlineRu;
  final List<String> bulletsEn;
  final List<String> bulletsRu;

  String headline(bool ru) => ru ? headlineRu : headlineEn;
  List<String> bullets(bool ru) => ru ? bulletsRu : bulletsEn;

  bool get isEmpty => trades == 0;
}

WeeklyPatternReport buildWeeklyReport(List<ClosedTrade> history, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final from = n.subtract(const Duration(days: 7));
  final week = history.where((t) => t.closedAt.isAfter(from)).toList();

  if (week.isEmpty) {
    return const WeeklyPatternReport(
      trades: 0,
      wins: 0,
      losses: 0,
      avgR: 0,
      widenPct: 0,
      avgLeftOnTableR: 0,
      revengeCount: 0,
      stopExits: 0,
      tpExits: 0,
      bestR: 0,
      worstR: 0,
      headlineEn: 'No closes this week',
      headlineRu: 'На этой неделе закрытий нет',
      bulletsEn: ['Take a few planned trades with a stop — the report fills itself.'],
      bulletsRu: ['Сделай несколько плановых сделок со стопом — отчёт заполнится сам.'],
    );
  }

  final wins = week.where((t) => t.pnl > 0).length;
  final losses = week.where((t) => t.pnl < 0).length;
  final avgR = week.map((t) => t.rMultiple).reduce((a, b) => a + b) / week.length;
  final widenN = week.where((t) => t.widenedStop || !t.flags.contains(RecapFlag.noWiden)).length;
  final widenPct = widenN / week.length * 100;
  final revengeCount = week.where((t) => !t.flags.contains(RecapFlag.noRevenge)).length;
  final stopExits = week.where((t) => t.exitKind == TradeExitKind.stop).length;
  final tpExits = week.where((t) => t.exitKind == TradeExitKind.tp).length;
  final bestR = week.map((t) => t.rMultiple).reduce(math.max);
  final worstR = week.map((t) => t.rMultiple).reduce(math.min);

  double leftSum = 0;
  var leftN = 0;
  for (final t in week) {
    final risk = (t.entry - (t.stop ?? t.entry)).abs();
    if (risk <= 0) continue;
    final mfeR = t.mfe / risk;
    final left = mfeR - t.rMultiple;
    if (left > 0) {
      leftSum += left;
      leftN++;
    }
  }
  final avgLeft = leftN == 0 ? 0.0 : leftSum / leftN;

  final bulletsEn = <String>[];
  final bulletsRu = <String>[];

  void add(String en, String ru) {
    bulletsEn.add(en);
    bulletsRu.add(ru);
  }

  if (widenPct >= 30) {
    add(
      'You widened stops on ${widenPct.toStringAsFixed(0)}% of closes. Cut size instead of moving the stop.',
      'Стоп отодвигали в ${widenPct.toStringAsFixed(0)}% закрытий. Режь размер, а не двигай стоп.',
    );
  } else if (widenN == 0) {
    add(
      'Zero widened stops this week — lock that habit.',
      'Ноль отодвинутых стопов за неделю — закрепи привычку.',
    );
  }

  if (avgLeft >= 0.6) {
    add(
      'Avg left on the table ≈ +${avgLeft.toStringAsFixed(1)}R. Trail after +1R or scale 50%.',
      'В среднем оставляли на столе ≈ +${avgLeft.toStringAsFixed(1)}R. Трейл после +1R или скейл 50%.',
    );
  }

  if (revengeCount > 0) {
    add(
      'Revenge burst flagged $revengeCount×. Pause ten minutes after a red trade.',
      'Реванш отмечен $revengeCount×. Пауза 10 минут после минуса.',
    );
  }

  if (tpExits > 0 && tpExits >= stopExits) {
    add(
      'TP exits ($tpExits) ≥ stop exits ($stopExits) — plans are landing.',
      'Выходов по TP ($tpExits) не меньше, чем по стопу ($stopExits) — планы доходят.',
    );
  } else if (stopExits >= 3 && wins == 0) {
    add(
      'Mostly stop exits with no greens — check entries against local impulse.',
      'Много стопов без плюсов — сверь входы с локальным импульсом.',
    );
  }

  if (avgR >= 0.5) {
    add(
      'Avg R is +${avgR.toStringAsFixed(2)} — process is paying.',
      'Средний R +${avgR.toStringAsFixed(2)} — процесс кормит.',
    );
  } else if (avgR < 0 && widenPct < 20) {
    add(
      'Red week but rules mostly held. Discipline compounds even when PnL doesn’t.',
      'Красная неделя, но правила в основном держались. Дисциплина копится даже без PnL.',
    );
  }

  if (bulletsEn.isEmpty) {
    add(
      'Steady desk week. Keep the same stop distance and risk %.',
      'Ровная неделя за деском. Держи ту же дистанцию стопа и риск %.',
    );
  }

  String headlineEn;
  String headlineRu;
  if (widenPct >= 40) {
    headlineEn = 'Pattern: stop creep';
    headlineRu = 'Паттерн: ползучий стоп';
  } else if (avgLeft >= 0.8) {
    headlineEn = 'Pattern: early banks';
    headlineRu = 'Паттерн: ранние фиксации';
  } else if (revengeCount >= 2) {
    headlineEn = 'Pattern: revenge burst';
    headlineRu = 'Паттерн: реванш-серия';
  } else if (avgR >= 0.5 && widenPct < 20) {
    headlineEn = 'Pattern: clean process';
    headlineRu = 'Паттерн: чистый процесс';
  } else {
    headlineEn = 'Weekly desk readout';
    headlineRu = 'Недельная сводка деска';
  }

  return WeeklyPatternReport(
    trades: week.length,
    wins: wins,
    losses: losses,
    avgR: avgR,
    widenPct: widenPct,
    avgLeftOnTableR: avgLeft,
    revengeCount: revengeCount,
    stopExits: stopExits,
    tpExits: tpExits,
    bestR: bestR,
    worstR: worstR,
    headlineEn: headlineEn,
    headlineRu: headlineRu,
    bulletsEn: bulletsEn.take(4).toList(),
    bulletsRu: bulletsRu.take(4).toList(),
  );
}
