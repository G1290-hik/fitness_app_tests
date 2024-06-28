import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/charts/circular_graph.dart';

class StreakWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: height,
        width: width,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  return Flexible(
                    child: Column(
                      children: [
                        MergedCircularGraphWidget(
                          values: {
                            'steps': 0.7,
                            'calories': 0.5,
                            'distance': 0.3,
                          },
                          size: 50,
                          alternatePadding: true,width: 4,
                        ),
                        Text(
                          weekDays[index],
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
