import 'package:flutter/material.dart';
import 'package:health_example/src/widgets/theme.dart';

class CircularSegment {
  final Color color;
  final double value;
  final double strokeWidth;

  CircularSegment({
    required this.color,
    required this.value,
    required this.strokeWidth,
  });
}

// ignore: must_be_immutable
class CircularGraphWidget extends StatelessWidget {
  final List<CircularSegment> segments = [
    CircularSegment(
        color: AppColors.contentColorRed,
        value: 0.7,
        strokeWidth: 20.0), //NOTE - For Steps
    CircularSegment(
        color: AppColors.contentColorOrange,
        value: 0.5,
        strokeWidth: 20.0), //NOTE - For Calories
    CircularSegment(
        color: AppColors.contentColorYellow,
        value: 0.3,
        strokeWidth: 20.0), //NOTE - For Distance
  ];

  CircularGraphWidget({
    super.key,
    this.width = 200,
    this.height = 200,
  });
  double height;
  double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          alignment: Alignment.center,
          children: segments
              .asMap()
              .map((index, segment) => MapEntry(
                    index,
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.all(28.0 * index),
                        child: CircularProgressIndicator(
                          value: segment.value,
                          strokeWidth: segment.strokeWidth,
                          color: segment.color,
                          backgroundColor: segment.color.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ))
              .values
              .toList(),
        ),
      ),
    );
  }
}
