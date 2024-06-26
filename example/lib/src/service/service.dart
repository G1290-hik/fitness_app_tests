// health_service.dart
import 'dart:io';

import 'package:carp_serializable/carp_serializable.dart';
import 'package:health/health.dart';
import 'package:health_example/src/widgets/util.dart';
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

  Future<List<HealthDataPoint>> fetchData(
      List<HealthDataType> dataTypes) async {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(hours: 24));

    _healthDataList.clear();

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: dataTypes,
        startTime: yesterday,
        endTime: now,
      );

      print('Total number of data points: ${healthData.length}. '
          '${healthData.length > 100 ? 'Only showing the first 100.' : ''}');

      _healthDataList.addAll(
          (healthData.length < 100) ? healthData : healthData.sublist(0, 100));
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    _healthDataList = Health().removeDuplicates(_healthDataList);

    _healthDataList.forEach((data) => print(toJsonString(data)));

    return _healthDataList;
  }

  Future<bool> addData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(minutes: 20));

    bool success = true;

    success &= await Health().writeHealthData(
        value: 1.925,
        type: HealthDataType.HEIGHT,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 90, type: HealthDataType.WEIGHT, startTime: now);
    success &= await Health().writeHealthData(
        value: 90,
        type: HealthDataType.HEART_RATE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 90,
        type: HealthDataType.STEPS,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 200,
        type: HealthDataType.ACTIVE_ENERGY_BURNED,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 70,
        type: HealthDataType.HEART_RATE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 37,
        type: HealthDataType.BODY_TEMPERATURE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 105,
        type: HealthDataType.BLOOD_GLUCOSE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 1.8,
        type: HealthDataType.WATER,
        startTime: earlier,
        endTime: now);

    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_REM,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_ASLEEP,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_AWAKE,
        startTime: earlier,
        endTime: now);
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_DEEP,
        startTime: earlier,
        endTime: now);

    success &= await Health().writeBloodOxygen(
      saturation: 98,
      startTime: earlier,
      endTime: now,
      flowRate: 1.0,
    );
    success &= await Health().writeWorkoutData(
      activityType: HealthWorkoutActivityType.AMERICAN_FOOTBALL,
      title: "Random workout name that shows up in Health Connect",
      start: now.subtract(Duration(minutes: 15)),
      end: now,
      totalDistance: 2430,
      totalEnergyBurned: 400,
    );
    success &= await Health().writeBloodPressure(
      systolic: 90,
      diastolic: 80,
      startTime: now,
    );
    success &= await Health().writeMeal(
      mealType: MealType.SNACK,
      startTime: earlier,
      endTime: now,
      caloriesConsumed: 1000,
      carbohydrates: 50,
      protein: 25,
      fatTotal: 50,
      name: "Banana",
      caffeine: 0.002,
    );

    return success;
  }

  Future<bool> deleteData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(hours: 24));

    bool success = true;
    for (HealthDataType type in types) {
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
}
