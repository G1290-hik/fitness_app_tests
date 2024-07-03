import 'package:health/health.dart';
import 'package:health_example/src/service/health_service.dart';

class SleepFetcher {
  final HealthService _health = HealthService();

  Future<Map<String, dynamic>> fetchLatestSleep() async {
    DateTime endTime = DateTime.now();
    DateTime startTime = endTime.subtract(Duration(days: 1));

    List<HealthDataPoint> sleepData = await _health.checkSleepData(
      startTime,
      endTime,
    );

    if (sleepData.isNotEmpty) {
      HealthDataPoint latestSleep = sleepData.last;
      int sleepDurationMinutes = latestSleep.value as int;
      DateTime sleepTime = latestSleep.dateFrom;

      return {
        'sleepDuration': sleepDurationMinutes,
        'sleepTime': sleepTime,
      };
    } else {
      return {
        'sleepDuration': 0,
        'sleepTime': DateTime.now(),
      };
    }
  }
}
