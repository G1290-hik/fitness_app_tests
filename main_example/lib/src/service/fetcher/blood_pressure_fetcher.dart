import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/service/service.dart';

class BloodPressureFetcher {
  final HealthService _healthService = HealthService();

  Future<List<double>> fetchHourlySystolic(DateTime startTime, DateTime endTime) async {
    debugPrint('Fetching hourly systolic values...');
    List<double> systolicValues = [];
    for (int i = 0; i <= endTime.difference(startTime).inHours; i++) {
      DateTime hourStart = startTime.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));
      double systolic = await _healthService.aggregateData(
          [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
          hourStart,
          hourEnd,
              (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length);
      systolicValues.add(systolic);
      debugPrint('Systolic value for ${hourStart.toIso8601String()} to ${hourEnd.toIso8601String()}: $systolic');
    }
    return systolicValues;
  }

  Future<List<double>> fetchHourlyDiastolic(DateTime startTime, DateTime endTime) async {
    debugPrint('Fetching hourly diastolic values...');
    List<double> diastolicValues = [];
    for (int i = 0; i <= endTime.difference(startTime).inHours; i++) {
      DateTime hourStart = startTime.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));
      double diastolic = await _healthService.aggregateData(
          [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
          hourStart,
          hourEnd,
              (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length);
      diastolicValues.add(diastolic);
      debugPrint('Diastolic value for ${hourStart.toIso8601String()} to ${hourEnd.toIso8601String()}: $diastolic');
    }
    return diastolicValues;
  }

  Future<List<Map<String, dynamic>>> fetchHourlySystolicWithTimestamps(DateTime startTime, DateTime endTime) async {
    debugPrint('Fetching hourly systolic values with timestamps...');
    List<Map<String, dynamic>> systolicValues = [];
    for (int i = 0; i <= endTime.difference(startTime).inHours; i++) {
      DateTime hourStart = startTime.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));
      double systolic = await _healthService.aggregateData(
          [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
          hourStart,
          hourEnd,
              (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length);
      systolicValues.add({'value': systolic, 'timestamp': hourEnd});
      debugPrint('Systolic value with timestamp for ${hourStart.toIso8601String()} to ${hourEnd.toIso8601String()}: $systolic');
    }
    return systolicValues;
  }

  Future<List<Map<String, dynamic>>> fetchHourlyDiastolicWithTimestamps(DateTime startTime, DateTime endTime) async {
    debugPrint('Fetching hourly diastolic values with timestamps...');
    List<Map<String, dynamic>> diastolicValues = [];
    for (int i = 0; i <= endTime.difference(startTime).inHours; i++) {
      DateTime hourStart = startTime.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));
      double diastolic = await _healthService.aggregateData(
          [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
          hourStart,
          hourEnd,
              (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length);
      diastolicValues.add({'value': diastolic, 'timestamp': hourEnd});
      debugPrint('Diastolic value with timestamp for ${hourStart.toIso8601String()} to ${hourEnd.toIso8601String()}: $diastolic');
    }
    return diastolicValues;
  }

  Future<Map<String, List<double>>> fetchDailyBloodPressure(DateTime startDate, int days) async {
    debugPrint('Fetching daily blood pressure for $days days starting from ${startDate.toIso8601String()}...');
    List<double> minSystolic = [];
    List<double> maxSystolic = [];
    List<double> minDiastolic = [];
    List<double> maxDiastolic = [];
    for (int i = 0; i < days; i++) {
      DateTime dayStart = startDate.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));
      double minSys = await _healthService.getMinSystolicBloodPressure(dayStart, dayEnd);
      double maxSys = await _healthService.getMaxSystolicBloodPressure(dayStart, dayEnd);
      double minDia = await _healthService.getMinDiastolicBloodPressure(dayStart, dayEnd);
      double maxDia = await _healthService.getMaxDiastolicBloodPressure(dayStart, dayEnd);
      minSystolic.add(minSys);
      maxSystolic.add(maxSys);
      minDiastolic.add(minDia);
      maxDiastolic.add(maxDia);
      debugPrint('Day $i: Min systolic: $minSys, Max systolic: $maxSys, Min diastolic: $minDia, Max diastolic: $maxDia');
    }
    return {
      "minSystolic": minSystolic,
      "maxSystolic": maxSystolic,
      "minDiastolic": minDiastolic,
      "maxDiastolic": maxDiastolic,
    };
  }

  Future<Map<String, double>> getLatestBloodPressure(DateTime startTime, DateTime endTime) async {
    debugPrint('Fetching latest blood pressure between ${startTime.toIso8601String()} and ${endTime.toIso8601String()}...');
    List<HealthDataPoint> systolicData = await _healthService.getSystolicBP(startTime, endTime);
    List<HealthDataPoint> diastolicData = await _healthService.getDiastolicBP(startTime, endTime);

    double latestSystolic = 0;
    double latestDiastolic = 0;
    DateTime? latestSystolicTime;
    DateTime? latestDiastolicTime;

    if (systolicData.isNotEmpty) {
      latestSystolic = (systolicData.last.value as NumericHealthValue).numericValue.toDouble();
      latestSystolicTime = systolicData.last.dateFrom;
      debugPrint('Latest systolic value: $latestSystolic at ${latestSystolicTime.toIso8601String()}');
    }

    if (diastolicData.isNotEmpty) {
      latestDiastolic = (diastolicData.last.value as NumericHealthValue).numericValue.toDouble();
      latestDiastolicTime = diastolicData.last.dateFrom;
      debugPrint('Latest diastolic value: $latestDiastolic at ${latestDiastolicTime.toIso8601String()}');
    }

    DateTime latestTimestamp = latestSystolicTime?.isAfter(latestDiastolicTime ?? DateTime(1970)) ?? false
        ? latestSystolicTime!
        : latestDiastolicTime ?? DateTime.now();

    debugPrint('Latest timestamp: ${latestTimestamp.toIso8601String()}');
    return {
      'systolic': latestSystolic,
      'diastolic': latestDiastolic,
      'timestamp': latestTimestamp.millisecondsSinceEpoch.toDouble(),
    };
  }

  Future<Map<String, dynamic>> fetchLatestBloodPressure() async {
    debugPrint('Fetching latest blood pressure data...');
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = now;

    Map<String, double> latestBp = await getLatestBloodPressure(startOfDay, endOfDay);

    return {
      'systolic': latestBp['systolic'],
      'diastolic': latestBp['diastolic'],
      'timestamp': DateTime.fromMillisecondsSinceEpoch(latestBp['timestamp']?.toInt() ?? 0),
    };
  }
}
