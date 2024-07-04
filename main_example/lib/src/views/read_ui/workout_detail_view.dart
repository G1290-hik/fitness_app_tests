import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> sessionData;

  WorkoutDetailsScreen({required this.sessionData});

  @override
  Widget build(BuildContext context) {
    String formattedStartTime =
        DateFormat('hh:mm a').format(sessionData['startTime']);
    String formattedEndTime =
        DateFormat('hh:mm a').format(sessionData['endTime']);
    num caloriesBurnt = sessionData['calories'];
    double totalDistance = sessionData['totalDistance'];
    String workoutType = sessionData['workoutType'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Workout Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Workout Type: $workoutType", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Start Time: $formattedStartTime",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("End Time: $formattedEndTime", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Calories Burnt: $caloriesBurnt kcal",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Total Distance: ${totalDistance.toStringAsFixed(2)} m",
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
