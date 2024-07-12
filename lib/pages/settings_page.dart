import 'package:flutter/material.dart';
import 'package:waterbottle/data/db.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ProfileData profileData = ProfileData();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    ProfileData data = await ProfileData.readProfileData();
    setState(() {
      profileData = data;
    });
  }

  void _updateProfileData() {
    setState(() {
      profileData.writeProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Weight (lbs)'),
            Slider(
              value: profileData.weight,
              min: 30.0,
              max: 300.0,
              divisions: 540,
              label: profileData.weight.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  profileData.weight = value;
                  _updateProfileData();
                });
              },
            ),
            Text(
              '${profileData.weight} lbs',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text('Hours of Exercise'),
            ...List.generate(7, (index) {
              return Row(
                children: [
                  Text(
                    style: const TextStyle(fontSize: 12),
                    _getDayOfWeek(index),
                  ),
                  Slider(
                    value: profileData.exerciseHours[index],
                    min: 0,
                    max: 10,
                    divisions: 20,
                    label: profileData.exerciseHours[index].toString(),
                    onChanged: (double value) {
                      setState(() {
                        profileData.exerciseHours[index] = value;
                        _updateProfileData();
                      });
                    },
                  ),
                  Text(
                    '${profileData.exerciseHours[index]} hours',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
            const SizedBox(height: 20),
            const Text('Your Goal Adjustment'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      profileData.manualAdjustment--;
                      _updateProfileData();
                    });
                  },
                ),
                Text(
                  '${profileData.manualAdjustment} oz',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      profileData.manualAdjustment++;
                      _updateProfileData();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDayOfWeek(int index) {
    switch (index) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return '';
    }
  }
}
