import 'package:carp_serializable/carp_serializable.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class ActivityService {
  List<HealthDataPoint> _activityDataList = [];

  List<HealthDataType> get activityTypes => [HealthDataType.WORKOUT];

  List<HealthDataAccess> get permissions =>
      activityTypes.map((e) => HealthDataAccess.READ_WRITE).toList();

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
        await Health().hasPermissions(activityTypes, permissions: permissions);

    if (hasPermissions!) {
      try {
        return await Health()
            .requestAuthorization(activityTypes, permissions: permissions);
      } catch (error) {
        print("Exception in authorize: $error");
        return false;
      }
    }
    return true;
  }

  Future<List<HealthDataPoint>> fetchAllActivityData() async {
    _activityDataList.clear();

    try {
      DateTime startTime =
          DateTime.fromMillisecondsSinceEpoch(0); // Earliest possible date
      DateTime endTime = DateTime.now();

      List<HealthDataPoint> activityData =
          await Health().getHealthDataFromTypes(
        types: activityTypes,
        startTime: startTime,
        endTime: endTime,
      );

      print('Total number of activity data points: ${activityData.length}.');
      _activityDataList.addAll(activityData);
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    _activityDataList = Health().removeDuplicates(_activityDataList);

    _activityDataList.forEach((data) => print(toJsonString(data)));

    return _activityDataList;
  }

  Future<List<HealthDataPoint>> getActivityDataPoints() async {
    List<HealthDataPoint> activityDataPoints = await fetchAllActivityData();
    return activityDataPoints;
  }

  Future<num?> getTotalCaloriesBurnt() async {
    List<HealthDataPoint> dataPoints = await getActivityDataPoints();
    List<int?> values = dataPoints
        .where((point) => point.type == HealthDataType.WORKOUT)
        .map((e) => (e.value as WorkoutHealthValue).totalEnergyBurned)
        .toList();

    if (values.isEmpty) {
      return 0.0;
    }

    return values.reduce((a, b) => a! + b!);
  }
}
