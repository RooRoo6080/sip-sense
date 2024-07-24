import 'package:waterbottle/data/db.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:waterbottle/data/logs.dart';

class DisplayData {
  static Future<Map<String, dynamic>> displayData() async {
    final consumptionData = await ConsumptionData.loadConsumptionData();
    final Map<String, dynamic> data = {};

    if (consumptionData != null) {
      data['consumedToday'] = consumptionData.consumedToday;
      data['consumeGoal'] = consumptionData.consumeGoal;
      data['waterInBottle'] = consumptionData.waterInBottle;
      data['bottleCapacity'] = consumptionData.bottleCapacity;
      data['lastUpdated'] = DateTime.now().toIso8601String();
    }

    final logs = await Logs.loadLogs();
    if (logs != null) {
      final Map<String, double> weeklyConsumption = {
        'sunday': 0,
        'monday': 0,
        'tuesday': 0,
        'wednesday': 0,
        'thursday': 0,
        'friday': 0,
        'saturday': 0,
      };

      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      for (final entry in logs.entries) {
        final entryDay =
            DateFormat('EEEE').format(entry.dateTime).toLowerCase();
        if (entry.dateTime.isAfter(startOfWeek) &&
                entry.dateTime.isBefore(endOfWeek) ||
            entry.dateTime.isAtSameMomentAs(now)) {
          weeklyConsumption[entryDay] =
              (weeklyConsumption[entryDay] ?? 0) + entry.consumed;
        }
      }

      data.addAll({
        'sundayConsumed': weeklyConsumption['sunday'] ?? 0,
        'mondayConsumed': weeklyConsumption['monday'] ?? 0,
        'tuesdayConsumed': weeklyConsumption['tuesday'] ?? 0,
        'wednesdayConsumed': weeklyConsumption['wednesday'] ?? 0,
        'thursdayConsumed': weeklyConsumption['thursday'] ?? 0,
        'fridayConsumed': weeklyConsumption['friday'] ?? 0,
        'saturdayConsumed': weeklyConsumption['saturday'] ?? 0,
      });
    }

    return data;
  }

  static Future<List<ChartData>> dayChartData() async {
    final logs = await Logs.loadLogs();
    final goal =
        (await ConsumptionData.loadConsumptionData())?.consumeGoal ?? 0.0;
    final Map<int, double> hourlyConsumption = {};
    final now = DateTime.now();

    if (logs != null) {
      for (var entry in logs.entries) {
        if (entry.dateTime.year == now.year &&
            entry.dateTime.month == now.month &&
            entry.dateTime.day == now.day) {
          final hour = entry.dateTime.hour;
          hourlyConsumption[hour] =
              (hourlyConsumption[hour] ?? 0) + entry.consumed;
        }
      }
    }

    double cumulativeConsumed = 0.0;
    final List<ChartData> chartData = List.generate(24, (index) {
      final hour = index;
      cumulativeConsumed += hourlyConsumption[hour] ?? 0.0;
      final goalProgress = (hour >= 7 && hour <= 23)
          ? goal * (hour - 7) / (23 - 7)
          : (hour > 23 ? goal : 0.0);

      return ChartData(
        '${hour % 12 == 0 ? 12 : hour % 12}${hour < 12 ? 'am' : 'pm'}',
        cumulativeConsumed,
        goalProgress,
      );
    });

    return chartData;
  }

  static Future<List<ChartData>> weekChartData() async {
    final logs = await Logs.loadLogs();
    final goal =
        (await ConsumptionData.loadConsumptionData())?.consumeGoal ?? 0.0;
    final Map<String, double> weeklyConsumption = {
      'Sun.': 0.0,
      'Mon.': 0.0,
      'Tue.': 0.0,
      'Wed.': 0.0,
      'Thu.': 0.0,
      'Fri.': 0.0,
      'Sat.': 0.0,
    };

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    if (logs != null) {
      for (var entry in logs.entries) {
        if (entry.dateTime.isAfter(startOfWeek) &&
            entry.dateTime.isBefore(endOfWeek)) {
          final day = entry.dateTime.weekday;
          switch (day) {
            case DateTime.sunday:
              weeklyConsumption['Sun.'] =
                  (weeklyConsumption['Sun.'] ?? 0) + entry.consumed;
              break;
            case DateTime.monday:
              weeklyConsumption['Mon.'] =
                  (weeklyConsumption['Mon.'] ?? 0) + entry.consumed;
              break;
            case DateTime.tuesday:
              weeklyConsumption['Tue.'] =
                  (weeklyConsumption['Tue.'] ?? 0) + entry.consumed;
              break;
            case DateTime.wednesday:
              weeklyConsumption['Wed.'] =
                  (weeklyConsumption['Wed.'] ?? 0) + entry.consumed;
              break;
            case DateTime.thursday:
              weeklyConsumption['Thu.'] =
                  (weeklyConsumption['Thu.'] ?? 0) + entry.consumed;
              break;
            case DateTime.friday:
              weeklyConsumption['Fri.'] =
                  (weeklyConsumption['Fri.'] ?? 0) + entry.consumed;
              break;
            case DateTime.saturday:
              weeklyConsumption['Sat.'] =
                  (weeklyConsumption['Sat.'] ?? 0) + entry.consumed;
              break;
          }
        }
      }
    }

    final List<ChartData> chartData = [
      ChartData('Sun.', weeklyConsumption['Sun.'] ?? 0.0, goal),
      ChartData('Mon.', weeklyConsumption['Mon.'] ?? 0.0, goal),
      ChartData('Tue.', weeklyConsumption['Tue.'] ?? 0.0, goal),
      ChartData('Wed.', weeklyConsumption['Wed.'] ?? 0.0, goal),
      ChartData('Thu.', weeklyConsumption['Thu.'] ?? 0.0, goal),
      ChartData('Fri.', weeklyConsumption['Fri.'] ?? 0.0, goal),
      ChartData('Sat.', weeklyConsumption['Sat.'] ?? 0.0, goal),
    ];

    return chartData;
  }

