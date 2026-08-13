import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:by_train/core/data/pakrail_repository.dart';
import 'package:by_train/features/journey_planner/presentation/journey_planner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('journey planner finds a real Karakoram Express journey', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    // Widget tests run in a fake-async zone where file I/O never completes;
    // warm the shared dataset cache with real async first.
    await tester.runAsync(() => PakRailRepository().loadStations());

    await tester.pumpWidget(const MaterialApp(home: JourneyPlannerScreen()));
    await tester.pumpAndSettle();

    // Open the departure-station picker (first TextField in the form).
    await tester.tap(find.byType(TextField).at(0));
    await tester.pumpAndSettle();
    expect(find.text('Choose Departure Station'), findsOneWidget);

    // Type in the picker's search field (the last TextField on screen).
    await tester.enterText(find.byType(TextField).last, 'Lahore');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Lahore Junction'));
    await tester.pumpAndSettle();

    // Open the destination-station picker (second TextField in the form).
    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Choose Destination Station'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Karachi Cantt');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Karachi Cantt'));
    await tester.pumpAndSettle();

    // Search for journeys.
    await tester.tap(find.text('Find Best Journeys'));
    await tester.pumpAndSettle();

    // A real journey exists: Karakoram Express 42DN runs Lahore -> Karachi.
    expect(find.textContaining('Karakoram Express'), findsWidgets);
    // The fastest-route preference (default) tags the top result.
    expect(find.textContaining('FASTEST'), findsWidgets);
  });

  testWidgets('bookmarking a result marks the card as saved', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() => PakRailRepository().loadStations());

    await tester.pumpWidget(const MaterialApp(home: JourneyPlannerScreen()));
    await tester.pumpAndSettle();

    // Pick Lahore -> Karachi as in the search test above.
    await tester.tap(find.byType(TextField).at(0));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Lahore');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Lahore Junction'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Karachi Cantt');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Karachi Cantt'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Find Best Journeys'));
    await tester.pumpAndSettle();

    // Not saved yet: outline bookmark, no SAVED tag.
    expect(find.byIcon(Icons.bookmark_border_rounded), findsWidgets);
    expect(find.text('SAVED'), findsNothing);

    // Save the first result (scroll it into view first).
    await tester.ensureVisible(find.byIcon(Icons.bookmark_border_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.bookmark_border_rounded).first);
    await tester.pumpAndSettle();

    // The card now shows the filled bookmark and a SAVED tag.
    expect(find.byIcon(Icons.bookmark_rounded), findsWidgets);
    expect(find.text('SAVED'), findsWidgets);
  });
}
