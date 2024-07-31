import 'package:flutter/material.dart';
import 'package:waterbottle/data/db.dart';
import 'package:waterbottle/data/theme_data.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ProfileData? profileData;
  ConsumptionData? _consumptionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadProfileData(),
      _loadConsumptionData(),
    ]);
    if (profileData != null) {
      _onConsumptionDataChanged(profileData!.weight, profileData!.manualAdjustment.toDouble());
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadConsumptionData() async {
    final data = await ConsumptionData.loadConsumptionData();
    setState(() {
      _consumptionData = data ??
          ConsumptionData(
            waterInBottle: 24,
            bottleCapacity: 24,
            consumeGoal: 35,
          );
    });
  }

  Future<void> _updateConsumptionData() async {
    if (_consumptionData != null) {
      await ConsumptionData.saveConsumptionData(_consumptionData!);
    }
  }

  void _onConsumptionDataChanged(double weight, double adjustment) {
    if (_consumptionData != null) {
      setState(() {
        _consumptionData!.consumeGoal = weight / 2 + adjustment;
      });
      _updateConsumptionData();
    }
  }

  Future<void> _loadProfileData() async {
    final data = await ProfileData.readProfileData();
    setState(() {
      profileData = data ??
          ProfileData(
            weight: 70.0,
            manualAdjustment: 0,
            drinkEvery: 1,
          );
    });
  }

  void _updateProfileData() {
    if (profileData != null) {
      setState(() {
        profileData!.writeProfileData();
        _onConsumptionDataChanged(profileData!.weight, profileData!.manualAdjustment.toDouble());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    child: Column(
                      children: [
                        const Text('Weight (lbs)'),
                        Slider(
                          value: profileData!.weight,
                          min: 30.0,
                          max: 300.0,
                          divisions: 540,
                          label: profileData!.weight.toStringAsFixed(1),
                          onChanged: (double value) {
                            setState(() {
                              profileData!.weight = value;
                              _updateProfileData();
                            });
                          },
                        ),
                        Text(
                          '${profileData!.weight} lbs',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 40),
                        const Text('Your Goal Adjustment'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  profileData!.manualAdjustment--;
                                  _updateProfileData();
                                });
                              },
                            ),
                            Text(
                              '${profileData!.manualAdjustment} oz',
                              style: const TextStyle(fontSize: 18),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  profileData!.manualAdjustment++;
                                  _updateProfileData();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    child: Column(
                      children: [
                        const Text('Remind me to drink if I haven\'t for...'),
                        Slider(
                          value: profileData!.drinkEvery,
                          min: 0.25,
                          max: 6.0,
                          divisions: 23,
                          label: profileData!.drinkEvery.toStringAsFixed(2),
                          onChanged: (double value) {
                            setState(() {
                              profileData!.drinkEvery = value;
                              _updateProfileData();
                            });
                          },
                        ),
                        Text(
                          '${profileData!.drinkEvery.toStringAsFixed(2)} hours',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_consumptionData != null) ...[
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      child: Column(
                        children: [
                          const Text('Bottle capacity'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    _consumptionData!.bottleCapacity--;
                                    _updateConsumptionData();
                                  });
                                },
                              ),
                              Text(
                                '${_consumptionData!.bottleCapacity} oz',
                                style: const TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _consumptionData!.bottleCapacity++;
                                    _updateConsumptionData();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Divider(),
                  const SizedBox(height: 10),
                  Consumer<ThemeNotifier>(
                    builder: (context, themeNotifier, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Light  "),
                          Switch(
                            value: themeNotifier.isDarkTheme,
                            onChanged: (value) {
                              themeNotifier.toggleTheme();
                            },
                          ),
                          const Text("  Dark"),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
