import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:by_train/core/router/app_router.dart';
import 'package:by_train/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpThroughSplash(WidgetTester tester) async {
    // A fresh router per test: the app's global router retains its last
    // position across test cases, which would skip the splash entirely.
    await tester.pumpWidget(ByTrainApp(routerConfig: AppRouter.buildRouter()));
    // Let the splash animation and its 2.2s navigation timer elapse.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();
  }

  testWidgets('onboarding shows on the first launch', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpThroughSplash(tester);

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('onboarding is skipped after it was completed once', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    await pumpThroughSplash(tester);

    expect(find.text('Skip'), findsNothing);
    // Lands on Home's empty state (no saved journeys).
    expect(find.text('Upcoming Journeys'), findsOneWidget);
    expect(find.text('No upcoming journeys yet'), findsOneWidget);
  });
}
