import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/alternate_circular_graph.dart';

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
                        AlternateCircularGraphWidget(),
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
