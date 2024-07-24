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
  late ConsumptionData _consumptionData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadConsumptionData();
  }

  Future<void> _loadConsumptionData() async {
    final data = await ConsumptionData.loadConsumptionData();
    setState(() {
      _consumptionData = data ??
          ConsumptionData(
            waterInBottle: _consumptionData.waterInBottle,
            bottleCapacity: _consumptionData.bottleCapacity,
            consumeGoal: 35,
          );
    });
  }

  Future<void> _updateConsumptionData() async {
    await ConsumptionData.saveConsumptionData(_consumptionData);
  }

  void _onConsumptionDataChanged(double weight, double adjustment) {
    setState(() {
      _consumptionData.consumeGoal = weight / 2 + adjustment;
    });
    _updateConsumptionData();
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
      _onConsumptionDataChanged(
          profileData.weight, profileData.manualAdjustment.toDouble());
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
}
