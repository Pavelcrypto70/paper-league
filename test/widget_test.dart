import 'package:flutter_test/flutter_test.dart';
import 'package:paper_league/main.dart';

void main() {
  testWidgets('Paper League boots to splash', (tester) async {
    await tester.pumpWidget(const PaperLeagueApp());
    await tester.pump();
    expect(find.textContaining('ENTER DESK'), findsOneWidget);
  });
}
