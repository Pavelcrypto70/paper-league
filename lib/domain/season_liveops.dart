import 'dart:math';

import 'package:paper_league/domain/season.dart';

/// Dense 28-day season retention: track, weekly challenges, SP, streak pressure.
class SeasonProgress {
  SeasonProgress({
    this.seasonNumber = 0,
    this.seasonXp = 0,
    Set<int>? claimedDays,
    Map<String, int>? weeklyProgress,
    this.weekKey = '',
    this.streakShields = 0,
    this.daysActive = 0,
    Set<String>? claimedWeekRewards,
    this.missedYesterday = false,
  })  : claimedDays = claimedDays ?? {},
        weeklyProgress = weeklyProgress ?? {},
        claimedWeekRewards = claimedWeekRewards ?? {};

  int seasonNumber;
  int seasonXp;
  Set<int> claimedDays;
  Map<String, int> weeklyProgress;
  String weekKey;
  int streakShields;
  int daysActive;
  Set<String> claimedWeekRewards;
  bool missedYesterday;

  bool claimedDay(int day) => claimedDays.contains(day);

  Map<String, dynamic> toJson() => {
        'sn': seasonNumber,
        'xp': seasonXp,
        'days': claimedDays.toList(),
        'wp': weeklyProgress,
        'wk': weekKey,
        'shield': streakShields,
        'active': daysActive,
        'wr': claimedWeekRewards.toList(),
        'miss': missedYesterday,
      };

  factory SeasonProgress.fromJson(Map<String, dynamic>? m) {
    if (m == null) return SeasonProgress();
    final wpRaw = m['wp'];
    final wp = <String, int>{};
    if (wpRaw is Map) {
      for (final e in wpRaw.entries) {
        wp[e.key.toString()] = (e.value as num?)?.toInt() ?? 0;
      }
    }
    return SeasonProgress(
      seasonNumber: m['sn'] as int? ?? 0,
      seasonXp: m['xp'] as int? ?? 0,
      claimedDays: {...(m['days'] as List? ?? const []).map((e) => (e as num).toInt())},
      weeklyProgress: wp,
      weekKey: m['wk'] as String? ?? '',
      streakShields: m['shield'] as int? ?? 0,
      daysActive: m['active'] as int? ?? 0,
      claimedWeekRewards: {...(m['wr'] as List? ?? const []).map((e) => e.toString())},
      missedYesterday: m['miss'] as bool? ?? false,
    );
  }
}

enum TrackRewardKind { credits, xp, shield, reroll, ink }

class SeasonTrackNode {
  const SeasonTrackNode({
    required this.day,
    required this.kind,
    required this.amount,
    required this.titleEn,
    required this.titleRu,
  });

  final int day;
  final TrackRewardKind kind;
  final int amount;
  final String titleEn;
  final String titleRu;

  String title(bool ru) => ru ? titleRu : titleEn;
}

/// Milestone days across the 28-day season (login claim after being active that day).
List<SeasonTrackNode> buildSeasonTrack() {
  return const [
    SeasonTrackNode(day: 1, kind: TrackRewardKind.credits, amount: 20, titleEn: 'Day 1 ink', titleRu: 'День 1'),
    SeasonTrackNode(day: 2, kind: TrackRewardKind.xp, amount: 15, titleEn: 'Warm tape', titleRu: 'Прогрев ленты'),
    SeasonTrackNode(day: 3, kind: TrackRewardKind.credits, amount: 25, titleEn: 'Third open', titleRu: 'Третий заход'),
    SeasonTrackNode(day: 5, kind: TrackRewardKind.shield, amount: 1, titleEn: 'Streak shield', titleRu: 'Щит стрика'),
    SeasonTrackNode(day: 7, kind: TrackRewardKind.credits, amount: 45, titleEn: 'Week one', titleRu: 'Неделя 1'),
    SeasonTrackNode(day: 9, kind: TrackRewardKind.reroll, amount: 1, titleEn: 'Drill fuel', titleRu: 'Топливо дрилла'),
    SeasonTrackNode(day: 10, kind: TrackRewardKind.xp, amount: 30, titleEn: 'Ten deep', titleRu: 'Десять дней'),
    SeasonTrackNode(day: 12, kind: TrackRewardKind.credits, amount: 35, titleEn: 'Mid grind', titleRu: 'Середина'),
    SeasonTrackNode(day: 14, kind: TrackRewardKind.shield, amount: 1, titleEn: 'Fortnight shield', titleRu: 'Щит двух недель'),
    SeasonTrackNode(day: 16, kind: TrackRewardKind.credits, amount: 40, titleEn: 'Pressure up', titleRu: 'Давление растёт'),
    SeasonTrackNode(day: 18, kind: TrackRewardKind.xp, amount: 40, titleEn: 'Contest prep', titleRu: 'К Contest'),
    SeasonTrackNode(day: 21, kind: TrackRewardKind.credits, amount: 60, titleEn: 'Grow cleared', titleRu: 'Рост закрыт'),
    SeasonTrackNode(day: 22, kind: TrackRewardKind.ink, amount: 1, titleEn: 'Contest seal', titleRu: 'Печать Contest'),
    SeasonTrackNode(day: 24, kind: TrackRewardKind.credits, amount: 50, titleEn: 'War week', titleRu: 'Неделя войны'),
    SeasonTrackNode(day: 26, kind: TrackRewardKind.shield, amount: 1, titleEn: 'Finals shield', titleRu: 'Щит финала'),
    SeasonTrackNode(day: 27, kind: TrackRewardKind.xp, amount: 55, titleEn: 'Eve of titles', titleRu: 'Канун титулов'),
    SeasonTrackNode(day: 28, kind: TrackRewardKind.credits, amount: 100, titleEn: 'Season close', titleRu: 'Финиш сезона'),
  ];
}

