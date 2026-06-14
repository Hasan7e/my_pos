import 'package:flutter_test/flutter_test.dart';

import 'package:my_pos/main.dart';

void main() {
  testWidgets('MyPOS app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MyPosApp());
    await tester.pump();

    expect(find.text('MyPOS-Store'), findsOneWidget);
  });
}
