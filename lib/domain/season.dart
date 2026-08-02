/// 28-day league season clock — titles/rank reset, account equity does not wipe.
class SeasonInfo {
  const SeasonInfo({
    required this.number,
    required this.day,
    required this.endsAt,
    required this.startedAt,
    required this.phase,
  });

  final int number;
  final int day; // 1..28
  final DateTime startedAt;
  final DateTime endsAt;
  final SeasonPhase phase;

  double get progress => ((day - 1) / 27).clamp(0.0, 1.0);

  Duration get remaining {
    final d = endsAt.difference(DateTime.now().toUtc());
    return d.isNegative ? Duration.zero : d;
  }

  String phaseLabel(bool ru) => switch (phase) {
        SeasonPhase.grow => ru ? 'Рост' : 'Grow',
        SeasonPhase.contest => ru ? 'Контест' : 'Contest',
        SeasonPhase.finals => ru ? 'Финал' : 'Finals',
      };

  String titleForRank(int rank, bool ru) {
    if (rank <= 0) return ru ? 'Без ранга' : 'Unranked';
    if (rank == 1) return ru ? 'Капитан стола' : 'Desk Captain';
    if (rank == 2) return ru ? 'Старший риск' : 'Senior Risk';
    if (rank == 3) return ru ? 'Контроль ленты' : 'Tape Control';
    if (rank <= 6) return ru ? 'Дисциплина+' : 'Discipline+';
    return ru ? 'Участник' : 'Contender';
  }
}

enum SeasonPhase { grow, contest, finals }

/// Fixed epoch → rolling 28-day seasons (UTC).
abstract final class SeasonClock {
  /// 2026-01-05 Monday UTC — season 1 day 1.
  static final DateTime epoch = DateTime.utc(2026, 1, 5);

  static const int lengthDays = 28;

  static SeasonInfo of(DateTime now) {
    final utc = now.toUtc();
    final elapsed = utc.difference(epoch).inDays;
    final number = (elapsed ~/ lengthDays) + 1;
    final day = (elapsed % lengthDays) + 1;
    final startedAt = epoch.add(Duration(days: (number - 1) * lengthDays));
    final endsAt = startedAt.add(const Duration(days: lengthDays));
    final phase = day <= 21
        ? SeasonPhase.grow
        : day <= 26
            ? SeasonPhase.contest
            : SeasonPhase.finals;
    return SeasonInfo(
      number: number,
      day: day,
      startedAt: startedAt,
      endsAt: endsAt,
      phase: phase,
    );
  }
}
