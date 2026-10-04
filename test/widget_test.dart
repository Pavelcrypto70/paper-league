import 'package:flutter_test/flutter_test.dart';
import 'package:paper_league/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Paper League boots to the language gate', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PaperLeagueApp());
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Choose your language'), findsOneWidget);
  });
}
