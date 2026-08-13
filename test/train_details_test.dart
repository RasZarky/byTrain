import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:by_train/core/data/pakrail_repository.dart';
import 'package:by_train/features/train/domain/models/train.dart';
import 'package:by_train/features/train/presentation/train_details_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget app({required String trainId, Train? train}) {
    final router = GoRouter(
      initialLocation: '/train-details/$trainId',
      routes: [
        GoRoute(
          path: '/train-details/:id',
          builder: (context, state) => TrainDetailsScreen(
            trainId: state.pathParameters['id']!,
            train: train,
          ),
        ),
        GoRoute(
          path: '/route-details/:id',
          builder: (context, state) => const Scaffold(body: Text('ROUTE')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('train details shows real data with no live UI', (tester) async {
    // Warm the dataset cache with real async (widget tests use fake async).
    await tester.runAsync(() => PakRailRepository().loadAllTrains());
    final trains = await tester.runAsync(
      () => PakRailRepository().loadAllTrains(),
    );
    final karakoram = trains!.firstWhere((t) => t.number == '41UP');

    await tester.pumpWidget(app(trainId: '41UP', train: karakoram));
    await tester.pumpAndSettle();

    expect(find.text('Karakoram Express'), findsWidgets);
    expect(find.text('Train Number: #41UP'), findsOneWidget);
    expect(find.text('Operational Status'), findsOneWidget);
    expect(find.text('JOURNEY DETAILS'), findsOneWidget);
    expect(find.text('TRAIN INFORMATION'), findsOneWidget);
    expect(find.text('View Full Route'), findsOneWidget);
    // No loading spinner; the live-pulse status card is gone.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('deep link loads the train from the dataset', (tester) async {
    await tester.runAsync(() => PakRailRepository().loadAllTrains());

    await tester.pumpWidget(app(trainId: '41UP'));
    // Initial frame shows the loading state.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Karakoram Express'), findsWidgets);
    expect(find.text('View Full Route'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('unknown train id shows a not-found state', (tester) async {
    await tester.runAsync(() => PakRailRepository().loadAllTrains());

    await tester.pumpWidget(app(trainId: 'ZZZ'));
    await tester.pumpAndSettle();

    expect(
      find.text('Train not found in the current timetable'),
      findsOneWidget,
    );
    expect(find.text('View Full Route'), findsNothing);
  });
}
