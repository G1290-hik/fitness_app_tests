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
    try {
      // Fetch latest systolic and diastolic blood pressure
      print('Fetching latest blood pressure data...');
      Map<String, dynamic> latestBpData =
          await _bpFetcher.fetchLatestBloodPressure();
      print('Blood pressure data fetched: $latestBpData');

      // Fetch latest heart rate data
      print('Fetching latest heart rate data...');
      Map<String, dynamic> latestHrData =
          await _hrFetcher.fetchLatestHeartRate();
      print('Heart rate data fetched: $latestHrData');

      return {
        'systolic': latestBpData['systolic'],
        'systolicTime': latestBpData['timestamp'],
        'diastolic': latestBpData['diastolic'],
        'diastolicTime': latestBpData['timestamp'],
        'heartRate': latestHrData['heartRate'],
        'heartRateTime': latestHrData['timestamp'],
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
                value:
                    '${data['systolic']?.toStringAsFixed(0) ?? '0'}/${data['diastolic']?.toStringAsFixed(0) ?? '0'}',
                unit: ' mmHg',
                description:
                    'Last measured: ${data['diastolicTime']?.toString() ?? 'N/A'}',
                screen: BloodPressureDetailScreen(),
              ),
              VitalsDetailCard(
                title: 'Heart Rate',
                value: '${data['heartRate']?.toStringAsFixed(0) ?? '0'}',
                unit: ' bpm',
                description:
                    'Last measured: ${data['heartRateTime']?.toString() ?? 'N/A'}',
                screen: HeartRateDetailScreen(),
              ),
            ],
          );
        }
      },
    );
  }
}
