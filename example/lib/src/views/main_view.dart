import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/view.dart';
import 'package:health_example/src/widgets/widgets.dart';
import 'package:intl/intl.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final StepDataFetcher _stepDataFetcher = StepDataFetcher();
  bool _isLoading = true;
  double _currentSteps = 0;
  double _currentCalories = 0;
  double _currentDistance = 0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentDayData();
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
      _isLoading = false;
      _currentSteps = stepsValues.reduce((a, b) => a + b);
      _currentCalories = caloriesValues.reduce((a, b) => a + b);
      _currentDistance = _currentSteps * 0.0008; // Example conversion factor
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

  @override
  Widget build(BuildContext context) {
    List<String> weekDays = _getWeekDays();
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: (context, constraints) {
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
                              'calories': _currentCalories / 800,
                              'distance': _currentDistance / 8,
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
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          children: [
                            GoalWidget(
                              icon: Icons.do_not_step_rounded,
                              currentVal: _currentSteps,
                              val: 10000,
                              color: AppColors.contentColorRed,
                              isDistance: false,
                              screen: StepDetailsScreen(),
                            ),
                            GoalWidget(
                              icon: CupertinoIcons.bolt,
                              currentVal: _currentCalories,
                              val: 800,
                              color: AppColors.contentColorOrange,
                              isDistance: false,
                              screen: StepDetailsScreen(),
                            ),
                            GoalWidget(
                              icon: Icons.social_distance_sharp,
                              currentVal: _currentDistance,
                              val: 8.00,
                              color: AppColors.contentColorYellow,
                              isDistance: true,
                              screen: StepDetailsScreen(),
                            ),
                          ],
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
                      child: VitalsDetailGridBox(),
                    ),
                  ),
                ],
              );
            }),
    );
  }
}
