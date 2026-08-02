import 'package:flutter_test/flutter_test.dart';
import 'package:paper_league/domain/season.dart';
import 'package:paper_league/domain/season_liveops.dart';

void main() {
  test('season track has milestone nodes across 28 days', () {
    final track = buildSeasonTrack();
    expect(track.first.day, 1);
    expect(track.last.day, 28);
    expect(track.length, greaterThanOrEqualTo(12));
    expect(trackNodeForDay(7), isNotNull);
    expect(trackNodeForDay(4), isNull);
  });

  test('weekly challenges scale by week', () {
    final grow = SeasonClock.of(DateTime.utc(2026, 1, 5)); // day 1 week 1
    final late = SeasonInfo(
      number: grow.number,
      day: 22,
      startedAt: grow.startedAt,
      endsAt: grow.endsAt,
      phase: SeasonPhase.contest,
    );
    final w1 = weeklyChallengesFor(grow);
    final w4 = weeklyChallengesFor(late);
    expect(w1.length, 4);
    expect(w4.length, 4);
    expect(w4.first.target, greaterThanOrEqualTo(w1.first.target));
  });

  test('phase multipliers raise pressure', () {
    expect(phaseXpMult(SeasonPhase.finals), greaterThan(phaseXpMult(SeasonPhase.grow)));
    expect(catchUpCostCredits(SeasonPhase.finals), greaterThan(catchUpCostCredits(SeasonPhase.grow)));
  });

  test('SeasonProgress roundtrip', () {
    final p = SeasonProgress(seasonNumber: 3, seasonXp: 120, claimedDays: {1, 7}, streakShields: 2);
    p.weeklyProgress['1-w1_dailies'] = 3;
    final back = SeasonProgress.fromJson(p.toJson());
    expect(back.seasonXp, 120);
    expect(back.claimedDay(7), isTrue);
    expect(back.streakShields, 2);
    expect(back.weeklyProgress['1-w1_dailies'], 3);
  });
}
