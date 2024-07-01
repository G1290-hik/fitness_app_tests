import 'package:carp_serializable/carp_serializable.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';

class ActivityService {
  List<HealthDataPoint> _activityDataList = [];

  List<HealthDataType> get activityTypes => [HealthDataType.WORKOUT];

  List<HealthDataAccess> get permissions =>
      activityTypes.map((e) => HealthDataAccess.READ_WRITE).toList();

  Future<List<HealthDataPoint>> fetchAllActivityData(
      DateTime startTime, DateTime endTime) async {
    _activityDataList.clear();

    try {
      List<HealthDataPoint> activityData =
          await Health().getHealthDataFromTypes(
        types: activityTypes,
        startTime: startTime,
        endTime: endTime,
      );

      debugPrint(
          'Total number of activity data points: ${activityData.length}.');
      _activityDataList.addAll(activityData);
    } catch (error) {
      debugPrint("Exception in getHealthDataFromTypes: $error");
    }

    // Filter out invalid dates
    _activityDataList = _activityDataList
        .where((data) =>
            data.dateFrom.isAfter(DateTime(2000)) &&
            data.dateTo.isAfter(DateTime(2000)))
        .toList();

    _activityDataList = Health().removeDuplicates(_activityDataList);

    _activityDataList.forEach((data) => debugPrint(toJsonString(data)));

    return _activityDataList;
  }

  Future<List<HealthDataPoint>> getActivityDataPoints(
      DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> activityDataPoints =
        await fetchAllActivityData(startTime, endTime);
    return activityDataPoints;
  }

  Future<num?> getTotalCaloriesBurnt(
      DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> dataPoints =
        await getActivityDataPoints(startTime, endTime);
    List<int?> values = dataPoints
        .where((point) => point.type == HealthDataType.WORKOUT)
        .map((e) => (e.value as WorkoutHealthValue).totalEnergyBurned)
        .toList();

    if (values.isEmpty) {
      return 0.0;
    }

    return values.where((value) => value != null).reduce((a, b) => a! + b!);
  }

  Future<Map<DateTime, Map<String, dynamic>>> aggregateDataByTimeFrame(
      DateTime startTime, DateTime endTime) async {
    List<HealthDataPoint> dataPoints =
        await getActivityDataPoints(startTime, endTime);

    debugPrint('Number of data points fetched: ${dataPoints.length}');

    Map<DateTime, Map<String, dynamic>> aggregatedData = {};

    // Grouping data points into sessions
    List<List<HealthDataPoint>> sessions = [];
    for (var point in dataPoints) {
      if (point.type == HealthDataType.WORKOUT) {
        bool addedToSession = false;
        for (var session in sessions) {
          // Check if the point belongs to an existing session
          if (point.dateFrom.difference(session.last.dateTo).inMinutes <= 5) {
            session.add(point);
            addedToSession = true;
            break;
          }
        }
        if (!addedToSession) {
          // Create a new session
          sessions.add([point]);
        }
      }
    }

    debugPrint('Number of sessions created: ${sessions.length}');

    for (var session in sessions) {
      DateTime sessionStart = session.first.dateFrom;
      DateTime sessionEnd = session.last.dateTo;
      num totalCalories = session
          .map((e) => (e.value as WorkoutHealthValue).totalEnergyBurned)
          .where((value) => value != null)
          .fold(0, (prev, element) => prev + element!);

      double totalDistance = session
          .map((e) => (e.value as WorkoutHealthValue).totalDistance)
          .where((value) => value != null)
          .fold(0.0, (prev, element) => prev + element!);

      String workoutType = session.first.type.toString();

      aggregatedData[sessionStart] = {
        'calories': totalCalories,
        'startTime': sessionStart,
        'endTime': sessionEnd,
        'workoutType': workoutType,
        'totalDistance': totalDistance,
      };

      debugPrint('Session aggregated data: ${aggregatedData[sessionStart]}');
    }

    debugPrint('Aggregated data: $aggregatedData');

    return aggregatedData;
  }

  String getWorkoutDataType(WorkoutHealthValue workoutValue) {
    return workoutValue.workoutActivityType.toString();
  }

  double getTotalDistance(List<HealthDataPoint> session) {
    return session
        .map((e) => (e.value as WorkoutHealthValue).totalDistance)
        .where((value) => value != null)
        .fold(0.0, (prev, element) => prev + element!);
  }
}
