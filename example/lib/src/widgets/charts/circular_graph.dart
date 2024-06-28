import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

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

class MergedCircularGraphWidget extends StatelessWidget {
  final List<CircularSegment> segments;
  final double size;
  final bool alternatePadding;
  final double width;

  MergedCircularGraphWidget({
    super.key,
    required Map<String, double> values,
    this.size = 200,
    this.alternatePadding = false,
    this.width=15,
  }) : segments = values.entries.map((entry) {
    return CircularSegment(
      color: _getColor(entry.key),
      value: entry.value,
      strokeWidth: width,
    );
  }).toList();

  static Color _getColor(String key) {
    switch (key) {
      case 'steps':
        return AppColors.contentColorRed;
      case 'calories':
        return AppColors.contentColorOrange;
      case 'distance':
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
                padding: alternatePadding
                    ? EdgeInsets.all(8.0 + (6.0 * index))
                    :EdgeInsets.all(28.0 * index)
                ,
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
