import 'package:flutter_test/flutter_test.dart';

import 'package:by_train/core/data/pakrail_repository.dart';
import 'package:by_train/features/journey_planner/presentation/bloc/journey_planner_bloc.dart';
import 'package:by_train/features/journey_planner/presentation/bloc/journey_planner_event.dart';
import 'package:by_train/features/journey_planner/presentation/bloc/journey_planner_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<JourneyPlannerBloc> searchBloc({
    bool fastestRoute = true,
    bool directOnly = false,
  }) async {
    final repo = PakRailRepository();
    final lahore = (await repo.stationByName('Lahore Junction'))!;
    final karachi = (await repo.stationByName('Karachi Cantt'))!;

    final bloc = JourneyPlannerBloc(repository: repo);
    if (!fastestRoute) bloc.add(const FastestRouteToggled());
    if (directOnly) bloc.add(const DirectOnlyToggled());
    bloc.add(FromStationSelected(lahore));
    bloc.add(ToStationSelected(karachi));
    bloc.add(const SearchStarted());
    await bloc.stream.firstWhere(
      (s) => s.status == JourneyPlannerStatus.success,
    );
    return bloc;
  }

  int durationOf(JourneyPlannerState s, int i) {
    final j = s.journeys[i];
    return j.arrivalTime.difference(j.departureTime).inMinutes;
  }

  test(
    'fastest route selected moves the fastest journeys to the top',
    () async {
      final bloc = await searchBloc(fastestRoute: true);
      expect(bloc.state.journeys.length, greaterThanOrEqualTo(2));

      for (var i = 1; i < bloc.state.journeys.length; i++) {
        expect(
          durationOf(bloc.state, i - 1),
          lessThanOrEqualTo(durationOf(bloc.state, i)),
        );
      }
      await bloc.close();
    },
  );

  test(
    'without fastest route, results stay sorted by departure time',
    () async {
      final bloc = await searchBloc(fastestRoute: false);
      expect(bloc.state.journeys.length, greaterThanOrEqualTo(2));

      for (var i = 1; i < bloc.state.journeys.length; i++) {
        expect(
          bloc.state.journeys[i].departureTime.isBefore(
            bloc.state.journeys[i - 1].departureTime,
          ),
          isFalse,
        );
      }
      await bloc.close();
    },
  );

  test(
    'toggling the filter off reorders results back by departure time',
    () async {
      final bloc = await searchBloc(fastestRoute: true);
      final fastestFirst = bloc.state.journeys.first;
      expect(
        fastestFirst.arrivalTime.difference(fastestFirst.departureTime),
        lessThanOrEqualTo(
          bloc.state.journeys.last.arrivalTime.difference(
            bloc.state.journeys.last.departureTime,
          ),
        ),
      );

      bloc.add(const FastestRouteToggled());
      await bloc.stream.firstWhere((s) => !s.fastestRoute);
      await bloc.stream.firstWhere(
        (s) => s.status == JourneyPlannerStatus.success,
      );

      for (var i = 1; i < bloc.state.journeys.length; i++) {
        expect(
          bloc.state.journeys[i].departureTime.isBefore(
            bloc.state.journeys[i - 1].departureTime,
          ),
          isFalse,
        );
      }
      await bloc.close();
    },
  );
}
