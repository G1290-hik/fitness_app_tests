import 'dart:io';

import 'package:carp_serializable/carp_serializable.dart';
import 'package:health/health.dart';
import 'package:health_example/src/utils/util.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  List<HealthDataPoint> _healthDataList = [];

  // All types available depending on platform (iOS or Android).
  List<HealthDataType> get types => (Platform.isAndroid)
      ? dataTypesAndroid
      : (Platform.isIOS)
          ? dataTypesIOS
          : [];

  // Set up corresponding permissions
  List<HealthDataAccess> get permissions =>
      types.map((e) => HealthDataAccess.READ_WRITE).toList();

  Future<void> configureHealth() async {
    Health().configure(useHealthConnectIfAvailable: true);
  }

  Future<void> installHealthConnect() async {
    await Health().installHealthConnect();
  }

  Future<bool> authorize() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();

    bool? hasPermissions =
        await Health().hasPermissions(types, permissions: permissions);

    hasPermissions = false;

    if (!hasPermissions) {
      try {
        return await Health()
            .requestAuthorization(types, permissions: permissions);
      } catch (error) {
        print("Exception in authorize: $error");
        return false;
      }
    }
  }

  Future<String> getHealthConnectSdkStatus() async {
    assert(Platform.isAndroid, "This is only available on Android");

    final status = await Health().getHealthConnectSdkStatus();
    return 'Health Connect Status: $status';
  }

  Future<List<HealthDataPoint>> fetchData(List<HealthDataType> dataTypes,
      DateTime startTime, DateTime endTime) async {
    _healthDataList.clear();

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: dataTypes,
        startTime: startTime,
        endTime: endTime,
      );

      print('Total number of data points: ${healthData.length}. ');
      _healthDataList.addAll(healthData);
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    _healthDataList = Health().removeDuplicates(_healthDataList);

    _healthDataList.forEach((data) => print(toJsonString(data)));

    return _healthDataList;
  }

  Future<List<HealthDataPoint>> getHealthDataPoints(
      HealthDataType dataType, DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> healthDataPoints = await fetchData(
      [dataType],
      startTime,
      endTime,
    );
    return healthDataPoints;
  }

  Future<List<HealthDataPoint>> getHeartRate(
      DateTime startTime, DateTime endTime) async {
    return await getHealthDataPoints(
        HealthDataType.HEART_RATE, startTime, endTime);
  }

  Future<List<HealthDataPoint>> getSystolicBP(
      DateTime startTime, DateTime endTime) async {
    return await getHealthDataPoints(
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC, startTime, endTime);
  }

  Future<List<HealthDataPoint>> getDiastolicBP(
      DateTime startTime, DateTime endTime) async {
    return await getHealthDataPoints(
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC, startTime, endTime);
  }

  Future<List<HealthDataPoint>> getWorkout(
      DateTime startTime, DateTime endTime) async {
    return await getHealthDataPoints(
        HealthDataType.WORKOUT, startTime, endTime);
  }

  double aggregateHealthDataPoints(
      List<HealthDataPoint> dataPoints, Function(List<double>) aggregator) {
    List<double> values = dataPoints.map((e) {
      if (e.value is NumericHealthValue) {
        return (e.value as NumericHealthValue).numericValue.toDouble();
      } else {
        throw TypeError();
      }
    }).toList();

    if (values.isEmpty) {
      return 0.0; // Return 0.0 if there are no values
    }

    return aggregator(values);
  }

  // Aggregation methods for each data type
  Future<double> aggregateData(
      List<HealthDataType> dataTypes,
      DateTime startTime,
      DateTime endTime,
      Function(List<double>) aggregator) async {
    List<HealthDataPoint> dataPoints =
        await fetchData(dataTypes, startTime, endTime);
    return aggregateHealthDataPoints(dataPoints, aggregator);
  }

  // Specific aggregation functions
  Future<double> getTotalSteps(DateTime startTime, DateTime endTime) async {
    return await aggregateData([HealthDataType.STEPS], startTime, endTime,
        (values) => values.reduce((a, b) => a + b));
  }

  Future<double> getAvgHeartRate(DateTime startTime, DateTime endTime) async {
    return await aggregateData([HealthDataType.HEART_RATE], startTime, endTime,
        (values) => values.reduce((a, b) => (a + b) / values.length));
  }

  Future<double> getMinHeartRate(DateTime startTime, DateTime endTime) async {
    return await aggregateData([HealthDataType.HEART_RATE], startTime, endTime,
        (values) => values.reduce((a, b) => a < b ? a : b));
  }

  Future<double> getMaxHeartRate(DateTime startTime, DateTime endTime) async {
    return await aggregateData([HealthDataType.HEART_RATE], startTime, endTime,
        (values) => values.reduce((a, b) => a > b ? a : b));
  }

  Future<double> getCaloriesBurnt(DateTime startTime, DateTime endTime) async {
    return await aggregateData([HealthDataType.TOTAL_CALORIES_BURNED],
        startTime, endTime, (values) => values.reduce((a, b) => a + b));
  }

  Future<double> getMaxSystolicBloodPressure(
      DateTime startTime, DateTime endTime) async {
    return await aggregateData(
        [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
        startTime,
        endTime,
        (values) =>
            values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b));
  }

  Future<double> getMaxDiastolicBloodPressure(
      DateTime startTime, DateTime endTime) async {
    return await aggregateData(
        [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
        startTime,
        endTime,
        (values) =>
            values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b));
  }

  Future<double> getMinSystolicBloodPressure(
      DateTime startTime, DateTime endTime) async {
    return await aggregateData(
        [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
        startTime,
        endTime,
        (values) =>
            values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b));
  }

  Future<double> getMinDiastolicBloodPressure(
      DateTime startTime, DateTime endTime) async {
    return await aggregateData(
        [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
        startTime,
        endTime,
        (values) =>
            values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b));
  }

  Future<double> getDistance(DateTime startTime, DateTime endTime) async {
    return await aggregateData(
        [HealthDataType.DISTANCE_DELTA],
        startTime,
        endTime,
        (values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b) / 1000);
  }

  Future<bool> deleteData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(hours: 24));

    bool success = true;
    for (HealthDataType type in dataTypesAndroid) {
      success &= await Health().delete(
        type: type,
        startTime: earlier,
        endTime: now,
      );
    }

    return success;
  }

  Future<int> fetchStepData() async {
    int? steps;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool stepsPermission =
        await Health().hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!stepsPermission) {
      stepsPermission =
          await Health().requestAuthorization([HealthDataType.STEPS]);
    }

    if (stepsPermission) {
      try {
        steps = await Health().getTotalStepsInInterval(midnight, now);
      } catch (error) {
        print("Exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');
      return (steps == null) ? 0 : steps;
    } else {
      print("Authorization not granted - error in authorization");
      return 0;
    }
  }

  Future<void> revokeAccess() async {
    try {
      await Health().revokePermissions();
    } catch (error) {
      print("Exception in revokeAccess: $error");
    }
  }

  Future<double> getLatestHeartRate(
      DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> heartRateData =
        await getHeartRate(startTime, endTime);

    if (heartRateData.isNotEmpty) {
      final latestHeartRatePoint = heartRateData.last;
      if (latestHeartRatePoint.value is NumericHealthValue) {
        return (latestHeartRatePoint.value as NumericHealthValue)
            .numericValue
            .toDouble();
      } else {
        throw TypeError();
      }
    } else {
      print("No heart rate data available");
      return 0.0;
    }
  }

  Future<List<HealthDataPoint>> fetchSleepData(
      List<HealthDataType> types, DateTime startTime, DateTime endTime) async {
    return await fetchData(types, startTime, endTime);
  }
  Future<List<HealthDataPoint>> checkSleepData(DateTime startTime, DateTime endTime) async {
    List<HealthDataType> sleepTypes = [
      HealthDataType.SLEEP_SESSION,
    ];
    return await fetchData(sleepTypes, startTime, endTime);
  }

  Future<void> addSleepData(HealthDataType dataType, DateTime startTime,
      DateTime endTime, double value) async {
    bool success = await Health().writeHealthData(
      value: value,
      type: dataType,
      startTime: startTime,
      endTime: endTime,
    );
    if (success) {
      print("Data added successfully");
    } else {
      print("Failed to add data");
    }
  }

  Future<void> addSleepWeekly(DateTime startTime, DateTime endTime) async {
    for (int i = 0; i < 7; i++) {
      DateTime start = startTime.subtract(Duration(days: i));
      DateTime end = endTime.subtract(Duration(days: i));
      await addSleepSession(start, end);
    }
  }

  Future<void> addSleepMonthly(DateTime startTime, DateTime endTime) async {
    for (int i = 0; i < 30; i++) {
      DateTime start = startTime.subtract(Duration(days: i));
      DateTime end = endTime.subtract(Duration(days: i));
      await addSleepSession(start, end);
    }
  }

  Future<void> addSleepSession(DateTime startTime, DateTime endTime) async {
    await addSleepData(
        HealthDataType.SLEEP_ASLEEP, startTime, endTime, 480.0); // 480 minutes
    await addSleepData(
        HealthDataType.SLEEP_LIGHT, startTime, endTime, 240.0); // 240 minutes
    await addSleepData(
        HealthDataType.SLEEP_DEEP, startTime, endTime, 120.0); // 120 minutes
    await addSleepData(
        HealthDataType.SLEEP_REM, startTime, endTime, 60.0); // 60 minutes
    await addSleepData(
        HealthDataType.SLEEP_SESSION, startTime, endTime, 1.0); // 1 session
  }

  Future<void> deleteSleepData(DateTime startTime, DateTime endTime) async {
    bool success = true;
    for (HealthDataType type in [
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_SESSION
    ]) {
      success &= await Health().delete(
        type: type,
        startTime: startTime,
        endTime: endTime,
      );
    }
    if (success) {
      print("Sleep data deleted successfully");
    } else {
      print("Failed to delete sleep data");
    }
  }

  Future<Map<String, double>> getLatestBloodPressure(
      DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> systolicData =
        await getSystolicBP(startTime, endTime);
    List<HealthDataPoint> diastolicData =
        await getDiastolicBP(startTime, endTime);

    print('Systolic Data: $systolicData');
    print('Diastolic Data: $diastolicData');

    double latestSystolic = 0;
    double latestDiastolic = 0;

    if (systolicData.isNotEmpty) {
      latestSystolic = (systolicData.last.value as NumericHealthValue)
          .numericValue
          .toDouble();
    }

    if (diastolicData.isNotEmpty) {
      latestDiastolic = (diastolicData.last.value as NumericHealthValue)
          .numericValue
          .toDouble();
    }

    print('Latest Systolic: $latestSystolic');
    print('Latest Diastolic: $latestDiastolic');

    return {
      'systolic': latestSystolic,
      'diastolic': latestDiastolic,
    };
  }
  Future<double> getLatestSystolicBP(DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> systolicData = await getSystolicBP(startTime, endTime);

    if (systolicData.isNotEmpty) {
      return (systolicData.last.value as NumericHealthValue).numericValue.toDouble();
    } else {
      print("No systolic blood pressure data available");
      return 0.0;
    }
  }

  Future<double> getLatestDiastolicBP(DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> diastolicData = await getDiastolicBP(startTime, endTime);

    if (diastolicData.isNotEmpty) {
      return (diastolicData.last.value as NumericHealthValue).numericValue.toDouble();
    } else {
      print("No diastolic blood pressure data available");
      return 0.0;
    }
  }
}
