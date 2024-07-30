import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:waterbottle/data/db.dart';

class Logs {
  List<LogEntry> entries;

  Logs({required this.entries});

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }

  static Logs fromJson(Map<String, dynamic> json) {
    return Logs(
      entries: (json['entries'] as List)
          .map((entryJson) => LogEntry.fromJson(entryJson))
          .toList(),
    );
  }

  static Future<String> get _filePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/logs.json';
  }

  static Future<void> saveLogs(Logs logs) async {
    final file = File(await _filePath);
    await file.writeAsString(jsonEncode(logs.toJson()));
  }

  static Future<Logs?> loadLogs() async {
    try {
      final file = File(await _filePath);
      if (await file.exists()) {
        final jsonData = jsonDecode(await file.readAsString());
        return Logs.fromJson(jsonData);
      }
      return Logs(entries: []);
    } catch (e) {
      return Logs(entries: []);
    }
  }

  static Future<void> waterDrunk(double value) async {
    final consumptionData = await ConsumptionData.loadConsumptionData();
    if (consumptionData != null) {
      await ConsumptionData.updateConsumptionData(value);
    }
  }
}

class LogEntry {
  DateTime dateTime;
  double consumed;

  LogEntry(this.dateTime, this.consumed);

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'consumed': consumed,
    };
  }

  static LogEntry fromJson(Map<String, dynamic> json) {
    return LogEntry(
      DateTime.parse(json['dateTime']),
      json['consumed'],
    );
  }
}
