import 'package:flutter/material.dart';
import 'package:health_example/src/service/fetcher/fetcher.dart';
import 'package:health_example/src/utils/theme.dart';
import 'package:health_example/src/views/view.dart';

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
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
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
                        fontSize: 12,
                        color: AppColors.mainTextColor2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 10,
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

      // Fetch heart rate data
      print('Fetching heart rate data...');
      Map<String, dynamic> heartRateData = await _hrFetcher.fetchHeartRateData(startOfDay);
      print('Heart rate data fetched: $heartRateData');

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

      // Get the last non-zero heart rate value and time
      List<double> heartRates = heartRateData['hourlyHeartRatesMax'] ?? [];
      List<DateTime> heartRateTimes = heartRateData['hourlyDates'] ?? [];

      double lastNonZeroHeartRate = 0.0;
      DateTime? lastNonZeroHeartRateTime;
      for (int i = heartRates.length - 1; i >= 0; i--) {
        if (heartRates[i] > 0) {
          lastNonZeroHeartRate = heartRates[i];
          lastNonZeroHeartRateTime = heartRateTimes[i];
          break;
        }
      }

      return {
        'systolic': lastNonZeroSystolic,
        'systolicTime': lastSystolicTime,
        'diastolic': lastNonZeroDiastolic,
        'diastolicTime': lastDiastolicTime,
        'heartRate': lastNonZeroHeartRate,
        'heartRateTime': lastNonZeroHeartRateTime,
      };
    } catch (e) {
      print('Error fetching data: $e');
      return {};
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
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data ?? {};
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            shrinkWrap: true,
            children: <Widget>[
              VitalsDetailCard(
                title: 'Blood Pressure',
                value: '${data['systolic']?.toStringAsFixed(0) ?? '0'}/${data['diastolic']?.toStringAsFixed(0) ?? '0'}',
                unit: ' mmHg',
                description: 'Last measured: ${data['systolicTime']?.toString() ?? 'N/A'}',
                screen: BloodPressureDetailScreen(),
              ),
              VitalsDetailCard(
                title: 'Heart Rate',
                value: '${data['heartRate']?.toStringAsFixed(0) ?? '0'}',
                unit: ' bpm',
                description: 'Last measured: ${data['heartRateTime']?.toString() ?? 'N/A'}',
                screen: HeartRateDetailScreen(),
              ),
            ],
          );
        }
      },
    );
  }
}
