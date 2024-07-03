import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/view.dart';

class GoalWidget extends StatelessWidget {
  const GoalWidget(
      {super.key,
      required this.icon,
      required this.currentVal,
      required this.val,
      required this.color,
      required this.isDistance,
      required this.unit});
  final IconData icon;
  final double currentVal, val;
  final Color color;
  final bool isDistance;
  final String unit;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 32,
          color: color,
        ),
        Text(
          currentVal.toStringAsFixed(isDistance ? 2 : 0),
          style: TextStyle(
              fontSize: 24, color: color, fontWeight: FontWeight.bold),
        ),
        RichText(
          text: TextSpan(
            text: '/${val.toStringAsFixed(isDistance ? 1 : 0)}',
            children: [
              TextSpan(
                text: unit,
                style: TextStyle(color: color.withOpacity(0.5), fontSize: 14),
              ),
            ],
            style: TextStyle(
                fontSize: 20, color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class GoalGridBoxWidget extends StatelessWidget {
  const GoalGridBoxWidget({
    super.key,
    required double currentSteps,
    required double currentCalories,
    required double currentDistance,
    required double goalSteps,
    required double goalCalories,
    required double goalDistance,
  })  : _currentSteps = currentSteps,
        _currentCalories = currentCalories,
        _currentDistance = currentDistance,
        _goalSteps = goalSteps,
        _goalCalories = goalCalories,
        _goalDistance = goalDistance;

  final double _currentSteps;
  final double _currentCalories;
  final double _currentDistance;
  final double _goalSteps;
  final double _goalCalories;
  final double _goalDistance;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GoalDetailsScreen()));
      },
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        mainAxisSpacing: 20,
        crossAxisSpacing: 5,
        children: [
          GoalWidget(
            icon: FluentIcons.person_walking_16_filled,
            currentVal: _currentSteps,
            val: _goalSteps,
            color: AppColors.contentColorRed,
            isDistance: false,
            unit: ' steps',
          ),
          GoalWidget(
            icon: CupertinoIcons.bolt,
            currentVal: _currentCalories,
            val: _goalCalories,
            color: AppColors.contentColorOrange,
            isDistance: false,
            unit: ' cal',
          ),
          GoalWidget(
            icon: FluentIcons.location_48_filled,
            currentVal: _currentDistance,
            val: _goalDistance,
            color: AppColors.contentColorYellow,
            isDistance: true,
            unit: ' km',
          ),
        ],
      ),
    );
  }
}
