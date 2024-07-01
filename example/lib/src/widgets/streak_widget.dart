import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/steps_detail_view.dart';
import 'package:health_example/src/widgets/charts/circular_graph.dart';

class StreakWidget extends StatefulWidget {
  const StreakWidget({
    super.key,
    required this.weekDays,
    required this.height,
    required this.width,
  });

  final List<String> weekDays;
  final double height;
  final double width;

  @override
  _StreakWidgetState createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget> {
  final StepDataFetcher _stepDataFetcher = StepDataFetcher();
  bool _isLoading = true;
  List<Map<String, double>> _weeklyData = List.generate(7, (_) => {});

  @override
  void initState() {
    super.initState();
    _fetchWeeklyData();
  }

  Future<void> _fetchWeeklyData() async {
    DateTime now = DateTime.now();
    List<Map<String, double>> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      DateTime dayStart =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));

      List<double> stepsValues = await _stepDataFetcher.fetchStepsData(
          dayStart, dayEnd, Duration(days: 1));
      List<double> caloriesValues = await _stepDataFetcher.fetchCaloriesData(
          dayStart, dayEnd, Duration(days: 1));

      double totalSteps =
          stepsValues.isNotEmpty ? stepsValues.reduce((a, b) => a + b) : 0;
      double totalCalories = caloriesValues.isNotEmpty
          ? caloriesValues.reduce((a, b) => a + b)
          : 0;
      double totalDistance = totalSteps * 0.0008; // Example conversion factor

      weeklyData.add({
        'steps': totalSteps,
        'calories': totalCalories,
        'distance': totalDistance,
      });
    }

    setState(() {
      _isLoading = false;
      _weeklyData = weeklyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: widget.height,
        width: widget.width,
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: AppColors.menuBackground.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        Map<String, double> dayData = _weeklyData[index];
                        return Flexible(
                          child: Column(
                            children: [
                              MergedCircularGraphWidget(
                                values: {
                                  'steps': dayData['steps']! / 10000,
                                  'calories': dayData['calories']! / 800,
                                  'distance': dayData['distance']! / 8,
                                },
                                size: 50,
                                alternatePadding: true,
                                width: 4,
                              ),
                              Text(
                                widget.weekDays[index],
                                style: const TextStyle(
                                  color: AppColors.mainTextColor2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
