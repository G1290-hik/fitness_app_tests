import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '', _steps = '0';
  int _dailySteps = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    requestPermissionAndInit();
    startDailyResetTimer();
  }

  Future<void> requestPermissionAndInit() async {
    var status = await Permission.activityRecognition.request();
    if (status == PermissionStatus.granted) {
      debugPrint("Permission granted");
      initPlatformState();
      await loadDailySteps();
    } else {
      debugPrint("Permission denied");
      setState(() {
        _steps = 'Permission Denied';
        _status = 'Permission Denied';
      });
    }
  }

  void onStepCount(StepCount event) {
    debugPrint("Step count event: $event");
    setState(() {
      _steps = event.steps.toString();
      calculateDailySteps(event.steps);
    });
  }

  void calculateDailySteps(int currentSteps) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int startSteps = prefs.getInt('startSteps') ?? currentSteps;
    setState(() {
      _dailySteps = currentSteps - startSteps;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    debugPrint("Pedestrian status event: $event");
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    debugPrint('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    debugPrint(_status);
  }

  void onStepCountError(error) {
    debugPrint('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  Future<void> loadDailySteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int startSteps = prefs.getInt('startSteps') ?? 0;
    int currentSteps = int.parse(_steps);
    setState(() {
      _dailySteps = currentSteps - startSteps;
    });
  }

  void startDailyResetTimer() {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
    Duration timeUntilMidnight = nextMidnight.difference(now);

    _timer = Timer(timeUntilMidnight, () {
      resetDailySteps();
      startDailyResetTimer(); // Schedule the next reset
    });
  }

  Future<void> resetDailySteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentSteps = int.parse(_steps);
    prefs.setInt('startSteps', currentSteps);
    setState(() {
      _dailySteps = 0;
    });
    debugPrint("Daily steps reset at midnight: $currentSteps");
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Building widget tree with steps: $_steps, daily steps: $_dailySteps and status: $_status");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pedometer Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Steps Taken Today',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _dailySteps.toString(),
                style: TextStyle(fontSize: 60),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              Text(
                'Pedestrian Status',
                style: TextStyle(fontSize: 30),
              ),
              Icon(
                _status == 'walking'
                    ? Icons.directions_walk
                    : _status == 'stopped'
                        ? Icons.accessibility_new
                        : Icons.error,
                size: 100,
              ),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? TextStyle(fontSize: 30)
                      : TextStyle(fontSize: 20, color: Colors.red),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
