import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/widgets/widgets.dart';

class BmiCalculationView extends StatelessWidget {
  const BmiCalculationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.contentColorWhite,
        ),
        backgroundColor: AppColors.pageBackground,
        title: Text(
          "BMI",
          style: TextStyle(color: AppColors.mainTextColor1),
        ),
      ),
      body: Column(
        children: [
          GaugeWidget(
            height: 450,
            size: false,
          ),
          Text(
            "NORMAL WEIGHT",
            style: TextStyle(
              color: AppColors.contentColorGreen,
              shadows: [
                Shadow(color: AppColors.contentColorGreen, blurRadius: 8),
                Shadow(color: AppColors.contentColorWhite, blurRadius: 3),
              ],
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          Text(
            "Ideal BMI: 23.0",
            style: TextStyle(
              color: AppColors.mainTextColor2,
              fontSize: 20,
            ),
          )
        ],
      ),
    );
  }
}
