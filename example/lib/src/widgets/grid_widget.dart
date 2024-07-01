import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

class GridWidget extends StatelessWidget {
  const GridWidget({
    super.key,
    required this.dataItems,
  });

  final List<DataItem> dataItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 300,
      width: MediaQuery.sizeOf(context).width * 0.8,
      child: GridView.count(
        crossAxisCount: 2,
        children: dataItems.map((item) => _buildCard(item)).toList(),
      ),
    );
  }

  Widget _buildCard(DataItem item) {
    return Card(
      color: AppColors.itemsBackground,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title,
              style: TextStyle(color: AppColors.mainTextColor2),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: item.value?.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.mainTextColor1,
                ),
                children: [
                  TextSpan(
                    text: ' ${item.unit}',
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

class DataItem {
  final String title;
  final double? value;
  final String unit;

  DataItem({required this.title, required this.value, required this.unit});
}
