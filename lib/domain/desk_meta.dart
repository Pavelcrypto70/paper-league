/// Soft-currency retention meta — streak, credits, upgrade sinks (no IAP).
class DeskMeta {
  DeskMeta({
    this.loginStreak = 0,
    this.credits = 0,
    this.lastLoginDay = '',
    Set<String>? unlockedUpgrades,
    this.drillRerolls = 0,
    this.creditsEarnedSeason = 0,
  }) : unlockedUpgrades = unlockedUpgrades ?? {};

  int loginStreak;
  int credits;
  String lastLoginDay;
  Set<String> unlockedUpgrades;
  int drillRerolls;
  int creditsEarnedSeason;

  bool has(String id) => unlockedUpgrades.contains(id);

  Map<String, dynamic> toJson() => {
        'streak': loginStreak,
        'credits': credits,
        'last': lastLoginDay,
        'up': unlockedUpgrades.toList(),
        'rerolls': drillRerolls,
        'earned': creditsEarnedSeason,
      };

  factory DeskMeta.fromJson(Map<String, dynamic>? m) {
    if (m == null) return DeskMeta();
    return DeskMeta(
      loginStreak: m['streak'] as int? ?? 0,
      credits: m['credits'] as int? ?? 0,
      lastLoginDay: m['last'] as String? ?? '',
      unlockedUpgrades: {...(m['up'] as List? ?? const []).map((e) => e.toString())},
      drillRerolls: m['rerolls'] as int? ?? 0,
      creditsEarnedSeason: m['earned'] as int? ?? 0,
    );
  }
}

class DeskUpgradeDef {
  const DeskUpgradeDef({
    required this.id,
    required this.cost,
    required this.titleEn,
    required this.titleRu,
    required this.hintEn,
    required this.hintRu,
  });

  final String id;
  final int cost;
  final String titleEn;
  final String titleRu;
  final String hintEn;
  final String hintRu;

  String title(bool ru) => ru ? titleRu : titleEn;
  String hint(bool ru) => ru ? hintRu : hintEn;
}

const kDeskUpgrades = <DeskUpgradeDef>[
  DeskUpgradeDef(
    id: 'up_risk_tight',
    cost: 40,
    titleEn: 'Tight risk presets',
    titleRu: 'Жёсткие пресеты риска',
    hintEn: 'Default stop chips include 0.6%',
    hintRu: 'В тикете появляется стоп 0.6%',
  ),
  DeskUpgradeDef(
    id: 'up_pb_slot',
    cost: 55,
    titleEn: 'Extra playbook slot',
    titleRu: 'Слот playbook',
    hintEn: '+2 custom playbook capacity',
    hintRu: '+2 слота под свои playbooks',
  ),
  DeskUpgradeDef(
    id: 'up_drill_reroll',
    cost: 30,
    titleEn: 'Drill reroll pack',
    titleRu: 'Пачка реролов дрилла',
    hintEn: '+3 Tape Drill rerolls',
    hintRu: '+3 рерола Tape Drill',
  ),
  DeskUpgradeDef(
    id: 'up_hud_pulse',
    cost: 70,
    titleEn: 'HUD pulse ink',
    titleRu: 'Чернила пульса HUD',
    hintEn: 'Stronger mark flash on fills',
    hintRu: 'Сильнее вспышка цены на fill',
  ),
  DeskUpgradeDef(
    id: 'up_streak_shield',
    cost: 35,
    titleEn: 'Streak shield pack',
    titleRu: 'Пачка щитов стрика',
    hintEn: '+2 shields — miss a day without reset',
    hintRu: '+2 щита — пропуск дня без сброса стрика',
  ),
  DeskUpgradeDef(
    id: 'up_season_boost',
    cost: 90,
    titleEn: 'Season SP boost',
    titleRu: 'Буст SP сезона',
    hintEn: '+15% season XP for the rest of the season',
    hintRu: '+15% XP сезона до конца сезона',
  ),
  DeskUpgradeDef(
    id: 'up_catchup_token',
    cost: 25,
    titleEn: 'Catch-up token',
    titleRu: 'Токен догона',
    hintEn: 'One free track catch-up claim',
    hintRu: 'Один бесплатный догон трека',
  ),
];

String dailyPhaseModifier({required String phase, required bool ru}) {
  return switch (phase) {
    'contest' => ru ? 'Contest: Daily жёстче · SP ×1.35' : 'Contest: Daily harder · SP ×1.35',
    'finals' => ru ? 'Finals: каждый день режет титулы · SP ×1.6' : 'Finals: every day cuts titles · SP ×1.6',
    _ => ru ? 'Grow: строй стрик · не пропускай трек' : 'Grow: build streak · don’t skip the track',
  };
}
