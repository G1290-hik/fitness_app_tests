import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/charts/circular_graph.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class StreakDetailScreen extends StatefulWidget {
  final List<Map<String, double>> weeklyData;
  final List<String> weekDays;
  final double goalSteps;
  final double goalCalories;
  final double goalDistance;
  const StreakDetailScreen({
    super.key,
    required this.weeklyData,
    required this.weekDays,
    required this.goalSteps,
    required this.goalCalories,
    required this.goalDistance,
  });

  @override
  _StreakDetailScreenState createState() => _StreakDetailScreenState();
}

class _StreakDetailScreenState extends State<StreakDetailScreen> {
  Map<String, double>? selectedData;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedData = widget.weeklyData.last;
    selectedIndex = widget.weeklyData.length - 1;
  }

  void _onDayTapped(int index) {
    setState(() {
      selectedData = widget.weeklyData[index];
      selectedIndex = index;
    });
  }

  String getDateFromIndex(int index) {
    final now = DateTime.now();
    final day =
        now.subtract(Duration(days: widget.weeklyData.length - index - 1));
    return DateFormat('EEE, MMM d').format(day);
  }

  String getAchievedText(double achievedValue, double goalValue) {
    final percentage = achievedValue / goalValue * 100;
    return percentage > 100
        ? "Completed"
        : "${percentage.toStringAsFixed(2)}% ACHIEVED";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.contentColorWhite),
        backgroundColor: AppColors.pageBackground,
        title: const Text('Detail Screen',
            style: TextStyle(color: AppColors.mainTextColor1)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.weeklyData.length,
              itemBuilder: (context, index) {
                Map<String, double> dayData = widget.weeklyData[index];
                return GestureDetector(
                  onTap: () => _onDayTapped(index),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: index == selectedIndex
                            ? AppColors.mainTextColor1
                            : Colors.transparent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        MergedCircularGraphWidget(
                          values: {
                            'steps': dayData['steps']! / widget.goalSteps,
                            'calories':
                                dayData['calories']! / widget.goalCalories,
                            'distance':
                                dayData['distance']! / widget.goalDistance,
                          },
                          size: 50,
                          alternatePadding: true,
                          width: 4,
                        ),
                        Text(
                          getDateFromIndex(index),
                          style: const TextStyle(
                            color: AppColors.mainTextColor2,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 20, color: AppColors.mainTextColor1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedData != null) ...[
                    Text(
                      getDateFromIndex(selectedIndex),
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.mainTextColor1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MergedCircularGraphWidget(
                      values: {
                        'steps': selectedData!['steps']! / widget.goalSteps,
                        'calories':
                            selectedData!['calories']! / widget.goalCalories,
                        'distance':
                            selectedData!['distance']! / widget.goalDistance,
                      },
                      size: 200,
                      alternatePadding: false,
                      width: 20,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'STEPS',
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.mainTextColor1,
                      ),
                    ),
                    Text(
                      '${selectedData!['steps']?.toStringAsFixed(0)} / ${widget.goalSteps}',
                      style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.mainTextColor1,
                      ),
                    ),
                    Text(
                      getAchievedText(
                          selectedData!['steps']!, widget.goalSteps),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.mainTextColor2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CALORIES',
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.mainTextColor1,
                      ),
                    ),
                    Text(
                      '${selectedData!['calories']?.toStringAsFixed(0)} / ${widget.goalCalories}',
                      style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.mainTextColor1,
                      ),
                    ),
                    Text(
                      getAchievedText(
                          selectedData!['calories']!, widget.goalCalories),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.mainTextColor2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DISTANCE',
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.mainTextColor1,
                      ),
                    ),
                    Text(
                      '${selectedData!['distance']?.toStringAsFixed(2)} / ${widget.goalDistance}',
                      style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.mainTextColor1,
                      ),
                    ),
                    Text(
                      getAchievedText(
                          selectedData!['distance']!, widget.goalSteps),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.mainTextColor2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
