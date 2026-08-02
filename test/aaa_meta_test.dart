import 'package:flutter_test/flutter_test.dart';
import 'package:paper_league/domain/daily_desk.dart';
import 'package:paper_league/domain/desk_meta.dart';
import 'package:paper_league/data/market_feed.dart';

void main() {
  test('DeskMeta persists upgrades and credits', () {
    final m = DeskMeta(credits: 40, loginStreak: 3, unlockedUpgrades: {'up_risk_tight'});
    final round = DeskMeta.fromJson(m.toJson());
    expect(round.credits, 40);
    expect(round.loginStreak, 3);
    expect(round.has('up_risk_tight'), isTrue);
  });

  test('season rewards denser set', () {
    final list = buildSeasonRewards(
      bestRank: 99,
      tapePts: 0,
      seasonDay: 22,
      extra: {'sr_streak7'},
    );
    expect(list.length, greaterThanOrEqualTo(6));
    expect(list.any((r) => r.id == 'sr_contest' && r.unlocked), isTrue);
    expect(list.any((r) => r.id == 'sr_streak7' && r.unlocked), isTrue);
  });

  test('synthetic tick moves price', () {
    final feed = MarketFeed(seed: 3);
    final c = feed.generateVolatileSeries(start: 100, count: 5).last;
    final next = feed.tickLive(c);
    expect(next.close, isNot(equals(c.close)));
  });

  test('phase modifier returns copy', () {
    expect(dailyPhaseModifier(phase: 'finals', ru: true), contains('Finals'));
    expect(dailyPhaseModifier(phase: 'grow', ru: false), contains('Grow'));
  });
}
