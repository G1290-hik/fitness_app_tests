import 'package:flutter/material.dart';
import 'package:health_example/src/utils/theme.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(
          'Add Screen',
          style: TextStyle(
              color: AppColors.mainTextColor1, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.pageBackground,
        centerTitle: true,
      ),
    );
  }
}
