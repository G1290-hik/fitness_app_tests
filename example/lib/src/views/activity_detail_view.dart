import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/service/activity_service.dart';

class ActivityHistoryScreen extends StatefulWidget {
  @override
  _ActivityHistoryScreenState createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final ActivityService _activityService = ActivityService();
  List<HealthDataPoint> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    await _activityService.configureHealth();
    bool authorized = await _activityService.authorize();
    if (authorized) {
      List<HealthDataPoint> activities =
          await _activityService.getActivityDataPoints();
      setState(() {
        _activities = activities;
      });
      // Debug print to show activities
      debugPrint(_activities.toString());
    }
  }

  String _getActivityType(HealthWorkoutActivityType type) {
    return type.toString().split('.').last.replaceAll('_', ' ');
  }

  String _getDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '$hours hours, $minutes minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Workouts")),
      body: _activities.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                HealthDataPoint dataPoint = _activities[index];
                if (dataPoint.value is WorkoutHealthValue) {
                  WorkoutHealthValue workoutValue =
                      dataPoint.value as WorkoutHealthValue;
                  final duration =
                      dataPoint.dateTo.difference(dataPoint.dateFrom);
                  return ListTile(
                    leading: Icon(Icons.fitness_center),
                    title: Text(
                        _getActivityType(workoutValue.workoutActivityType)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Calories Burnt: ${workoutValue.totalEnergyBurned} kcal"),
                        Text("Duration: ${_getDuration(duration)}"),
                        Text("Date: ${dataPoint.dateFrom}"),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
    );
  }
}
