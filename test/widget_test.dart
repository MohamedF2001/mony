import 'package:flutter_test/flutter_test.dart';
import 'package:mony/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyAppp()));

    // Verify that the splash screen or initial screen is present.
    expect(find.byType(MyAppp), findsOneWidget);

    // Settle all animations and timers (like the splash screen timer)
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
