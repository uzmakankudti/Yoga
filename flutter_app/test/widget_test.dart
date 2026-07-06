import 'package:flutter_test/flutter_test.dart';

import 'package:yoga_prana_vidya/main.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const YPVApp());
    await tester.pump();
    expect(find.text('YPV'), findsWidgets);
  });
}
