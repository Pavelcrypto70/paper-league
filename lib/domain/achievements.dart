import 'package:flutter/material.dart';
import 'package:paper_league/domain/models.dart';

enum AchievementId {
  firstFill,
  firstGreen,
  rulesHeld,
  tpSniper,
  rTwo,
  partialPro,
  ironLoss,
  tenTrades,
  discNinety,
  winStreak3,
  riskMonk,
  multiAsset,
  noWidenFive,
  comeback,
}

class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.icon,
    required this.titleEn,
    required this.titleRu,
    required this.descEn,
    required this.descRu,
  });

  final AchievementId id;
  final IconData icon;
  final String titleEn;
  final String titleRu;
  final String descEn;
  final String descRu;

  String title(bool ru) => ru ? titleRu : titleEn;
  String desc(bool ru) => ru ? descRu : descEn;
  String get key => id.name;
}

const kAchievements = <AchievementDef>[
  AchievementDef(
    id: AchievementId.firstFill,
    icon: Icons.bolt_rounded,
    titleEn: 'First fill',
    titleRu: 'Первый филл',
    descEn: 'Close your first paper trade.',
    descRu: 'Закрой первую бумажную сделку.',
  ),
  AchievementDef(
    id: AchievementId.firstGreen,
    icon: Icons.trending_up_rounded,
    titleEn: 'First green',
    titleRu: 'Первый плюс',
    descEn: 'Bank a winning trade.',
    descRu: 'Закрой сделку в плюс.',
  ),
  AchievementDef(
    id: AchievementId.rulesHeld,
    icon: Icons.verified_rounded,
    titleEn: 'Rules held',
    titleRu: 'По правилам',
    descEn: 'Close with all four discipline flags green.',
    descRu: 'Закрой сделку со всеми четырьмя флагами дисциплины.',
  ),
  AchievementDef(
    id: AchievementId.tpSniper,
    icon: Icons.gps_fixed_rounded,
    titleEn: 'TP sniper',
    titleRu: 'Снайпер TP',
    descEn: 'Exit via take-profit.',
    descRu: 'Выйди по тейк-профиту.',
  ),
  AchievementDef(
    id: AchievementId.rTwo,
    icon: Icons.looks_two_rounded,
    titleEn: '+2R club',
    titleRu: 'Клуб +2R',
    descEn: 'Close a trade at +2R or better.',
    descRu: 'Закрой сделку на +2R или лучше.',
  ),
  AchievementDef(
    id: AchievementId.partialPro,
    icon: Icons.call_split_rounded,
    titleEn: 'Scale out',
    titleRu: 'Скейл-аут',
    descEn: 'Take a partial close.',
    descRu: 'Сделай частичное закрытие.',
  ),
  AchievementDef(
    id: AchievementId.ironLoss,
    icon: Icons.shield_rounded,
    titleEn: 'Iron stop',
    titleRu: 'Железный стоп',
    descEn: 'Take a stop-loss without widening.',
    descRu: 'Прими стоп без отодвигания.',
  ),
  AchievementDef(
    id: AchievementId.tenTrades,
    icon: Icons.tag_rounded,
    titleEn: 'Desk ten',
    titleRu: 'Десять сделок',
    descEn: 'Close 10 trades.',
    descRu: 'Закрой 10 сделок.',
  ),
  AchievementDef(
    id: AchievementId.discNinety,
    icon: Icons.military_tech_rounded,
    titleEn: 'Disc 90',
    titleRu: 'Дисц 90',
    descEn: 'Reach discipline score 90.',
    descRu: 'Набери 90 очков дисциплины.',
  ),
  AchievementDef(
    id: AchievementId.winStreak3,
    icon: Icons.local_fire_department_rounded,
    titleEn: 'Hot streak',
    titleRu: 'Серия',
    descEn: 'Win 3 trades in a row.',
    descRu: 'Три плюсовые сделки подряд.',
  ),
  AchievementDef(
    id: AchievementId.riskMonk,
    icon: Icons.balance_rounded,
    titleEn: 'Risk monk',
    titleRu: 'Монах риска',
    descEn: 'Five closes within the risk budget.',
    descRu: 'Пять закрытий в лимите риска.',
  ),
  AchievementDef(
    id: AchievementId.multiAsset,
    icon: Icons.hub_rounded,
    titleEn: 'Multi-book',
    titleRu: 'Мультикнига',
    descEn: 'Trade three different symbols.',
    descRu: 'Поторгуй три разных символа.',
  ),
  AchievementDef(
    id: AchievementId.noWidenFive,
    icon: Icons.lock_rounded,
    titleEn: 'Stop lock',
    titleRu: 'Стоп на замке',
    descEn: 'Five closes without widening the stop.',
    descRu: 'Пять закрытий без отодвигания стопа.',
  ),
  AchievementDef(
    id: AchievementId.comeback,
    icon: Icons.replay_rounded,
    titleEn: 'Comeback',
    titleRu: 'Камбэк',
    descEn: 'Win right after a losing trade.',
    descRu: 'Плюс сразу после минусовой сделки.',
  ),
];

