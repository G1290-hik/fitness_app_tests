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
            text: '/${val.toStringAsFixed(0)}' ,
            children: [
              TextSpan(
                text: unit,
                style: TextStyle(color: color.withOpacity(0.5),fontSize: 14),
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
  })  : _currentSteps = currentSteps,
        _currentCalories = currentCalories,
        _currentDistance = currentDistance;

  final double _currentSteps;
  final double _currentCalories;
  final double _currentDistance;

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
            icon: Icons.do_not_step_rounded,
            currentVal: _currentSteps,
            val: 10000,
            color: AppColors.contentColorRed,
            isDistance: false, unit: ' steps',
          ),
          GoalWidget(
            icon: CupertinoIcons.bolt,
            currentVal: _currentCalories,
            val: 5000,
            color: AppColors.contentColorOrange,
            isDistance: false, unit: ' cal',
          ),
          GoalWidget(
            icon: Icons.social_distance_sharp,
            currentVal: _currentDistance,
            val: 10.00,
            color: AppColors.contentColorYellow,
            isDistance: true, unit: ' km',
          ),
        ],
      ),
    );
  }
}
