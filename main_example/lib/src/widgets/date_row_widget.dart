import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

class DateRow extends StatelessWidget {
  final String dateRange;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final double fontSize;

  const DateRow({
    super.key,
    required this.dateRange,
    required this.onPrevious,
    required this.onNext,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_sharp,
              color: AppColors.contentColorWhite,
            ),
            onPressed: onPrevious,
          ),
          Text(
            dateRange,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.contentColorWhite,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_sharp,
              color: AppColors.contentColorWhite,
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