AchievementDef? achievementById(AchievementId id) {
  for (final a in kAchievements) {
    if (a.id == id) return a;
  }
  return null;
}

AchievementDef? achievementByKey(String key) {
  for (final a in kAchievements) {
    if (a.key == key) return a;
  }
  return null;
}

/// Returns newly unlocked achievement keys.
List<String> evaluateAchievements({
  required Set<String> already,
  required List<ClosedTrade> history,
  required int discipline,
  ClosedTrade? justClosed,
}) {
  final newly = <String>[];

  void unlock(AchievementId id) {
    final k = id.name;
    if (!already.contains(k) && !newly.contains(k)) newly.add(k);
  }

  if (history.isNotEmpty) unlock(AchievementId.firstFill);
  if (history.any((t) => t.pnl > 0)) unlock(AchievementId.firstGreen);
  if (history.length >= 10) unlock(AchievementId.tenTrades);
  if (discipline >= 90) unlock(AchievementId.discNinety);

  final symbols = history.map((t) => t.symbol).toSet();
  if (symbols.length >= 3) unlock(AchievementId.multiAsset);

  final sizeOk = history.where((t) => t.flags.contains(RecapFlag.sizeOk)).length;
  if (sizeOk >= 5) unlock(AchievementId.riskMonk);

  final noWiden = history.where((t) => t.flags.contains(RecapFlag.noWiden)).length;
  if (noWiden >= 5) unlock(AchievementId.noWidenFive);

  // Win streak from newest
  var streak = 0;
  for (final t in history) {
    if (t.pnl > 0) {
      streak++;
      if (streak >= 3) {
        unlock(AchievementId.winStreak3);
        break;
      }
    } else {
      break;
    }
  }

  final t = justClosed;
  if (t != null) {
    if (t.flags.length >= 4 &&
        t.flags.contains(RecapFlag.stopSet) &&
        t.flags.contains(RecapFlag.sizeOk) &&
        t.flags.contains(RecapFlag.noWiden) &&
        t.flags.contains(RecapFlag.noRevenge)) {
      unlock(AchievementId.rulesHeld);
    }
    if (t.exitKind == TradeExitKind.tp) unlock(AchievementId.tpSniper);
    if (t.rMultiple >= 2) unlock(AchievementId.rTwo);
    if (t.exitKind == TradeExitKind.partial) unlock(AchievementId.partialPro);
    if (t.exitKind == TradeExitKind.stop && t.flags.contains(RecapFlag.noWiden)) {
      unlock(AchievementId.ironLoss);
    }
    if (history.length >= 2 && t.pnl > 0 && history[1].pnl < 0) {
      unlock(AchievementId.comeback);
    }
  }

  return newly;
}
