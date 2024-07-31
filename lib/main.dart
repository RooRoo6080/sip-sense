import 'package:flutter/material.dart';
import 'package:waterbottle/data/theme_data.dart';
import 'package:waterbottle/pages/logs_page.dart';
import 'pages/connection_page.dart';
import 'pages/settings_page.dart';
import 'pages/my_day_page.dart';
import 'pages/tracking_page.dart';
import 'services/notification_service.dart';
import 'services/background_timer.dart';
// import 'pages/recommendations_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/db.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

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
  await NotificationService().init();
  await initializeConsumptionData();
  initBackgroundFetch();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(isDarkTheme),
      child: const WaterTrackerApp(),
    ),
  );
}

class WaterTrackerApp extends StatefulWidget {
  const WaterTrackerApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WaterTrackerAppState createState() => _WaterTrackerAppState();
}

class _WaterTrackerAppState extends State<WaterTrackerApp> {
  // ignore: unused_field
  bool _isDarkTheme = true;
  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, themeNotifier, child) {
      return MaterialApp(
        title: 'Water Tracker',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.getThemeData(),
        home: const HomePage(),
      );
    });
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
        title: const Text('SipSense'),
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
        type: BottomNavigationBarType.fixed,
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
