import 'package:health/health.dart';
import 'package:health_example/src/service/health_service.dart';

class HeartRateFetcher {
  final HealthService _healthService = HealthService();

  Future<Map<String, dynamic>> fetchHeartRateData(DateTime startDate) async {
    DateTime startTime7Days = startDate;
    DateTime startTime30Days = DateTime.now().subtract(Duration(days: 29));
    DateTime startTime1Day = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day); // Midnight of the current day

    List<double> minHeartRates7Days = [];
    List<double> maxHeartRates7Days = [];
    List<DateTime> dates7Days = [];

    List<double> minHeartRates30Days = [];
    List<double> maxHeartRates30Days = [];
    List<DateTime> dates30Days = [];

    List<double> hourlyHeartRatesMin = [];
    List<double> hourlyHeartRatesMax = [];
    List<DateTime> hourlyDates = [];

    double overallMinHeartRate = double.infinity;
    double overallMaxHeartRate = double.negativeInfinity;

    // Fetch 7 days of data
    for (int i = 0; i < 7; i++) {
      DateTime dayStart = startTime7Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));

      double minHeartRate =
      await _healthService.getMinHeartRate(dayStart, dayEnd);
      double maxHeartRate =
      await _healthService.getMaxHeartRate(dayStart, dayEnd);

      minHeartRates7Days.add(minHeartRate > 0 ? minHeartRate : 0);
      maxHeartRates7Days.add(maxHeartRate > 0 ? maxHeartRate : 0);
      dates7Days.add(dayStart);

      if (minHeartRate > 0 && minHeartRate < overallMinHeartRate) {
        overallMinHeartRate = minHeartRate;
      }
      if (maxHeartRate > 0 && maxHeartRate > overallMaxHeartRate) {
        overallMaxHeartRate = maxHeartRate;
      }
    }

    // Fetch 30 days of data
    for (int i = 0; i < 30; i++) {
      DateTime dayStart = startTime30Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));

      double minHeartRate =
      await _healthService.getMinHeartRate(dayStart, dayEnd);
      double maxHeartRate =
      await _healthService.getMaxHeartRate(dayStart, dayEnd);

      minHeartRates30Days.add(minHeartRate > 0 ? minHeartRate : 0);
      maxHeartRates30Days.add(maxHeartRate > 0 ? maxHeartRate : 0);
      dates30Days.add(dayStart);

      if (minHeartRate > 0 && minHeartRate < overallMinHeartRate) {
        overallMinHeartRate = minHeartRate;
      }
      if (maxHeartRate > 0 && maxHeartRate > overallMaxHeartRate) {
        overallMaxHeartRate = maxHeartRate;
      }
    }

    // Fetch 1 day of data (hourly)
    DateTime now = DateTime.now();
    for (int i = 0; i <= now.hour; i++) {
      // Loop until the current hour
      DateTime hourStart = startTime1Day.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));

      double minHeartRate =
      await _healthService.getMinHeartRate(hourStart, hourEnd);
      double maxHeartRate =
      await _healthService.getMaxHeartRate(hourStart, hourEnd);

      hourlyHeartRatesMin.add(minHeartRate > 0 ? minHeartRate : 0);
      hourlyHeartRatesMax.add(maxHeartRate > 0 ? maxHeartRate : 0);
      hourlyDates.add(hourStart);
    }

    return {
      'minHeartRates7Days': minHeartRates7Days,
      'maxHeartRates7Days': maxHeartRates7Days,
      'dates7Days': dates7Days,
      'minHeartRates30Days': minHeartRates30Days,
      'maxHeartRates30Days': maxHeartRates30Days,
      'dates30Days': dates30Days,
      'hourlyHeartRatesMin': hourlyHeartRatesMin,
      'hourlyHeartRatesMax': hourlyHeartRatesMax,
      'hourlyDates': hourlyDates,
      'overallMinHeartRate': overallMinHeartRate,
      'overallMaxHeartRate': overallMaxHeartRate,
    };
  }

  Future<Map<String, dynamic>> fetchLatestHeartRate() async {
    DateTime now = DateTime.now();
    DateTime oneHourAgo = now.subtract(Duration(hours: 1));
    List<HealthDataPoint> heartRateData =
    await _healthService.getHeartRate(oneHourAgo, now);

    if (heartRateData.isNotEmpty) {
      final latestHeartRatePoint = heartRateData.last;
      if (latestHeartRatePoint.value is NumericHealthValue) {
        double latestHeartRate = (latestHeartRatePoint.value as NumericHealthValue)
            .numericValue
            .toDouble();
        DateTime timestamp = latestHeartRatePoint.dateTo;
        return {
          'heartRate': latestHeartRate,
          'timestamp': timestamp,
        };
      } else {
        throw TypeError();
      }
    } else {
      print("No heart rate data available");
      return {
        'heartRate': 0.0,
        'timestamp': DateTime.now(),
      };
    }
  }
}
