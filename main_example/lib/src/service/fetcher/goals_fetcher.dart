import 'package:health/health.dart';
import 'package:health_example/src/service/service.dart';

class StepDataFetcher {
  final HealthService _healthService = HealthService();

  Future<List<double>> fetchStepsData(
      DateTime startTime, DateTime endTime, Duration interval) async {
    List<double> stepsValues = [];
    int intervalsCount =
        endTime.difference(startTime).inMinutes ~/ interval.inMinutes;

    for (int i = 0; i <= intervalsCount; i++) {
      DateTime periodStart =
          startTime.add(Duration(minutes: i * interval.inMinutes));
      DateTime periodEnd = periodStart.add(interval);

      double steps = await _healthService.aggregateData(
          [HealthDataType.STEPS],
          periodStart,
          periodEnd,
          (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b));
      stepsValues.add(steps);
    }

    return stepsValues;
  }

  Future<List<double>> fetchCaloriesData(
      DateTime startTime, DateTime endTime, Duration interval) async {
    List<double> caloriesValues = [];
    int intervalsCount =
        endTime.difference(startTime).inMinutes ~/ interval.inMinutes;

    for (int i = 0; i <= intervalsCount; i++) {
      DateTime periodStart =
          startTime.add(Duration(minutes: i * interval.inMinutes));
      DateTime periodEnd = periodStart.add(interval);

      double calories = await _healthService.aggregateData(
          [HealthDataType.TOTAL_CALORIES_BURNED],
          periodStart,
          periodEnd,
          (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b));
      caloriesValues.add(calories);
    }

    return caloriesValues;
  }
}
