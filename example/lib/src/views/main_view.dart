import 'package:flutter/material.dart';
import 'package:health_example/src/service/fetcher/fetcher.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/widgets.dart';
import 'package:intl/intl.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final StepDataFetcher _stepDataFetcher = StepDataFetcher();
  late Future<void> _initialLoad;
  double _currentSteps = 0;
  double _currentCalories = 0;
  double _currentDistance = 0;

  @override
  void initState() {
    super.initState();
    _initialLoad = _fetchAllData();
  }

  Future<void> _fetchCurrentDayData() async {
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(now.year, now.month, now.day);
    DateTime endTime = now;

    List<double> stepsValues = await _stepDataFetcher.fetchStepsData(
        startTime, endTime, Duration(hours: 1));
    List<double> caloriesValues = await _stepDataFetcher.fetchCaloriesData(
        startTime, endTime, Duration(hours: 1));

    setState(() {
      _currentSteps = stepsValues.reduce((a, b) => a + b);
      _currentCalories = caloriesValues.reduce((a, b) => a + b);
      _currentDistance = _currentSteps * 0.0008; // Example conversion factor
    });
  }

  Future<void> _fetchVitalsData() async {
    // Simulate fetching data with a delay
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchCurrentDayData(),
      _fetchVitalsData(),
    ]);
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
              height: constraints.maxHeight * 0.4,
              child: VitalsDetailGridBox(),
            ),
          ),
          ActivityWidget(height: constraints.maxHeight*0.4,)
        ],
      );
    });
  }
}