class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.target,
    required this.titleEn,
    required this.titleRu,
    required this.hintEn,
    required this.hintRu,
    required this.rewardCredits,
    required this.rewardXp,
  });

  final String id;
  final int target;
  final String titleEn;
  final String titleRu;
  final String hintEn;
  final String hintRu;
  final int rewardCredits;
  final int rewardXp;

  String title(bool ru) => ru ? titleRu : titleEn;
  String hint(bool ru) => ru ? hintRu : hintEn;
}

int seasonWeekIndex(SeasonInfo s) => ((s.day - 1) ~/ 7) + 1; // 1..4

String weekKeyFor(SeasonInfo s) => '${s.number}-w${seasonWeekIndex(s)}';

/// Four challenges per season-week — rotate by season number.
List<WeeklyChallenge> weeklyChallengesFor(SeasonInfo s) {
  final week = seasonWeekIndex(s);
  final seed = s.number * 17 + week * 3;
  final packs = _weekPacks;
  final pack = packs[seed % packs.length];
  // Scale targets slightly in later weeks.
  final scale = week >= 3 ? 1.25 : 1.0;
  return pack
      .map(
        (c) => WeeklyChallenge(
          id: '${weekKeyFor(s)}_${c.id}',
          target: max(1, (c.target * scale).round()),
          titleEn: c.titleEn,
          titleRu: c.titleRu,
          hintEn: c.hintEn,
          hintRu: c.hintRu,
          rewardCredits: c.rewardCredits + (week - 1) * 5,
          rewardXp: c.rewardXp + (week - 1) * 5,
        ),
      )
      .toList();
}

