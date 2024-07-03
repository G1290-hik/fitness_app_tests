import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:math';

import '../src/service/service.dart';

class AddSleepDataScreen extends StatefulWidget {
  @override
  _AddSleepDataScreenState createState() => _AddSleepDataScreenState();
}

class _AddSleepDataScreenState extends State<AddSleepDataScreen> {
  final HealthService _healthService = HealthService();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _healthService.configureHealth();
  }



  void _addSleepMonthly() async {
    DateTime now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      int sleepDuration = _random.nextInt(8) + 1; // Random sleep duration between 1 and 8 hours
      DateTime endTime = now.subtract(Duration(days: i));
      DateTime startTime = endTime.subtract(Duration(hours: sleepDuration));
      await _healthService.addSleepSession(startTime, endTime);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Monthly sleep data added successfully')),
    );
  }

  void _fetchSleepData() async {
    DateTime now = DateTime.now();
    DateTime startTime = now.subtract(Duration(days: 30)); // Example: last 30 days
    DateTime endTime = now;

    List<HealthDataPoint> sleepData = await _healthService.checkSleepData(startTime, endTime);
    sleepData.forEach((data) => print(data));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fetched ${sleepData.length} sleep data points')),
    );
  }

  void _deleteSleepData() async {
    DateTime now = DateTime.now();
    DateTime startTime = now.subtract(Duration(days: 30)); // Example: last 30 days
    DateTime endTime = now;

    await _healthService.deleteSleepData(startTime, endTime);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sleep data deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Sleep Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _addSleepMonthly,
              child: Text('Add Monthly Sleep Data'),
            ),
            ElevatedButton(
              onPressed: _fetchSleepData,
              child: Text('Fetch Sleep Data'),
            ),
            ElevatedButton(
              onPressed: _deleteSleepData,
              child: Text('Delete Sleep Data'),
            ),
          ],
        ),
      ),
    );
  }
}
