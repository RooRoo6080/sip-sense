import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProfileData {
  double weight;
  List<double> exerciseHours;
  int manualAdjustment;

  ProfileData({
    this.weight = 70.0,
    this.exerciseHours = const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    this.manualAdjustment = 0,
  }) {
    exerciseHours = exerciseHours;
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'exerciseHours': exerciseHours,
      'manualAdjustment': manualAdjustment,
    };
  }

  static ProfileData fromJson(Map<String, dynamic> json) {
    return ProfileData(
      weight: json['weight'].toDouble(),
      exerciseHours:
          List<double>.from(json['exerciseHours'].map((x) => x.toDouble())),
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
