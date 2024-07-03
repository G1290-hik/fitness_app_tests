import 'package:flutter/material.dart';
import 'package:health_example/src/views/sleep_details_screen.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/view.dart';

class VitalsDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Widget screen;

  const VitalsDetailCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Card(
        color: AppColors.menuBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize:18,
                  color: AppColors.mainTextColor2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppColors.mainTextColor1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: unit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mainTextColor2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VitalsDetailGridBox extends StatelessWidget {
  final Map<String, dynamic> vitalsData;

  const VitalsDetailGridBox({super.key, required this.vitalsData});

  @override
  Widget build(BuildContext context) {
    final double sleepDuration = vitalsData['sleepDuration'] ?? 0;
    final int hours = sleepDuration ~/ 60;
    final double minutes = sleepDuration % 60;


    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 4.0,
      mainAxisSpacing: 4.0,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        VitalsDetailCard(
          title: 'Blood Pressure',
          value:
          '${vitalsData['systolic']?.toStringAsFixed(0) ?? '0'} / ${vitalsData['diastolic']?.toStringAsFixed(0) ?? '0'}',
          unit: ' mmHg',
          screen: BloodPressureDetailScreen(),
        ),
        VitalsDetailCard(
          title: 'Heart Rate',
          value: '${vitalsData['heartRate']?.toStringAsFixed(0) ?? '0'}',
          unit: ' bpm',
          screen: HeartRateDetailScreen(),
        ),
        VitalsDetailCard(
          title: 'Sleep',
          value: '${hours.toStringAsFixed(0)}h ${minutes.toStringAsFixed(0)}m',
          unit: '',
          screen: SleepDetailScreen(), // Add a screen for detailed sleep view
        ),
      ],
    );
  }
}
