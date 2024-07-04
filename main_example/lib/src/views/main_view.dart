import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/src/service/health_service.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/splash_screen.dart';
import 'package:health_example/src/views/write_ui/add_page.dart';
import 'package:health_example/src/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'read_ui/edit_goals_screen.dart';

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
  int _currentIndex = 0;

  Future<void> _fetchData() async {
    try {
      DateTime now = DateTime.now();
      DateTime startTime = DateTime(now.year, now.month, now.day, 0, 0, 1);
      DateTime endTime = now;

      double steps = await _healthService.getTotalSteps(startTime, endTime);
      double calories =
          await _healthService.getCaloriesBurnt(startTime, endTime);
      double distance = await _healthService.getDistance(startTime, endTime);

      double latestSystolicBP =
          await _healthService.getLatestSystolicBP(startTime, endTime);
      double latestDiastolicBP =
          await _healthService.getLatestDiastolicBP(startTime, endTime);
      double latestHr =
          await _healthService.getLatestHeartRate(startTime, endTime);
      double latestO2 =
          await _healthService.getLatestBloodOxygen(startTime, endTime);

      List<HealthDataPoint> sleepData =
          await _healthService.checkSleepData(startTime, endTime);
      double totalSleepDuration = sleepData.fold(
          0.0,
          (sum, data) =>
              sum + (data.value as NumericHealthValue).numericValue.toDouble());

      setState(() {
        _currentSteps = steps;
        _currentCalories = calories;
        _currentDistance = distance;
        _vitalsData = {
          'systolic': latestSystolicBP,
          'diastolic': latestDiastolicBP,
          'heartRate': latestHr,
          'sleepDuration': totalSleepDuration,
          'bloodoxygen': latestO2,
        };
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

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _refreshData() async {
    await _fetchData();
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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.contentColorOrange,
        unselectedItemColor: AppColors.contentColorWhite,
        backgroundColor: AppColors.menuBackground,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    List<String> weekDays = _getWeekDays();
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          backgroundColor: AppColors.itemsBackground,
          color: AppColors.contentColorOrange,
          onRefresh: _refreshData,
          child: _currentIndex == 0
              ? ListView(
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
                              Map<String, double>? newGoals =
                                  await Navigator.push(
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
                )
              : AddPage(),
        );
      },
    );
  }
}
