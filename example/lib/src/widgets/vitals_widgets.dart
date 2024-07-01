import 'package:flutter/material.dart';
import 'package:health_example/src/service/fetcher/fetcher.dart';
import 'package:health_example/src/utils/theme.dart';

class VitalsDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String description;

  const VitalsDetailCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.menuBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.mainTextColor2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 28,
                      color: AppColors.mainTextColor1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: unit,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mainTextColor2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.mainTextColor2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VitalsDetailGridBox extends StatefulWidget {
  const VitalsDetailGridBox({super.key});

  @override
  _VitalsDetailGridBoxState createState() => _VitalsDetailGridBoxState();
}

class _VitalsDetailGridBoxState extends State<VitalsDetailGridBox> {
  final BloodPressureFetcher _bpFetcher = BloodPressureFetcher();
  final HeartRateFetcher _hrFetcher = HeartRateFetcher();
  final StepDataFetcher _stepFetcher = StepDataFetcher();

  Future<Map<String, dynamic>> _fetchData() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay =
        startOfDay.add(Duration(days: 1)).subtract(Duration(seconds: 1));

    // Fetch systolic and diastolic blood pressure
    List<double> systolicValues =
        await _bpFetcher.fetchHourlySystolic(startOfDay, endOfDay);
    List<double> diastolicValues =
        await _bpFetcher.fetchHourlyDiastolic(startOfDay, endOfDay);

    // Fetch heart rate
    double latestHeartRate = await _hrFetcher.fetchLatestHeartRate();

    // Fetch steps and calories
    List<double> stepsValues = await _stepFetcher.fetchStepsData(
        startOfDay, endOfDay, Duration(hours: 1));
    List<double> caloriesValues = await _stepFetcher.fetchCaloriesData(
        startOfDay, endOfDay, Duration(hours: 1));

    return {
      'systolic': systolicValues.isNotEmpty
          ? systolicValues.last.toStringAsFixed(0)
          : '0.0',
      'diastolic': diastolicValues.isNotEmpty
          ? diastolicValues.last.toStringAsFixed(0)
          : '0.0',
      'heartRate': latestHeartRate.toStringAsFixed(0),
      'steps': stepsValues.isNotEmpty
          ? stepsValues.reduce((a, b) => a + b).toStringAsFixed(0)
          : '0',
      'calories': caloriesValues.isNotEmpty
          ? caloriesValues.reduce((a, b) => a + b).toStringAsFixed(0)
          : '0',
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        } else {
          var data = snapshot.data!;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Vitals",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.mainTextColor2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 24,
                    children: [
                      //TODO - Create the Sleep Detail Page
                      // VitalsDetailCard(
                      //   title: "Sleep",
                      //   value: "7h 4m",
                      //   unit: "",
                      //   description: "Slept at 00:06 AM",
                      // ),
                      VitalsDetailCard(
                        title: "Heart Rate",
                        value: data['heartRate'],
                        unit: " bpm",
                        description: "Last measured just now",
                      ),
                      VitalsDetailCard(
                        title: "Blood Pressure",
                        value: "${data['systolic']}/${data['diastolic']}",
                        unit: " mmHg",
                        description: "Last measured just now",
                      ),
                      VitalsDetailCard(
                        title: "Steps",
                        value: data['steps'],
                        unit: " steps",
                        description: "Last measured just now",
                      ),
                      VitalsDetailCard(
                        title: "Calories Burned",
                        value: data['calories'],
                        unit: " kcal",
                        description: "Last measured just now",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
