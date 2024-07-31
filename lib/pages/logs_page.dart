import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:waterbottle/data/logs.dart';

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

  @override
  void initState() {
    super.initState();
    _logsFuture = _loadLogs();
    _logsFormattedFuture = Logs.loadLogs();
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

  Future<void> _refreshLogs() async {
    setState(() {
      _logsFuture = _loadLogs();
      _logsFormattedFuture = Logs.loadLogs();
    });
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
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 50.0, 8.0),
                    child: RefreshIndicator(
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
                    ),
                  );
                }
              },
            ),
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
                                style: const TextStyle(fontSize: 12),
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
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
