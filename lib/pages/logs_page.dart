import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:waterbottle/data/logs.dart';
import 'package:waterbottle/data/db.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({Key? key}) : super(key: key);

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late Future<String> _logsFuture;
  late Future<Logs?> _logsFormattedFuture;
  final TextEditingController _formattedController = TextEditingController();
  final TextEditingController _rawController = TextEditingController();
  bool _isRaw = false;

  late Future<ProfileData> _profileDataFuture;
  late Future<ConsumptionData?> _consumptionDataFuture;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _manualAdjustmentController =
      TextEditingController();
  final TextEditingController _waterInBottleController =
      TextEditingController();
  final TextEditingController _bottleCapacityController =
      TextEditingController();
  final TextEditingController _consumedTodayController =
      TextEditingController();
  final TextEditingController _consumeGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _logsFuture = _loadLogs();
    _logsFormattedFuture = Logs.loadLogs();
    _profileDataFuture = ProfileData.readProfileData();
    _consumptionDataFuture = ConsumptionData.loadConsumptionData();
  }

  Future<void> _saveProfileData() async {
    final profileData = ProfileData(
      weight: double.parse(_weightController.text),
      manualAdjustment: int.parse(_manualAdjustmentController.text),
    );
    await profileData.writeProfileData();
  }

  Future<void> _saveConsumptionData() async {
    final consumptionData = ConsumptionData(
      waterInBottle: double.parse(_waterInBottleController.text),
      bottleCapacity: double.parse(_bottleCapacityController.text),
      consumedToday: double.parse(_consumedTodayController.text),
      consumeGoal: double.parse(_consumeGoalController.text),
    );
    await ConsumptionData.saveConsumptionData(consumptionData);
  }

  Future<String> _loadLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/logs.json';
      final file = File(filePath);
      if (await file.exists()) {
        final rawContent = await file.readAsString();
        final jsonData = jsonDecode(rawContent);
        _formattedController.text =
            const JsonEncoder.withIndent('  ').convert(jsonData);
        _rawController.text = rawContent;
        return rawContent;
      }
      return jsonEncode(Logs(entries: []).toJson());
    } catch (e) {
      return 'Error loading logs: $e';
    }
  }

  Future<void> _saveLogs() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/logs.json';
    final file = File(filePath);
    if (_isRaw) {
      await file.writeAsString(_rawController.text);
    } else {
      await file.writeAsString(_formattedController.text);
    }
  }

  Future<void> _addLogEntry(double consumed) async {
    final logs = await Logs.loadLogs() ?? Logs(entries: []);
    final newEntry = LogEntry(DateTime.now(), consumed);
    logs.entries.add(newEntry);
    await Logs.saveLogs(logs);
    _refreshLogs();
  }

  Future<void> _refreshLogs() async {
    setState(() {
      _logsFuture = _loadLogs();
      _logsFormattedFuture = Logs.loadLogs();
    });
  }

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double newValue = 0.0;
        return AlertDialog(
          title: const Text('Add Log Entry'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: newValue,
                    min: 0,
                    max: 24,
                    divisions: 48,
                    label: newValue.toStringAsFixed(1),
                    onChanged: (double value) {
                      setState(() {
                        newValue = value;
                      });
                    },
                  ),
                  Text(newValue.toStringAsFixed(1)),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addLogEntry(double.parse(newValue.toStringAsFixed(1)));
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          IconButton(
            icon: Icon(_isRaw ? Icons.format_list_bulleted : Icons.code),
            onPressed: () {
              setState(() {
                _isRaw = !_isRaw;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Existing FutureBuilder for Logs
            FutureBuilder<Logs?>(
              future: _logsFormattedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data!.entries.isEmpty) {
                  return const Center(child: Text('No logs available'));
                } else {
                  final logs = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: _refreshLogs,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: logs.entries.length,
                      itemBuilder: (context, index) {
                        final entry = logs.entries[index];
                        return ListTile(
                          title: Text(
                            'Date: ${entry.dateTime}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            'Consumed: ${entry.consumed.toStringAsFixed(1)} oz',
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () {},
                        );
                      },
                    ),
                  );
                }
              },
            ),
            FutureBuilder<ProfileData>(
              future: _profileDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final profileData = snapshot.data!;
                  _weightController.text = profileData.weight.toString();
                  _manualAdjustmentController.text =
                      profileData.manualAdjustment.toString();
                  return Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _weightController,
                          decoration:
                              const InputDecoration(labelText: 'Weight'),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: _manualAdjustmentController,
                          decoration: const InputDecoration(
                              labelText: 'Manual Adjustment'),
                          keyboardType: TextInputType.number,
                        ),
                        ElevatedButton(
                          onPressed: _saveProfileData,
                          child: const Text('Save Profile Data'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text('No profile data available'));
                }
              },
            ),
            // FutureBuilder for ConsumptionData
            FutureBuilder<ConsumptionData?>(
              future: _consumptionDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final consumptionData = snapshot.data!;
                  _waterInBottleController.text =
                      consumptionData.waterInBottle.toString();
                  _bottleCapacityController.text =
                      consumptionData.bottleCapacity.toString();
                  _consumedTodayController.text =
                      consumptionData.consumedToday.toString();
                  _consumeGoalController.text =
                      consumptionData.consumeGoal.toString();
                  return Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _waterInBottleController,
                          decoration: const InputDecoration(
                              labelText: 'Water in Bottle'),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: _bottleCapacityController,
                          decoration: const InputDecoration(
                              labelText: 'Bottle Capacity'),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: _consumedTodayController,
                          decoration: const InputDecoration(
                              labelText: 'Consumed Today'),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: _consumeGoalController,
                          decoration:
                              const InputDecoration(labelText: 'Consume Goal'),
                          keyboardType: TextInputType.number,
                        ),
                        ElevatedButton(
                          onPressed: _saveConsumptionData,
                          child: const Text('Save Consumption Data'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                      child: Text('No consumption data available'));
                }
              },
            ),
            // Existing FutureBuilder for Logs JSON (Raw and Formatted)
            FutureBuilder<String>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No logs available'));
                } else {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 50.0, 8.0),
                    child: RefreshIndicator(
                      onRefresh: _refreshLogs,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _isRaw
                                    ? _rawController
                                    : _formattedController,
                                maxLines: null,
                                style: const TextStyle(fontSize: 12 ),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Logs JSON',
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _saveLogs,
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
