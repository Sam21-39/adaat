import 'package:flutter_test/flutter_test.dart';
import 'package:adaat/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AdaatApp());

    // Verify the splash screen loads
    expect(find.text('Adaat'), findsOneWidget);
  });
}
