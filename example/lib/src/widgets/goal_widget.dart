import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/view.dart';

class GoalWidget extends StatelessWidget {
  const GoalWidget({
    super.key,
    required this.icon,
    required this.currentVal,
    required this.val,
    required this.color,
    required this.isDistance,
  });
  final IconData icon;
  final double currentVal, val;
  final Color color;
  final bool isDistance;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 36,
          color: color,
        ),
        Text(
          currentVal.toStringAsFixed(isDistance ? 2 : 0),
          style: TextStyle(
              fontSize: 24, color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          '/${val.toStringAsFixed(isDistance ? 1 : 0)}',
          style: TextStyle(color: AppColors.mainTextColor2, fontSize: 20),
        )
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
  }) : _currentSteps = currentSteps, _currentCalories = currentCalories, _currentDistance = currentDistance;

  final double _currentSteps;
  final double _currentCalories;
  final double _currentDistance;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StepDetailsScreen()));
      },
      child: GridView.count(
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
          ),
          GoalWidget(
            icon: CupertinoIcons.bolt,
            currentVal: _currentCalories,
            val: 5000,
            color: AppColors.contentColorOrange,
            isDistance: false,
          ),
          GoalWidget(
            icon: Icons.social_distance_sharp,
            currentVal: _currentDistance,
            val: 10.00,
            color: AppColors.contentColorYellow,
            isDistance: true,
          ),
        ],
      ),
    );
  }
}

