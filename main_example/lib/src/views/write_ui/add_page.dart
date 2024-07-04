import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/write_ui/health_add_page.dart';
import 'package:health_example/src/views/write_ui/workout_add_page.dart';

class AddPage extends StatelessWidget {
  const AddPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutAddPage(),
                ),
              );
            },
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.5,
              color: AppColors.contentColorWhite,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    FluentIcons.person_walking_24_regular,
                    size: 96,
                    color: AppColors.itemsBackground,
                  ),
                  Text(
                    "Workout",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.contentColorBlack,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthAddPage(),
                ),
              );
            },
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.5,
              color: AppColors.pageBackground,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    FluentIcons.heart_48_regular,
                    size: 96,
                    color: AppColors.contentColorWhite,
                  ),
                  Text(
                    "Health",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.mainTextColor1,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
