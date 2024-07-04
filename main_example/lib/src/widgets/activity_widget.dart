
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/view.dart';

class ActivityWidget extends StatelessWidget {
  const ActivityWidget({
    super.key,
    required this.height,
  });
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityHistoryScreen(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(          color: AppColors.contentColorWhite.withOpacity(0.2),borderRadius: BorderRadius.circular(8)),

          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Show All Workout Details",
                style: TextStyle(color: AppColors.mainTextColor1),
              ),
              Icon(CupertinoIcons.forward,color: AppColors.contentColorWhite,)
            ],
          ),
        ),
      ),
    );
  }
}
