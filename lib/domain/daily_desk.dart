/// Daily retention loop — 4 micro-missions, reset at UTC midnight.
class DailyDeskState {
  const DailyDeskState({
    required this.dayKey,
    required this.plannedTrade,
    required this.cleanStop,
    required this.drillDone,
    required this.sharedCard,
  });

  final String dayKey;
  final bool plannedTrade;
  final bool cleanStop;
  final bool drillDone;
  final bool sharedCard;

  int get done =>
      (plannedTrade ? 1 : 0) + (cleanStop ? 1 : 0) + (drillDone ? 1 : 0) + (sharedCard ? 1 : 0);

  int get total => 4;
  double get progress => done / total;
  bool get complete => done >= total;

  DailyDeskState copyWith({
    String? dayKey,
    bool? plannedTrade,
    bool? cleanStop,
    bool? drillDone,
    bool? sharedCard,
  }) {
    return DailyDeskState(
      dayKey: dayKey ?? this.dayKey,
      plannedTrade: plannedTrade ?? this.plannedTrade,
      cleanStop: cleanStop ?? this.cleanStop,
      drillDone: drillDone ?? this.drillDone,
      sharedCard: sharedCard ?? this.sharedCard,
    );
  }

  static String keyFor(DateTime utc) =>
      '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';

  static DailyDeskState empty(DateTime utc) => DailyDeskState(
        dayKey: keyFor(utc),
        plannedTrade: false,
        cleanStop: false,
        drillDone: false,
        sharedCard: false,
      );

  Map<String, dynamic> toJson() => {
        'day': dayKey,
        'plan': plannedTrade,
        'stop': cleanStop,
        'drill': drillDone,
        'share': sharedCard,
      };

  factory DailyDeskState.fromJson(Map<String, dynamic> m, DateTime utc) {
    final today = keyFor(utc);
    if (m['day'] != today) return empty(utc);
    return DailyDeskState(
      dayKey: today,
      plannedTrade: m['plan'] as bool? ?? false,
      cleanStop: m['stop'] as bool? ?? false,
      drillDone: m['drill'] as bool? ?? false,
      sharedCard: m['share'] as bool? ?? false,
    );
  }
}

class SeasonReward {
  const SeasonReward({
    required this.id,
    required this.titleEn,
    required this.titleRu,
    required this.hintEn,
    required this.hintRu,
    required this.unlocked,
  });

  final String id;
  final String titleEn;
  final String titleRu;
  final String hintEn;
  final String hintRu;
  final bool unlocked;

  String title(bool ru) => ru ? titleRu : titleEn;
  String hint(bool ru) => ru ? hintRu : hintEn;
}

List<SeasonReward> buildSeasonRewards({
  required int bestRank,
  required int tapePts,
  required int seasonDay,
  required Set<String> extra,
}) {
  bool has(String id) => extra.contains(id);
  return [
    SeasonReward(
      id: 'sr_top3',
      titleEn: 'Podium ink',
      titleRu: 'Чернила пьедестала',
      hintEn: 'Finish a season top 3',
      hintRu: 'Закрой сезон в топ-3',
      unlocked: bestRank <= 3 || has('sr_top3'),
    ),
    SeasonReward(
      id: 'sr_captain',
      titleEn: 'Desk Captain',
      titleRu: 'Капитан стола',
      hintEn: 'Hold #1 at any snapshot',
      hintRu: 'Подержи #1 хотя бы раз',
      unlocked: bestRank == 1 || has('sr_captain'),
    ),
    SeasonReward(
      id: 'sr_drill',
      titleEn: 'Tape scholar',
      titleRu: 'Ученик ленты',
      hintEn: 'Earn 20 Tape Drill process pts',
      hintRu: 'Набери 20 очков Tape Drill',
      unlocked: tapePts >= 20 || has('sr_drill'),
    ),
    SeasonReward(
      id: 'sr_finals',
      titleEn: 'Finals pulse',
      titleRu: 'Пульс финала',
      hintEn: 'Reach season day 27+',
      hintRu: 'Дойди до дня 27+ сезона',
      unlocked: seasonDay >= 27 || has('sr_finals'),
    ),
    SeasonReward(
      id: 'sr_streak7',
      titleEn: 'Seven desk days',
      titleRu: 'Семь дней деска',
      hintEn: 'Hold a 7-day login streak',
      hintRu: 'Удержи 7-дневный стрик',
      unlocked: has('sr_streak7'),
    ),
    SeasonReward(
      id: 'sr_credits',
      titleEn: 'Credit grind',
      titleRu: 'Кредитный grind',
      hintEn: 'Earn 80 credits this season',
      hintRu: 'Заработай 80 credits за сезон',
      unlocked: has('sr_credits'),
    ),
    SeasonReward(
      id: 'sr_contest',
      titleEn: 'Contest ink',
      titleRu: 'Чернила Contest',
      hintEn: 'Reach contest phase (day 22+)',
      hintRu: 'Дойди до Contest (день 22+)',
      unlocked: seasonDay >= 22 || has('sr_contest'),
    ),
    SeasonReward(
      id: 'sr_track14',
      titleEn: 'Half-track',
      titleRu: 'Полтрека',
      hintEn: 'Claim 8 season track nodes',
      hintRu: 'Забери 8 узлов трека сезона',
      unlocked: has('sr_track14'),
    ),
    SeasonReward(
      id: 'sr_week_clear',
      titleEn: 'Week clearer',
      titleRu: 'Чистая неделя',
      hintEn: 'Clear all weekly challenges once',
      hintRu: 'Закрой все недельные челленджи',
      unlocked: has('sr_week_clear'),
    ),
    SeasonReward(
      id: 'sr_xp200',
      titleEn: 'Season grinder',
      titleRu: 'Гриндер сезона',
      hintEn: 'Reach 200 season XP',
      hintRu: 'Набери 200 XP сезона',
      unlocked: has('sr_xp200'),
    ),
    SeasonReward(
      id: 'sr_streak14',
      titleEn: 'Two-week desk',
      titleRu: 'Две недели деска',
      hintEn: '14-day login streak',
      hintRu: 'Стрик 14 дней',
      unlocked: has('sr_streak14'),
    ),
  ];
}
