import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/service/health_service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/splash_screen.dart';
import 'package:health_example/src/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_goals_screen.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final HealthService _healthService = HealthService();

  late Future<void> _initialLoad;
  double _currentSteps = 0;
  double _currentCalories = 0;
  double _currentDistance = 0;
  double _goalSteps = 10000;
  double _goalCalories = 5000;
  double _goalDistance = 10;
  Map<String, dynamic> _vitalsData = {};

  Future<void> _fetchData() async {
    try {
      DateTime now = DateTime.now();
      DateTime startTime = DateTime(now.year, now.month, now.day, 0, 0,
          1); // Start of the current day at 00:00:01
      DateTime endTime = now;

      debugPrint('Fetching current day data...');
      double steps = await _healthService.getTotalSteps(startTime, endTime);
      double calories =
          await _healthService.getCaloriesBurnt(startTime, endTime);
      double distance = await _healthService.getDistance(startTime, endTime);
      debugPrint(
          'Current day data fetched: steps=$steps, calories=$calories, distance=$distance');

      debugPrint('Fetching latest systolic blood pressure data...');
      double latestSystolicBP =
          await _healthService.getLatestSystolicBP(startTime, endTime);
      debugPrint('Systolic blood pressure data fetched: $latestSystolicBP');

      debugPrint('Fetching latest diastolic blood pressure data...');
      double latestDiastolicBP =
          await _healthService.getLatestDiastolicBP(startTime, endTime);
      debugPrint('Diastolic blood pressure data fetched: $latestDiastolicBP');

      debugPrint('Fetching latest heart rate data...');
      double latestHr =
          await _healthService.getLatestHeartRate(startTime, endTime);
      debugPrint('Heart rate data fetched: $latestHr');

      debugPrint('Fetching latest blood oxygen data...');
      double latestO2 =
          await _healthService.getLatestBloodOxygen(startTime, endTime);
      debugPrint('Blood Oxygen data fetched: $latestO2');

      debugPrint('Fetching latest sleep data...');
      List<HealthDataPoint> sleepData =
          await _healthService.checkSleepData(startTime, endTime);
      double totalSleepDuration = sleepData.fold(
          0.0,
          (sum, data) =>
              sum + (data.value as NumericHealthValue).numericValue.toDouble());
      if (totalSleepDuration > 0) {
        debugPrint('Sleep data fetched: $totalSleepDuration');
      } else {
        debugPrint('No sleep data found in the last days.');
      }

      setState(() {
        _currentSteps = steps;
        _currentCalories = calories;
        _currentDistance = distance;
        _vitalsData = {
          'systolic': latestSystolicBP,
          'systolicTime': endTime,
          'diastolic': latestDiastolicBP,
          'diastolicTime': endTime,
          'heartRate': latestHr,
          'heartRateTime': endTime,
          'sleepDuration': totalSleepDuration,
          'sleepTime': endTime,
          'bloodoxygen': latestO2,
          'bloodoxygenTime': endTime,
        };
        debugPrint(
            'Data fetched, steps=$steps, calories=$calories, distance=$distance, systolicBP=$latestSystolicBP, diastolicBP=$latestDiastolicBP, heartRate=$latestHr, sleep=$totalSleepDuration');
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _initialLoad = _fetchData();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _goalSteps = prefs.getDouble('goalSteps') ?? 10000;
      _goalCalories = prefs.getDouble('goalCalories') ?? 5000;
      _goalDistance = prefs.getDouble('goalDistance') ?? 10;
    });
  }

  List<String> _getWeekDays() {
    List<String> weekDays = [];
    DateTime now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      weekDays.add(DateFormat('EEE').format(day));
    }
    return weekDays;
  }

  void _editGoals(Map<String, double> newGoals) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _goalSteps = newGoals['walkSteps']!;
      _goalCalories = newGoals['burnKcals']!;
      _goalDistance = newGoals['coverDistance']!;
    });
    await prefs.setDouble('goalSteps', _goalSteps);
    await prefs.setDouble('goalCalories', _goalCalories);
    await prefs.setDouble('goalDistance', _goalDistance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else {
            return _buildContent(context);
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    List<String> weekDays = _getWeekDays();
    return LayoutBuilder(builder: (context, constraints) {
      return ListView(
        children: [
          Container(
            color: Colors.transparent,
            height: constraints.maxHeight * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "Today's Summary",
                  style: TextStyle(
                    color: AppColors.mainTextColor1,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                Center(
                  child: MergedCircularGraphWidget(
                    alternatePadding: false,
                    values: {
                      'steps': _currentSteps / _goalSteps,
                      'calories': _currentCalories / _goalCalories,
                      'distance': _currentDistance / _goalDistance,
                    },
                    size: 200,
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Map<String, double>? newGoals = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditGoalsScreen(
                          initialWalkSteps: _goalSteps,
                          initialBurnKcals: _goalCalories,
                          initialCoverDistance: _goalDistance,
                        ),
                      ),
                    );
                    if (newGoals != null) {
                      _editGoals(newGoals);
                    }
                  },
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: AppColors.menuBackground,
                  child: Text(
                    "Edit Your Goals",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mainTextColor2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GoalGridBoxWidget(
                  currentSteps: _currentSteps,
                  goalSteps: _goalSteps,
                  currentCalories: _currentCalories,
                  goalCalories: _goalCalories,
                  currentDistance: _currentDistance,
                  goalDistance: _goalDistance,
                ),
              ],
            ),
          ),
          StreakWidget(
            weekDays: weekDays,
            height: constraints.maxHeight * 0.2,
            width: constraints.maxWidth,
            goalDistance: _goalDistance,
            goalCalories: _goalCalories,
            goalSteps: _goalSteps,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              color: Colors.transparent,
              height: constraints.maxHeight * 0.55,
              child: VitalsDetailGridBox(vitalsData: _vitalsData),
            ),
          ),
          ActivityWidget(height: constraints.maxHeight * 0.1),
        ],
      );
    });
  }
}
