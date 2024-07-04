import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/service/health_service.dart';

class AddBloodOxygenDataScreen extends StatefulWidget {
  @override
  _AddBloodOxygenDataScreenState createState() =>
      _AddBloodOxygenDataScreenState();
}

class _AddBloodOxygenDataScreenState extends State<AddBloodOxygenDataScreen> {
  final HealthService _healthService = HealthService();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _healthService.configureHealth();
  }

  void _addBloodOxygenMonthly() async {
    DateTime now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      DateTime endTime = now.subtract(Duration(days: i));
      DateTime startTime = endTime.subtract(
          Duration(hours: 1)); // Assuming measurement duration is 1 hour
      double bloodOxygenLevel = _random.nextDouble() * 5 +
          95; // Random blood oxygen level between 95 and 100
      await _healthService.addBloodOxygenData(
          startTime, endTime, bloodOxygenLevel);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Monthly blood oxygen data added successfully')),
    );
  }

  void _fetchBloodOxygenData() async {
    DateTime now = DateTime.now();
    DateTime startTime =
        now.subtract(Duration(days: 30)); // Example: last 30 days
    DateTime endTime = now;

    List<HealthDataPoint> bloodOxygenData =
        await _healthService.getBloodOxygen(startTime, endTime);
    bloodOxygenData.forEach((data) => print(data));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Fetched ${bloodOxygenData.length} blood oxygen data points')),
    );
  }

  void _deleteBloodOxygenData() async {
    DateTime now = DateTime.now();
    DateTime startTime =
        now.subtract(Duration(days: 30)); // Example: last 30 days
    DateTime endTime = now;

    await _healthService.deleteBloodOxygenData(startTime, endTime);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Blood oxygen data deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Blood Oxygen Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _addBloodOxygenMonthly,
              child: Text('Add Monthly Blood Oxygen Data'),
            ),
            ElevatedButton(
              onPressed: _fetchBloodOxygenData,
              child: Text('Fetch Blood Oxygen Data'),
            ),
            ElevatedButton(
              onPressed: _deleteBloodOxygenData,
              child: Text('Delete Blood Oxygen Data'),
            ),
          ],
        ),
      ),
    );
  }
}
