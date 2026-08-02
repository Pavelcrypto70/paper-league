import 'package:paper_league/domain/season.dart';

enum LeagueDivision { rookie, pro, elite, masters }

LeagueDivision divisionForScore(double score) {
  if (score >= 92) return LeagueDivision.masters;
  if (score >= 85) return LeagueDivision.elite;
  if (score >= 75) return LeagueDivision.pro;
  return LeagueDivision.rookie;
}

extension LeagueDivisionX on LeagueDivision {
  String get id => name;

  String label(bool ru) => switch (this) {
        LeagueDivision.rookie => ru ? 'Rookie' : 'Rookie',
        LeagueDivision.pro => 'Pro',
        LeagueDivision.elite => 'Elite',
        LeagueDivision.masters => ru ? 'Masters' : 'Masters',
      };

  static LeagueDivision parse(String? raw) {
    return LeagueDivision.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => LeagueDivision.rookie,
    );
  }
}

class RemoteScoreRow {
  const RemoteScoreRow({
    required this.userId,
    required this.nickname,
    required this.hue,
    required this.score,
    required this.discipline,
    required this.maxDd,
    required this.retPct,
    required this.division,
    required this.updatedAt,
    this.avatarUrl,
    this.isYou = false,
  });

  final String userId;
  final String nickname;
  final int hue;
  final double score;
  final double discipline;
  final double maxDd;
  final double retPct;
  final LeagueDivision division;
  final DateTime updatedAt;
  final String? avatarUrl;
  final bool isYou;
}

class SeasonTitleRow {
  const SeasonTitleRow({
    required this.seasonNumber,
    required this.userId,
    required this.rank,
    required this.titleKey,
    this.nickname,
  });

  final int seasonNumber;
  final String userId;
  final int rank;
  final String titleKey;
  final String? nickname;

  String title(bool ru) {
    final info = SeasonClock.of(DateTime.now());
    return info.titleForRank(rank, ru);
  }
}

class ScoreUpsert {
  const ScoreUpsert({
    required this.seasonNumber,
    required this.discipline,
    required this.maxDd,
    required this.retPct,
    required this.score,
  });

  final int seasonNumber;
  final double discipline;
  final double maxDd;
  final double retPct;
  final double score;
}
