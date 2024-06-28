import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/bmi_calculation_view.dart';
import 'package:health_example/src/widgets/widgets.dart';
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
                  Center(
                    child: MergedCircularGraphWidget(
                      alternatePadding: false,
                      values: {
                        'steps': 0.7,
                        'calories': 0.5,
                        'distance': 0.3,
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
                        currentVal: 3817,
                        val: 10000,
                        color: AppColors.contentColorRed,
                        isDistance: false,
                      ),
                      GoalWidget(
                        icon: Icons.bolt,
                        currentVal: 308,
                        val: 800,
                        color: AppColors.contentColorOrange,
                        isDistance: false,
                      ),
                      GoalWidget(
                        icon: Icons.data_exploration_outlined,
                        currentVal: 2.75,
                        val: 8.00,
                        color: AppColors.contentColorYellow,
                        isDistance: true,
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BmiCalculationView()),
                );
              },
              child: BMIWidget(
                height: constraints.maxHeight * 0.47,
              ),
            ),
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
