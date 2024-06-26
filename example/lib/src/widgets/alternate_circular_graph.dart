import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health_example/src/widgets/circular_graph.dart';
import 'package:health_example/src/widgets/theme.dart';

class AlternateCircularGraphWidget extends StatelessWidget {
  final List<CircularSegment> segments;

  AlternateCircularGraphWidget({
    super.key,
    this.size = 50,
  }) : segments = List.generate(3, (index) {
          final random = Random();
          return CircularSegment(
            color: _getColor(index),
            value: random.nextDouble(),
            strokeWidth: 15.0,
          );
        });

  final double size;

  static Color _getColor(int index) {
    switch (index) {
      case 0:
        return AppColors.contentColorRed;
      case 1:
        return AppColors.contentColorOrange;
      case 2:
      default:
        return AppColors.contentColorYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: segments
              .asMap()
              .map((index, segment) => MapEntry(
                    index,
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.all(10.0 + (5.0 * index)),
                        child: CircularProgressIndicator(
                          value: segment.value,
                          strokeWidth: segment.strokeWidth * (size / 200),
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
