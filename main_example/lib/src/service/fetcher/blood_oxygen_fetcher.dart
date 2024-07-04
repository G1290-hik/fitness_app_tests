import 'package:health_example/src/service/health_service.dart';

class BloodOxygenFetcher {
  final HealthService _healthService = HealthService();

  Future<Map<String, dynamic>> fetchBloodOxygenData(DateTime startDate) async {
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
      futures7Days.add(_fetchDailyBloodOxygen(dayStart, dayEnd));
    }

    // Prepare 30 days of data requests
    for (int i = 0; i < 30; i++) {
      DateTime dayStart = startTime30Days.add(Duration(days: i));
      DateTime dayEnd = dayStart.add(Duration(days: 1));
      futures30Days.add(_fetchDailyBloodOxygen(dayStart, dayEnd));
    }

    // Prepare 1 day of data (hourly) requests
    DateTime now = DateTime.now();
    for (int i = 0; i <= now.hour; i++) {
      DateTime hourStart = startTime1Day.add(Duration(hours: i));
      DateTime hourEnd = hourStart.add(Duration(hours: 1));
      futures1Day.add(fetchHourlyBloodOxygen(hourStart, hourEnd));
    }

    // Await for all results
    List<Map<String, double>> results7Days = await Future.wait(futures7Days);
    List<Map<String, double>> results30Days = await Future.wait(futures30Days);
    List<Map<String, double>> results1Day = await Future.wait(futures1Day);

    // Process results
    List<double> minBloodOxygen7Days = [];
    List<double> maxBloodOxygen7Days = [];
    List<DateTime> dates7Days = [];
    double overallMinBloodOxygen = double.infinity;
    double overallMaxBloodOxygen = double.negativeInfinity;

    for (int i = 0; i < 7; i++) {
      var result = results7Days[i];
      double minBloodOxygen = result['min']!;
      double maxBloodOxygen = result['max']!;
      DateTime dayStart = startTime7Days.add(Duration(days: i));

      minBloodOxygen7Days.add(minBloodOxygen > 0 ? minBloodOxygen : 0);
      maxBloodOxygen7Days.add(maxBloodOxygen > 0 ? maxBloodOxygen : 0);
      dates7Days.add(dayStart);

      if (minBloodOxygen > 0 && minBloodOxygen < overallMinBloodOxygen) {
        overallMinBloodOxygen = minBloodOxygen;
      }
      if (maxBloodOxygen > 0 && maxBloodOxygen > overallMaxBloodOxygen) {
        overallMaxBloodOxygen = maxBloodOxygen;
      }
    }

    List<double> minBloodOxygen30Days = [];
    List<double> maxBloodOxygen30Days = [];
    List<DateTime> dates30Days = [];

    for (int i = 0; i < 30; i++) {
      var result = results30Days[i];
      double minBloodOxygen = result['min']!;
      double maxBloodOxygen = result['max']!;
      DateTime dayStart = startTime30Days.add(Duration(days: i));

      minBloodOxygen30Days.add(minBloodOxygen > 0 ? minBloodOxygen : 0);
      maxBloodOxygen30Days.add(maxBloodOxygen > 0 ? maxBloodOxygen : 0);
      dates30Days.add(dayStart);

      if (minBloodOxygen > 0 && minBloodOxygen < overallMinBloodOxygen) {
        overallMinBloodOxygen = minBloodOxygen;
      }
      if (maxBloodOxygen > 0 && maxBloodOxygen > overallMaxBloodOxygen) {
        overallMaxBloodOxygen = maxBloodOxygen;
      }
    }

    List<double> hourlyBloodOxygenMin = [];
    List<double> hourlyBloodOxygenMax = [];
    List<DateTime> hourlyDates = [];

    for (int i = 0; i <= now.hour; i++) {
      var result = results1Day[i];
      double minBloodOxygen = result['min']!;
      double maxBloodOxygen = result['max']!;
      DateTime hourStart = startTime1Day.add(Duration(hours: i));

      hourlyBloodOxygenMin.add(minBloodOxygen > 0 ? minBloodOxygen : 0);
      hourlyBloodOxygenMax.add(maxBloodOxygen > 0 ? maxBloodOxygen : 0);
      hourlyDates.add(hourStart);
    }

    // Get the latest blood oxygen value and timestamp
    double latestBloodOxygen =
        hourlyBloodOxygenMax.isNotEmpty ? hourlyBloodOxygenMax.last : 0;
    DateTime? latestBloodOxygenTime =
        hourlyDates.isNotEmpty ? hourlyDates.last : null;

    return {
      'minBloodOxygen7Days': minBloodOxygen7Days,
      'maxBloodOxygen7Days': maxBloodOxygen7Days,
      'dates7Days': dates7Days,
      'minBloodOxygen30Days': minBloodOxygen30Days,
      'maxBloodOxygen30Days': maxBloodOxygen30Days,
      'dates30Days': dates30Days,
      'hourlyBloodOxygenMin': hourlyBloodOxygenMin,
      'hourlyBloodOxygenMax': hourlyBloodOxygenMax,
      'hourlyDates': hourlyDates,
      'overallMinBloodOxygen': overallMinBloodOxygen,
      'overallMaxBloodOxygen': overallMaxBloodOxygen,
      'latestBloodOxygen': latestBloodOxygen,
      'latestBloodOxygenTime': latestBloodOxygenTime,
    };
  }

  Future<Map<String, double>> _fetchDailyBloodOxygen(
      DateTime dayStart, DateTime dayEnd) async {
    double minBloodOxygen =
        await _healthService.getMinBloodOxygen(dayStart, dayEnd);
    double maxBloodOxygen =
        await _healthService.getMaxBloodOxygen(dayStart, dayEnd);
    return {'min': minBloodOxygen, 'max': maxBloodOxygen};
  }

  Future<Map<String, double>> fetchHourlyBloodOxygen(
      DateTime hourStart, DateTime hourEnd) async {
    double minBloodOxygen =
        await _healthService.getMinBloodOxygen(hourStart, hourEnd);
    double maxBloodOxygen =
        await _healthService.getMaxBloodOxygen(hourStart, hourEnd);
    return {'min': minBloodOxygen, 'max': maxBloodOxygen};
  }

  Future<Map<String, dynamic>> fetchLatestBloodOxygen() async {
    try {
      DateTime endTime = DateTime.now();
      DateTime startTime = endTime.subtract(Duration(days: 1));
      double latestBloodOxygen =
          await _healthService.getLatestBloodOxygen(startTime, endTime);
      return {
        'bloodOxygen': latestBloodOxygen,
        'timestamp': endTime,
      };
    } catch (e) {
      print('Error fetching latest blood oxygen: $e');
      return {
        'bloodOxygen': 0.0,
        'timestamp': DateTime.now(),
      };
    }
  }
}
