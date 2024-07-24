import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:core';

class ProfileData {
  double weight;
  int manualAdjustment;

  ProfileData({
    this.weight = 70.0,
    this.manualAdjustment = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'manualAdjustment': manualAdjustment,
    };
  }

  static ProfileData fromJson(Map<String, dynamic> json) {
    return ProfileData(
      weight: json['weight'].toDouble(),
      manualAdjustment: json['manualAdjustment'],
    );
  }

  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/profile_data.json');
  }

  static Future<ProfileData> readProfileData() async {
    final file = await _getLocalFile();
    if (await file.exists()) {
      String contents = await file.readAsString();
      Map<String, dynamic> json = jsonDecode(contents);
      return ProfileData.fromJson(json);
    }
    return ProfileData();
  }

  Future<void> writeProfileData() async {
    final file = await _getLocalFile();
    String json = jsonEncode(toJson());
    await file.writeAsString(json);
  }
}

class ConsumptionData {
  double waterInBottle;
  double bottleCapacity;
  double consumedToday;
  double consumeGoal;
  String lastUpdated;

  ConsumptionData({
    required this.waterInBottle,
    required this.bottleCapacity,
    required this.consumedToday,
    required this.consumeGoal,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'waterInBottle': waterInBottle,
      'bottleCapacity': bottleCapacity,
      'consumedToday': consumedToday,
      'consumeGoal': consumeGoal,
      'lastUpdated': lastUpdated,
    };
  }

  static ConsumptionData fromJson(Map<String, dynamic> json) {
    return ConsumptionData(
      waterInBottle: json['waterInBottle'],
      bottleCapacity: json['bottleCapacity'],
      consumedToday: json['consumedToday'],
      consumeGoal: json['consumeGoal'],
      lastUpdated: json['lastUpdated'],
    );
  }

  static Future<String> get _filePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/consumption_data.json';
  }

  static Future<void> saveConsumptionData(ConsumptionData data) async {
    final file = File(await _filePath);
    await file.writeAsString(jsonEncode(data.toJson()));
  }

  static Future<ConsumptionData?> loadConsumptionData() async {
    try {
      final file = File(await _filePath);
      if (await file.exists()) {
        final jsonData = jsonDecode(await file.readAsString());
        return ConsumptionData.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/consumption_data.json';
      final file = File(filePath);
      final defaultData = ConsumptionData(
        waterInBottle: 24,
        bottleCapacity: 24,
        consumedToday: 0,
        consumeGoal: 35,
        lastUpdated: DateTime.now().toIso8601String(),
      );
      await file.writeAsString(jsonEncode(defaultData.toJson()));
      final jsonData = jsonDecode(await file.readAsString());
      return ConsumptionData.fromJson(jsonData);
    }
  }

  static Future<void> updateConsumptionData(double consumed) async {
    final data = await loadConsumptionData();
    var test = DateTime.parse(data!.lastUpdated);
    if (data != null) {
      final now = DateTime.now();
      if (now.day != test.day ||
          now.month != test.month ||
          now.year != test.year) {
        data.consumedToday = 0;
      }
      data.consumedToday += consumed;
      data.waterInBottle -= consumed;
      data.lastUpdated = now as String;
      await saveConsumptionData(data);
    }
  }

  static Future<void> initializeConsumptionData() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/consumption_data.json';
    final file = File(filePath);

    if (!(await file.exists())) {
      final defaultData = ConsumptionData(
        waterInBottle: 24,
        bottleCapacity: 24,
        consumedToday: 0,
        consumeGoal: 35,
        lastUpdated: DateTime.now().toIso8601String(),
      );
      await file.writeAsString(jsonEncode(defaultData.toJson()));
    }
  }
}