  static Future<List<ChartData>> monthChartData() async {
    final logs = await Logs.loadLogs();
    final goal =
        (await ConsumptionData.loadConsumptionData())?.consumeGoal ?? 0.0;
    final Map<int, double> monthlyConsumption = {};
    final now = DateTime.now();

    if (logs != null) {
      for (var entry in logs.entries) {
        if (entry.dateTime.month == now.month &&
            entry.dateTime.year == now.year) {
          final day = entry.dateTime.day;
          monthlyConsumption[day] =
              (monthlyConsumption[day] ?? 0) + entry.consumed;
        }
      }
    }

    final List<ChartData> chartData = List.generate(31, (index) {
      final day = index + 1;
      return ChartData(
        day.toString(),
        day <= now.day ? (monthlyConsumption[day] ?? 0.0) : null,
        goal,
      );
    });

    return chartData;
  }

  static Future<List<ChartData>> yearChartData() async {
    final logs = await Logs.loadLogs();
    final goal =
        (await ConsumptionData.loadConsumptionData())?.consumeGoal ?? 0.0;
    final Map<int, double> yearlyConsumption = {};
    final now = DateTime.now();

    if (logs != null) {
      for (var entry in logs.entries) {
        if (entry.dateTime.year == now.year) {
          final month = entry.dateTime.month;
          yearlyConsumption[month] =
              (yearlyConsumption[month] ?? 0) + entry.consumed;
        }
      }
    }

    final List<ChartData> chartData = List.generate(12, (index) {
      final month = index + 1;
      return ChartData(
        _getMonthName(month),
        month <= now.month ? (yearlyConsumption[month] ?? 0.0) : null,
        goal * _getDaysInMonth(month, now.year),
      );
    });

    return chartData;
  }

  static String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  static int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  static Future<List<ChartData>> allTimeChartData() async {
    final logs = await Logs.loadLogs();
    final goal =
        (await ConsumptionData.loadConsumptionData())?.consumeGoal ?? 0.0;
    final Map<int, double> yearlyConsumption = {};

    if (logs != null) {
      for (var entry in logs.entries) {
        final year = entry.dateTime.year;
        yearlyConsumption[year] =
            (yearlyConsumption[year] ?? 0) + entry.consumed;
      }
    }

    final List<ChartData> chartData = yearlyConsumption.entries.map((entry) {
      final daysInYear = _daysInYear(entry.key);
      return ChartData(
        entry.key.toString(),
        entry.value,
        goal * daysInYear,
      );
    }).toList();

    return chartData;
  }

  static int _daysInYear(int year) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    return end.difference(start).inDays;
  }

  static Future<List<ChartData>> whenDrinkWaterAverage() async {
    final logs = await Logs.loadLogs();
    final goal =
        (await ConsumptionData.loadConsumptionData())?.consumeGoal ?? 0.0;
    final Map<int, double> hourlyConsumption = {};
    final Map<int, int> hourlyCount = {};

    if (logs != null) {
      for (var entry in logs.entries) {
        final hour = entry.dateTime.hour;
        hourlyConsumption[hour] =
            (hourlyConsumption[hour] ?? 0) + entry.consumed;
        hourlyCount[hour] = (hourlyCount[hour] ?? 0) + 1;
      }
    }

    final List<ChartData> chartData = List.generate(24, (hour) {
      final consumption = hourlyConsumption[hour] ?? 0;
      final count = hourlyCount[hour] ?? 1;
      final averageConsumption = consumption / count;
      return ChartData(
        '$hour:00',
        averageConsumption,
        goal / 24,
      );
    });

    return chartData;
  }
}

class ChartData {
  ChartData(this.x, this.y, this.y2);
  final String x;
  final double? y;
  final double? y2;
}
