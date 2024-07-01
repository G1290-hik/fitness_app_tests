import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

class GoalWidget extends StatelessWidget {
  const GoalWidget({
    super.key,
    required this.icon,
    required this.currentVal,
    required this.val,
    required this.color,
    required this.isDistance,
    required this.screen,
  });
  final IconData icon;
  final double currentVal, val;
  final Color color;
  final bool isDistance;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Column(
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
      ),
    );
  }
}
