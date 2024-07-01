import 'package:health/health.dart';
import 'package:health_example/src/service/service.dart';

class BloodPressureFetcher {
  final HealthService _healthService = HealthService();

  Future<List<double>> fetchHourlySystolic(
      DateTime startTime, DateTime endTime) async {
    List<double> systolicValues = [];
    for (int i = 0; i <= endTime.difference(startTime).inHours; i++) {
      DateTime hourStart = startTime.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));
      double systolic = await _healthService.aggregateData(
          [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
          hourStart,
          hourEnd,
          (values) => values.isEmpty
              ? 0
              : values.reduce((a, b) => a + b) / values.length);
      systolicValues.add(systolic);
    }
    return systolicValues;
  }

  Future<List<double>> fetchHourlyDiastolic(
      DateTime startTime, DateTime endTime) async {
    List<double> diastolicValues = [];
    for (int i = 0; i <= endTime.difference(startTime).inHours; i++) {
      DateTime hourStart = startTime.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));
      double diastolic = await _healthService.aggregateData(
          [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
          hourStart,
          hourEnd,
          (values) => values.isEmpty
              ? 0
              : values.reduce((a, b) => a + b) / values.length);
      diastolicValues.add(diastolic);
    }
    return diastolicValues;
  }

  Future<Map<String, List<double>>> fetchDailyBloodPressure(
      DateTime startDate, int days) async {
    List<double> minSystolic = [];
    List<double> maxSystolic = [];
    List<double> minDiastolic = [];
    List<double> maxDiastolic = [];
    for (int i = 0; i < days; i++) {
      DateTime dayStart = startDate.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));
      double minSys =
          await _healthService.getMinSystolicBloodPressure(dayStart, dayEnd);
      double maxSys =
          await _healthService.getMaxSystolicBloodPressure(dayStart, dayEnd);
      double minDia =
          await _healthService.getMinDiastolicBloodPressure(dayStart, dayEnd);
      double maxDia =
          await _healthService.getMaxDiastolicBloodPressure(dayStart, dayEnd);
      minSystolic.add(minSys);
      maxSystolic.add(maxSys);
      minDiastolic.add(minDia);
      maxDiastolic.add(maxDia);
    }
    return {
      "minSystolic": minSystolic,
      "maxSystolic": maxSystolic,
      "minDiastolic": minDiastolic,
      "maxDiastolic": maxDiastolic,
    };
  }
}
