import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

class MinMaxGridWidget extends StatelessWidget {
  const MinMaxGridWidget({
    super.key,
    required this.showHeartRate,
    required double? maxHeartRate,
    required double? minHeartRate,
    required double? minSystolic,
    required double? minDiastolic,
    required double? maxDiastolic,
    required double? maxSystolic,
  })  : _maxHeartRate = maxHeartRate,
        _minHeartRate = minHeartRate,
        _minSystolic = minSystolic,
        _maxDiastolic = maxDiastolic,
        _maxSystolic = maxSystolic,
        _minDiastolic = minDiastolic;

  final bool showHeartRate;
  final double? _maxHeartRate;
  final double? _minHeartRate;
  final double? _minSystolic;
  final double? _minDiastolic;
  final double? _maxDiastolic;
  final double? _maxSystolic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 300,
      width: MediaQuery.sizeOf(context).width * 0.8,
      child: GridView.count(
        crossAxisCount: 2,
        children: showHeartRate
            ? [
                _buildCard("Max HR", _maxHeartRate, "bpm"),
                _buildCard("Min HR", _minHeartRate, "bpm"),
              ]
            : [
                _buildCard("Max Systolic BP", _maxSystolic, "mmHg"),
                _buildCard("Min Systolic BP", _minSystolic, "mmHg"),
                _buildCard("Max Diastolic BP", _maxDiastolic, "mmHg"),
                _buildCard("Min Diastolic BP", _minDiastolic, "mmHg"),
              ],
      ),
    );
  }

  Widget _buildCard(String title, double? value, String unit) {
    return Card(
      color: AppColors.itemsBackground,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(color: AppColors.mainTextColor2),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: value?.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.mainTextColor1,
                ),
                children: [
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mainTextColor2,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
