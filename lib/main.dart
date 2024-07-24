import 'package:flutter/material.dart';
import 'package:waterbottle/data/theme_data.dart';
import 'package:waterbottle/pages/logs_page.dart';
import 'pages/connection_page.dart';
import 'pages/settings_page.dart';
import 'pages/my_day_page.dart';
import 'pages/tracking_page.dart';
// import 'pages/recommendations_page.dart';
import 'data/db.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:core';

Future<void> initializeConsumptionData() async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/consumption_data.json';
  final file = File(filePath);

  if (!(await file.exists())) {
    final defaultData = ConsumptionData(
      waterInBottle: 24,
      bottleCapacity: 24,
      consumeGoal: 35,
    );
    await file.writeAsString(jsonEncode(defaultData.toJson()));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeConsumptionData();
  runApp(const WaterTrackerApp());
}

class WaterTrackerApp extends StatefulWidget {
  const WaterTrackerApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WaterTrackerAppState createState() => _WaterTrackerAppState();
}

class _WaterTrackerAppState extends State<WaterTrackerApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Tracker',
      debugShowCheckedModeBanner: false,
      theme: Styles.themeData(true, Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const MyDayPage(),
    const TrackingPage(),
    // const RecommendationsPage(),
    const LogsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.bluetooth),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConnectionPage()),
            );
          },
        ),
        title: const Text('Smartwater'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        enableFeedback: true,
        selectedItemColor: Theme.of(context).colorScheme.onSurface,
        unselectedItemColor: Theme.of(context).colorScheme.primaryFixedDim,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'My Day',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.recommend),
          //   label: 'Tips',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.developer_board),
            label: 'Logs',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
