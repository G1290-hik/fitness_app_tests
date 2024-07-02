import 'package:flutter/material.dart';
import 'package:health_example/src/service/fetcher/fetcher.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/blood_pressure_details_view.dart';
import 'package:health_example/src/views/heart_rate_details_view.dart';

class VitalsDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String description;
  final Widget screen;

  const VitalsDetailCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> screen));
      },
      child: Card(
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
                        fontSize: 24,
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

  Future<Map<String, dynamic>> _fetchData() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1)).subtract(Duration(seconds: 1));

    try {
      // Fetch systolic and diastolic blood pressure with timestamps
      print('Fetching systolic blood pressure data...');
      List<Map<String, dynamic>> systolicValues = await _bpFetcher.fetchHourlySystolicWithTimestamps(startOfDay, endOfDay);
      print('Systolic data fetched: $systolicValues');

      print('Fetching diastolic blood pressure data...');
      List<Map<String, dynamic>> diastolicValues = await _bpFetcher.fetchHourlyDiastolicWithTimestamps(startOfDay, endOfDay);
      print('Diastolic data fetched: $diastolicValues');

      // Fetch heart rate with timestamp
      print('Fetching heart rate data...');
      var latestHeartRateData = await _hrFetcher.fetchLatestHeartRate();
      print('Heart rate data fetched: $latestHeartRateData');
      double latestHeartRate = latestHeartRateData['value'];
      DateTime latestHeartRateTime = latestHeartRateData['timestamp'];

      // Initialize to default values
      double lastNonZeroSystolic = 0.0;
      DateTime? lastSystolicTime;
      for (var data in systolicValues.reversed) {
        if (data['value'] > 0) {
          lastNonZeroSystolic = data['value'];
          lastSystolicTime = data['timestamp'];
          break;
        }
      }

      double lastNonZeroDiastolic = 0.0;
      DateTime? lastDiastolicTime;
      for (var data in diastolicValues.reversed) {
        if (data['value'] > 0) {
          lastNonZeroDiastolic = data['value'];
          lastDiastolicTime = data['timestamp'];
          break;
        }
      }

      return {
        'systolic': lastNonZeroSystolic > 0 ? lastNonZeroSystolic.toStringAsFixed(0) : 'N/A',
        'systolicTime': lastSystolicTime ?? 'N/A',
        'diastolic': lastNonZeroDiastolic > 0 ? lastNonZeroDiastolic.toStringAsFixed(0) : 'N/A',
        'diastolicTime': lastDiastolicTime ?? 'N/A',
        'heartRate': latestHeartRate > 0 ? latestHeartRate.toStringAsFixed(0) : 'N/A',
        'heartRateTime': latestHeartRate > 0 ? latestHeartRateTime : 'N/A',
      };
    } catch (e) {
      print('Error fetching data: $e');
      return {
        'systolic': 'N/A',
        'systolicTime': 'N/A',
        'diastolic': 'N/A',
        'diastolicTime': 'N/A',
        'heartRate': 'N/A',
        'heartRateTime': 'N/A',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Snapshot error: ${snapshot.error}');
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
                      VitalsDetailCard(
                        title: "Heart Rate",
                        value: data['heartRate'],
                        unit: " bpm",
                        description: data['heartRate'] != 'N/A'
                            ? "Last measured at ${data['heartRateTime'].hour}:${data['heartRateTime'].minute}"
                            : "N/A", screen: HeartRateDetailScreen(),
                      ),
                      VitalsDetailCard(
                        title: "Blood Pressure",
                        value: "${data['systolic']} / ${data['diastolic']}",
                        unit: " mmHg",
                        description: data['systolic'] != 'N/A' && data['diastolic'] != 'N/A'
                            ? "Last measured at ${data['systolicTime'].hour}:${data['systolicTime'].minute} and ${data['diastolicTime'].hour}:${data['diastolicTime'].minute}"
                            : "N/A", screen: BloodPressureDetailScreen(),
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
