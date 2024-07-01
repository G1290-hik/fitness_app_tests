import 'package:flutter/material.dart';
import 'package:health_example/src/service/activity_service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:intl/intl.dart';

import 'workout_detail_view.dart';

class ActivityHistoryScreen extends StatefulWidget {
  @override
  _ActivityHistoryScreenState createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final ActivityService _activityService = ActivityService();
  Map<DateTime, Map<String, dynamic>> _aggregatedData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });

    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 730));

    debugPrint('Fetching data from $startDate to $endDate');

    Map<DateTime, Map<String, dynamic>> aggregatedData =
        await _activityService.aggregateDataByTimeFrame(
      startDate,
      endDate,
    );

    setState(() {
      _aggregatedData = aggregatedData;
      _isLoading = false;
    });

    debugPrint('Aggregated data in state: $_aggregatedData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(
          "Workouts",
          style: TextStyle(color: AppColors.mainTextColor1),
        ),
        backgroundColor: AppColors.pageBackground,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _aggregatedData.isEmpty
              ? Center(child: Text("No data available."))
              : ListView.builder(
                  itemCount: _aggregatedData.length,
                  itemBuilder: (context, index) {
                    DateTime date = _aggregatedData.keys.elementAt(index);
                    Map<String, dynamic> sessionData = _aggregatedData[date]!;
                    String formattedDate =
                        DateFormat('dd-MM-yyyy').format(date);
                    String formattedStartTime =
                        DateFormat('hh:mm a').format(sessionData['startTime']);
                    String formattedEndTime =
                        DateFormat('hh:mm a').format(sessionData['endTime']);
                    num caloriesBurnt = sessionData['calories'];
                    double totalDistance = sessionData['totalDistance'];
                    String workoutType = sessionData['workoutType'];

                    debugPrint(
                        'Displaying session data: $formattedDate, $formattedStartTime, $formattedEndTime, $caloriesBurnt, $totalDistance');

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutDetailsScreen(
                              sessionData: sessionData,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.directions_walk,
                          color: AppColors.contentColorGreen,
                        ),
                        title: Text(
                          "Date: $formattedDate",
                          style: TextStyle(
                              fontSize: 14, color: AppColors.mainTextColor1),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Start Time: $formattedStartTime",
                              style: TextStyle(color: AppColors.mainTextColor2),
                            ),
                            Text(
                              "End Time: $formattedEndTime",
                              style: TextStyle(color: AppColors.mainTextColor2),
                            ),
                            Text(
                              "Calories Burnt: $caloriesBurnt kcal",
                              style: TextStyle(color: AppColors.mainTextColor2),
                            ),
                            Text(
                              "Total Distance: ${totalDistance.toStringAsFixed(2)}m",
                              style: TextStyle(color: AppColors.mainTextColor2),
                            ),
                            Text(
                              "Workout Type: $workoutType",
                              style: TextStyle(color: AppColors.mainTextColor2),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
