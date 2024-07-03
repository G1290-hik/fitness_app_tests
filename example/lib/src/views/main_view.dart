import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/service/health_service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/widgets.dart';
import 'package:intl/intl.dart';

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
  Map<String, dynamic> _vitalsData = {};

  @override
  void initState() {
    super.initState();
    _initialLoad = _fetchAllData();
  }

  Future<void> _fetchCurrentDayData() async {
    try {
      debugPrint('Fetching current day data...');
      DateTime now = DateTime.now();
      DateTime startTime = DateTime(now.year, now.month, now.day);
      DateTime endTime = now;

      _currentSteps = await _healthService.getTotalSteps(startTime, endTime);
      _currentCalories = await _healthService.getCaloriesBurnt(startTime, endTime);
      _currentDistance = await _healthService.getDistance(startTime, endTime);

      setState(() {});
      debugPrint('Current day data fetched: steps=$_currentSteps, calories=$_currentCalories, distance=$_currentDistance');
    } catch (e) {
      debugPrint('Error fetching current day data: $e');
    }
  }

  Future<void> _fetchVitalsData() async {
    try {
      debugPrint('Fetching latest blood pressure data...');
      DateTime now = DateTime.now();
      DateTime startTime = now.subtract(Duration(days: 1)); // Example duration
      DateTime endTime = now;

      Map<String, double> latestBpData = await _healthService.getLatestBloodPressure(startTime, endTime);
      debugPrint('Blood pressure data fetched: $latestBpData');

      debugPrint('Fetching latest heart rate data...');
      double latestHr = await _healthService.getLatestHeartRate(startTime, endTime);
      debugPrint('Heart rate data fetched: $latestHr');

      debugPrint('Fetching latest sleep data...');
      List<HealthDataPoint> sleepData = await _healthService.checkSleepData(startTime, endTime);
      double totalSleepDuration = sleepData.fold(0.0, (sum, data) => sum + (data.value as NumericHealthValue).numericValue.toDouble());
      debugPrint('Sleep data fetched: $totalSleepDuration');

      setState(() {
        _vitalsData = {
          'systolic': latestBpData['systolic'],
          'systolicTime': endTime,
          'diastolic': latestBpData['diastolic'],
          'diastolicTime': endTime,
          'heartRate': latestHr,
          'heartRateTime': endTime,
          'sleepDuration': totalSleepDuration,
          'sleepTime': endTime,
        };
      });
    } catch (e) {
      debugPrint('Error fetching vitals data: $e');
    }
  }

  Future<void> _fetchAllData() async {
    try {
      debugPrint('Fetching all data...');
      await Future.wait([
        _fetchCurrentDayData(),
        _fetchVitalsData(),
      ]);
      debugPrint('All data fetched successfully');
    } catch (e) {
      debugPrint('Error fetching all data: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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
                      'steps': _currentSteps / 10000,
                      'calories': _currentCalories / 5000,
                      'distance': _currentDistance / 10,
                    },
                    size: 200,
                  ),
                ),
                const Card(
                  color: AppColors.menuBackground,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Your Goals",
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.mainTextColor2,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GoalGridBoxWidget(
                  currentSteps: _currentSteps,
                  currentCalories: _currentCalories,
                  currentDistance: _currentDistance,
                ),
              ],
            ),
          ),
          StreakWidget(
            weekDays: weekDays,
            height: constraints.maxHeight * 0.2,
            width: constraints.maxWidth,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              color: Colors.transparent,
              height: constraints.maxHeight * 0.6,
              child: VitalsDetailGridBox(vitalsData: _vitalsData),
            ),
          ),
          ActivityWidget(height: constraints.maxHeight * 0.4),
        ],
      );
    });
  }
}
