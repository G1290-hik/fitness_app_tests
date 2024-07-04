import 'package:health_example/src/service/health_service.dart';

class HeartRateFetcher {
  final HealthService _healthService = HealthService();

  Future<Map<String, dynamic>> fetchHeartRateData(DateTime startDate) async {
    DateTime startTime7Days = startDate;
    DateTime startTime30Days = DateTime.now().subtract(Duration(days: 29));
    DateTime startTime1Day = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day); // Midnight of the current day

    List<Future<Map<String, double>>> futures7Days = [];
    List<Future<Map<String, double>>> futures30Days = [];
    List<Future<Map<String, double>>> futures1Day = [];

    // Prepare 7 days of data requests
    for (int i = 0; i < 7; i++) {
      DateTime dayStart = startTime7Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));
      futures7Days.add(_fetchDailyHeartRate(dayStart, dayEnd));
    }

    // Prepare 30 days of data requests
    for (int i = 0; i < 30; i++) {
      DateTime dayStart = startTime30Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));
      futures30Days.add(_fetchDailyHeartRate(dayStart, dayEnd));
    }

    // Prepare 1 day of data (hourly) requests
    DateTime now = DateTime.now();
    for (int i = 0; i <= now.hour; i++) {
      DateTime hourStart = startTime1Day.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));
      futures1Day.add(fetchHourlyHeartRate(hourStart, hourEnd));
    }

    // Await for all results
    List<Map<String, double>> results7Days = await Future.wait(futures7Days);
    List<Map<String, double>> results30Days = await Future.wait(futures30Days);
    List<Map<String, double>> results1Day = await Future.wait(futures1Day);

    // Process results
    List<double> minHeartRates7Days = [];
    List<double> maxHeartRates7Days = [];
    List<DateTime> dates7Days = [];
    double overallMinHeartRate = double.infinity;
    double overallMaxHeartRate = double.negativeInfinity;

    for (int i = 0; i < 7; i++) {
      var result = results7Days[i];
      double minHeartRate = result['min']!;
      double maxHeartRate = result['max']!;
      DateTime dayStart = startTime7Days.add(Duration(days: i));

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

    List<double> minHeartRates30Days = [];
    List<double> maxHeartRates30Days = [];
    List<DateTime> dates30Days = [];

    for (int i = 0; i < 30; i++) {
      var result = results30Days[i];
      double minHeartRate = result['min']!;
      double maxHeartRate = result['max']!;
      DateTime dayStart = startTime30Days.add(Duration(days: i));

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

    List<double> hourlyHeartRatesMin = [];
    List<double> hourlyHeartRatesMax = [];
    List<DateTime> hourlyDates = [];

    for (int i = 0; i <= now.hour; i++) {
      var result = results1Day[i];
      double minHeartRate = result['min']!;
      double maxHeartRate = result['max']!;
      DateTime hourStart = startTime1Day.add(Duration(hours: i));

      hourlyHeartRatesMin.add(minHeartRate > 0 ? minHeartRate : 0);
      hourlyHeartRatesMax.add(maxHeartRate > 0 ? maxHeartRate : 0);
      hourlyDates.add(hourStart);
    }

    // Get the latest heart rate value and timestamp
    double latestHeartRate =
        hourlyHeartRatesMax.isNotEmpty ? hourlyHeartRatesMax.last : 0;
    DateTime? latestHeartRateTime =
        hourlyDates.isNotEmpty ? hourlyDates.last : null;

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
      'latestHeartRate': latestHeartRate,
      'latestHeartRateTime': latestHeartRateTime,
    };
  }

  Future<Map<String, double>> _fetchDailyHeartRate(
      DateTime dayStart, DateTime dayEnd) async {
    double minHeartRate =
        await _healthService.getMinHeartRate(dayStart, dayEnd);
    double maxHeartRate =
        await _healthService.getMaxHeartRate(dayStart, dayEnd);
    return {'min': minHeartRate, 'max': maxHeartRate};
  }

  Future<Map<String, double>> fetchHourlyHeartRate(
      DateTime hourStart, DateTime hourEnd) async {
    double minHeartRate =
        await _healthService.getMinHeartRate(hourStart, hourEnd);
    double maxHeartRate =
        await _healthService.getMaxHeartRate(hourStart, hourEnd);
    return {'min': minHeartRate, 'max': maxHeartRate};
  }

  Future<Map<String, dynamic>> fetchLatestHeartRate() async {
    try {
      DateTime endTime = DateTime.now();
      DateTime startTime = endTime.subtract(Duration(days: 1));
      double latestHeartRate =
          await _healthService.getLatestHeartRate(startTime, endTime);
      return {
        'heartRate': latestHeartRate,
        'timestamp': endTime,
      };
    } catch (e) {
      print('Error fetching latest heart rate: $e');
      return {
        'heartRate': 0.0,
        'timestamp': DateTime.now(),
      };
    }
  }
}
