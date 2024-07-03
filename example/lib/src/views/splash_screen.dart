import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.contentColorWhite,
        ),
      ),
    );
  }
}
