import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

class MinMaxGridWidget extends StatelessWidget {
  const MinMaxGridWidget({
    super.key,
    required double maxHeartRate,
    required double minHeartRate,
  })  : _maxHeartRate = maxHeartRate,
        _minHeartRate = minHeartRate;

  final double _maxHeartRate;
  final double _minHeartRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(8),
      height: 230,
      width: MediaQuery.sizeOf(context).width * 0.8,
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          Card(
            color: AppColors.itemsBackground,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Max HR.",
                    style: TextStyle(color: AppColors.mainTextColor2),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_maxHeartRate.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.mainTextColor1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: AppColors.itemsBackground,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Min HR.",
                    style: TextStyle(color: AppColors.mainTextColor2),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_minHeartRate.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.mainTextColor1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