const _weekPacks = <List<WeeklyChallenge>>[
  [
    WeeklyChallenge(
      id: 'dailies',
      target: 4,
      titleEn: 'Full desk days',
      titleRu: 'Полные дни деска',
      hintEn: 'Complete Daily Desk',
      hintRu: 'Закрой Daily Desk',
      rewardCredits: 40,
      rewardXp: 35,
    ),
    WeeklyChallenge(
      id: 'stops',
      target: 5,
      titleEn: 'Clean stops',
      titleRu: 'Чистые стопы',
      hintEn: 'Close with stop set, no widen',
      hintRu: 'Закрой со стопом без widen',
      rewardCredits: 35,
      rewardXp: 30,
    ),
    WeeklyChallenge(
      id: 'drills',
      target: 3,
      titleEn: 'Tape reps',
      titleRu: 'Репы ленты',
      hintEn: 'Finish Tape Drill rounds',
      hintRu: 'Пройди раунды Tape Drill',
      rewardCredits: 30,
      rewardXp: 25,
    ),
    WeeklyChallenge(
      id: 'shares',
      target: 2,
      titleEn: 'Show the book',
      titleRu: 'Покажи книгу',
      hintEn: 'Share a recap card',
      hintRu: 'Зашарь карточку рекапа',
      rewardCredits: 25,
      rewardXp: 20,
    ),
  ],
  [
    WeeklyChallenge(
      id: 'trades',
      target: 8,
      titleEn: 'Process volume',
      titleRu: 'Объём процесса',
      hintEn: 'Close planned trades',
      hintRu: 'Закрой сделки с планом',
      rewardCredits: 40,
      rewardXp: 30,
    ),
    WeeklyChallenge(
      id: 'dailies',
      target: 5,
      titleEn: 'Streak fuel',
      titleRu: 'Топливо стрика',
      hintEn: 'Complete Daily Desk',
      hintRu: 'Закрой Daily Desk',
      rewardCredits: 45,
      rewardXp: 35,
    ),
    WeeklyChallenge(
      id: 'stops',
      target: 6,
      titleEn: 'Risk lock',
      titleRu: 'Замок риска',
      hintEn: 'Clean stop closes',
      hintRu: 'Чистые закрытия по стопу',
      rewardCredits: 35,
      rewardXp: 30,
    ),
    WeeklyChallenge(
      id: 'drills',
      target: 4,
      titleEn: 'Drill grind',
      titleRu: 'Grind дрилла',
      hintEn: 'Tape Drill rounds',
      hintRu: 'Раунды Tape Drill',
      rewardCredits: 30,
      rewardXp: 25,
    ),
  ],
  [
    WeeklyChallenge(
      id: 'dailies',
      target: 5,
      titleEn: 'Contest attendance',
      titleRu: 'Явка на Contest',
      hintEn: 'Complete Daily Desk',
      hintRu: 'Закрой Daily Desk',
      rewardCredits: 50,
      rewardXp: 40,
    ),
    WeeklyChallenge(
      id: 'stops',
      target: 7,
      titleEn: 'No-widen week',
      titleRu: 'Неделя без widen',
      hintEn: 'Clean process closes',
      hintRu: 'Чистые закрытия',
      rewardCredits: 45,
      rewardXp: 35,
    ),
    WeeklyChallenge(
      id: 'shares',
      target: 3,
      titleEn: 'Public process',
      titleRu: 'Публичный процесс',
      hintEn: 'Share recaps',
      hintRu: 'Шерь рекапы',
      rewardCredits: 30,
      rewardXp: 25,
    ),
    WeeklyChallenge(
      id: 'trades',
      target: 10,
      titleEn: 'Desk hours',
      titleRu: 'Часы на деске',
      hintEn: 'Close trades',
      hintRu: 'Закрой сделки',
      rewardCredits: 40,
      rewardXp: 30,
    ),
  ],
];

double phaseXpMult(SeasonPhase phase) => switch (phase) {
      SeasonPhase.grow => 1.0,
      SeasonPhase.contest => 1.35,
      SeasonPhase.finals => 1.6,
    };

double phaseCreditMult(SeasonPhase phase) => switch (phase) {
      SeasonPhase.grow => 1.0,
      SeasonPhase.contest => 1.2,
      SeasonPhase.finals => 1.5,
    };

int catchUpCostCredits(SeasonPhase phase) => switch (phase) {
      SeasonPhase.grow => 12,
      SeasonPhase.contest => 18,
      SeasonPhase.finals => 28,
    };

String seasonPressureLine(SeasonInfo s, {required bool ru, required int streak, required int shields}) {
  final left = s.remaining;
  final daysLeft = left.inDays;
  final hours = left.inHours.remainder(24);
  if (ru) {
    return switch (s.phase) {
      SeasonPhase.grow =>
        'День ${s.day}/28 · стрик $streak · щитов $shields · ещё $daysLeft д $hours ч. Пропуск жжёт стрик.',
      SeasonPhase.contest =>
        'CONTEST день ${s.day} · SP ×1.35 · стрик $streak. Каждый день двигает ранг.',
      SeasonPhase.finals =>
        'ФИНАЛ · $daysLeft д $hours ч · SP ×1.6 · щитов $shields. Титулы режут сейчас.',
    };
  }
  return switch (s.phase) {
    SeasonPhase.grow =>
      'Day ${s.day}/28 · streak $streak · shields $shields · $daysLeft d $hours h left. Miss burns streak.',
    SeasonPhase.contest =>
      'CONTEST day ${s.day} · SP ×1.35 · streak $streak. Every day moves rank.',
    SeasonPhase.finals =>
      'FINALS · $daysLeft d $hours h · SP ×1.6 · shields $shields. Titles cut now.',
  };
}

SeasonTrackNode? trackNodeForDay(int day) {
  for (final n in buildSeasonTrack()) {
    if (n.day == day) return n;
  }
  return null;
}
