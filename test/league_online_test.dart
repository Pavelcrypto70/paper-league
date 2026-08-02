import 'package:flutter_test/flutter_test.dart';
import 'package:paper_league/domain/league_remote.dart';
import 'package:paper_league/domain/season.dart';
import 'package:paper_league/state/auth_controller.dart';

void main() {
  test('division bands match Live-Ops plan', () {
    expect(divisionForScore(70), LeagueDivision.rookie);
    expect(divisionForScore(75), LeagueDivision.pro);
    expect(divisionForScore(85), LeagueDivision.elite);
    expect(divisionForScore(92), LeagueDivision.masters);
  });

  test('season clock is stable 28-day epoch', () {
    final a = SeasonClock.of(DateTime.utc(2026, 1, 5));
    expect(a.number, 1);
    expect(a.day, 1);
    final b = SeasonClock.of(DateTime.utc(2026, 2, 1));
    expect(b.number, 1);
    expect(b.day, 28);
    final c = SeasonClock.of(DateTime.utc(2026, 2, 2));
    expect(c.number, 2);
    expect(c.day, 1);
  });

  test('ScoreUpsert carries components', () {
    const u = ScoreUpsert(
      seasonNumber: 1,
      discipline: 80,
      maxDd: 2,
      retPct: 1,
      score: 70,
    );
    expect(u.score, 70);
    expect(u.seasonNumber, 1);
  });

  test('AuthPhase enum has gate', () {
    expect(AuthPhase.values.contains(AuthPhase.needsGate), isTrue);
  });
}
