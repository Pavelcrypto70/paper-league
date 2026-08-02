import 'package:flutter_test/flutter_test.dart';
import 'package:paper_league/data/local_league_client.dart';
import 'package:paper_league/domain/league_remote.dart';

void main() {
  test('LocalLeagueClient constructs', () {
    final c = LocalLeagueClient();
    expect(c.nickname, 'trader');
  });

  test('division parse', () {
    expect(LeagueDivisionX.parse('masters'), LeagueDivision.masters);
    expect(LeagueDivisionX.parse(null), LeagueDivision.rookie);
  });
}
