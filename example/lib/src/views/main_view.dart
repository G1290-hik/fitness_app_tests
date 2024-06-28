import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/bmi_indicator_widget.dart';
import 'package:health_example/src/widgets/streak_widget.dart';
import 'package:health_example/src/widgets/charts/circular_graph.dart';
//import 'package:health_example/src/widgets/vitals_widgets.dart';
import 'package:intl/intl.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

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
      body: LayoutBuilder(builder: (context, constraints) {
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
                  Center(child: MergedCircularGraphWidget(
                    alternatePadding: false,
                    values: {
                      'steps': 0.7,
                      'calories': 0.5,
                      'distance': 0.3,
                    },
                    size: 200,
                  ),),
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
                    children: const [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_border_purple500,
                            size: 36,
                            color: AppColors.contentColorRed,
                          ),
                          Text(
                            "1277",
                            style: TextStyle(
                                fontSize: 24,
                                color: AppColors.contentColorRed,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "/10000",
                            style: TextStyle(
                                color: AppColors.mainTextColor2, fontSize: 20),
                          )
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flip_camera_android,
                            size: 36,
                            color: AppColors.contentColorOrange,
                          ),
                          Text(
                            "138",
                            style: TextStyle(
                                fontSize: 24,
                                color: AppColors.contentColorOrange,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "/800",
                            style: TextStyle(
                                color: AppColors.mainTextColor2, fontSize: 20),
                          )
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.social_distance,
                            size: 36,
                            color: AppColors.contentColorYellow,
                          ),
                          Text(
                            "0.88",
                            style: TextStyle(
                                fontSize: 24,
                                color: AppColors.contentColorYellow,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "/8.0",
                            style: TextStyle(
                                color: AppColors.mainTextColor2, fontSize: 20),
                          )
                        ],
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
            BMIWidget(height: constraints.maxHeight * 0.4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                color: Colors.transparent,
                height: constraints.maxHeight * 0.6,
                // child: const VitalsDetailGridBox(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
