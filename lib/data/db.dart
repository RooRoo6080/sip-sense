import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
  double waterInBottle = 24;
  double bottleCapacity = 24;
  double consumedToday = 0;
  double consumeGoal = 35;

  ConsumptionData({
    required this.waterInBottle,
    required this.bottleCapacity,
    required this.consumedToday,
    required this.consumeGoal,
  });

  Map<String, dynamic> toJson() {
    return {
      'waterInBottle': waterInBottle,
      'bottleCapacity': bottleCapacity,
      'consumedToday': consumedToday,
      'consumeGoal': consumeGoal,
    };
  }

  static ConsumptionData fromJson(Map<String, dynamic> json) {
    return ConsumptionData(
      waterInBottle: json['waterInBottle'],
      bottleCapacity: json['bottleCapacity'],
      consumedToday: json['consumedToday'],
      consumeGoal: json['consumeGoal'],
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
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
