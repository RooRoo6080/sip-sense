import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:waterbottle/data/display_data.dart';
import 'package:waterbottle/data/db.dart';
import 'package:waterbottle/data/logs.dart';
import 'dart:core';
import 'package:google_fonts/google_fonts.dart';

class MyDayPage extends StatefulWidget {
  const MyDayPage({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _MyDayPageState createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  Future<List<ChartData>>? _chartData;
  Future<Map<String, dynamic>>? _displayDataFuture;
  late ConsumptionData _consumptionData;

  @override
  void initState() {
    super.initState();
    _displayDataFuture = DisplayData.displayData();
    _chartData = DisplayData.dayChartData();
    _loadConsumptionData();
    _fetchDisplayData();
    _fetchChartData();
  }

  void _fetchDisplayData() {
    _displayDataFuture = DisplayData.displayData();
  }

  void _fetchChartData() {
    _chartData = DisplayData.dayChartData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _fetchDisplayData();
      _fetchChartData();
    });
    await _displayDataFuture;
  }

  Future<void> _loadConsumptionData() async {
    final data = await ConsumptionData.loadConsumptionData();
    setState(() {
      _consumptionData = data ??
          ConsumptionData(
            waterInBottle: 0,
            bottleCapacity: 24,
            consumeGoal: 35,
          );
      rebuildAllChildren(context);
    });
  }

  Future<void> _updateConsumptionData() async {
    setState(() async {
      await ConsumptionData.saveConsumptionData(_consumptionData);
      _loadConsumptionData();
      _refreshData;
    });
  }

  void _onBottleFilled(bool amount) {
    setState(() {
      _consumptionData.waterInBottle =
          amount ? _consumptionData.bottleCapacity : 0;
    });
    _updateConsumptionData();
    _refreshData;
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  Future<void> _addLogEntry(double consumed) async {
    final logs = await Logs.loadLogs() ?? Logs(entries: []);
    final newEntry = LogEntry(DateTime.now(), consumed);
    logs.entries.add(newEntry);
    await Logs.saveLogs(logs);
  }

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double newValue = 0.0;
        return AlertDialog(
          title: Text(
            style: GoogleFonts.montserrat(fontSize: 20),
            'Log water consumption',
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: newValue,
                    min: 0,
                    max: _consumptionData.bottleCapacity,
                    divisions: (_consumptionData.bottleCapacity * 2).toInt(),
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
                setState(() {
                  _consumptionData.waterInBottle -= newValue;
                  _displayDataFuture = DisplayData.displayData();
                });
                _updateConsumptionData();
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
    rebuildAllChildren(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<dynamic>(
                future: _displayDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No data available'));
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    List<String> daysOfWeek = [
                      'monday',
                      'tuesday',
                      'wednesday',
                      'thursday',
                      'friday',
                      'saturday',
                      'sunday'
                    ];
                    String dayOfWeek = daysOfWeek[DateTime.now().weekday - 1];
                    final displayData = snapshot.data!;
                    final consumedToday = displayData["${dayOfWeek}Consumed"];
                    final consumeGoal = displayData["consumeGoal"];
                    final waterInBottle = displayData["waterInBottle"];
                    final bottleCapacity = displayData["bottleCapacity"];
                    final sundayConsumed = displayData["sundayConsumed"];
                    final mondayConsumed = displayData["mondayConsumed"];
                    final tuesdayConsumed = displayData["tuesdayConsumed"];
                    final wednesdayConsumed = displayData["wednesdayConsumed"];
                    final thursdayConsumed = displayData["thursdayConsumed"];
                    final fridayConsumed = displayData["fridayConsumed"];
                    final saturdayConsumed = displayData["saturdayConsumed"];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const SizedBox(width: 40),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          height: 250,
                                          child: TweenAnimationBuilder<double>(
                                            tween: Tween<double>(
                                                begin: 0.0,
                                                end: consumedToday! /
                                                    consumeGoal!),
                                            duration: const Duration(
                                                milliseconds: 1000),
                                            curve: Curves.easeInOut,
                                            builder: (context, value, _) =>
                                                CircularProgressIndicator(
                                              value: value,
                                              strokeCap: StrokeCap.round,
                                              strokeWidth: 30,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: 15),
                                            Column(
                                              children: [
                                                Countup(
                                                  begin: 0.0,
                                                  end: consumedToday,
                                                  curve: Curves.easeInOut,
                                                  style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 80,
                                                  ),
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                ),
                                                SizedBox(
                                                  width: 70,
                                                  height: 0,
                                                  child: Divider(
                                                    thickness: 1,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                                Text(
                                                  style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 80,
                                                  ),
                                                  consumeGoal
                                                      .toStringAsFixed(0),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 1),
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RotatedBox(
                                                  quarterTurns: 1,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                    'ounces',
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {});
                                            },
                                            child: const Icon(
                                              Icons.wb_incandescent,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 180),
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: TextButton(
                                            onPressed: _showAddLogDialog,
                                            child: const Icon(
                                              Icons.add,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.5)),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                      begin: 0.0,
                                      end: waterInBottle! / bottleCapacity!),
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeInOut,
                                  builder: (context, value, _) =>
                                      LinearProgressIndicator(
                                    value: value,
                                    minHeight: 25,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryFixed,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _onBottleFilled(false);
                                          _displayDataFuture =
                                              DisplayData.displayData();
                                        });
                                      },
                                      child: const Icon(
                                        Icons.water_drop_outlined,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    '$waterInBottle oz left in bottle',
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 30,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _onBottleFilled(true);
                                          _displayDataFuture =
                                              DisplayData.displayData();
                                        });
                                      },
                                      child: const Icon(
                                        Icons.water_drop,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(
                            thickness: 1,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DoTWCircularProgressIndicator(
                                text: 'S',
                                endTween: sundayConsumed! / consumeGoal,
                              ),
                              DoTWCircularProgressIndicator(
                                text: 'M',
                                endTween: mondayConsumed! / consumeGoal,
                              ),
                              DoTWCircularProgressIndicator(
                                text: 'T',
                                endTween: tuesdayConsumed! / consumeGoal,
                              ),
                              DoTWCircularProgressIndicator(
                                text: 'W',
                                endTween: wednesdayConsumed! / consumeGoal,
                              ),
                              DoTWCircularProgressIndicator(
                                text: 'T',
                                endTween: thursdayConsumed! / consumeGoal,
                              ),
                              DoTWCircularProgressIndicator(
                                text: 'F',
                                endTween: fridayConsumed! / consumeGoal,
                              ),
                              DoTWCircularProgressIndicator(
                                text: 'S',
                                endTween: saturdayConsumed! / consumeGoal,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(thickness: 1),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              FutureBuilder<dynamic>(
                future: _chartData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No data available'));
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    final chartdata = snapshot.data!;
                    return SfCartesianChart(
                      title: const ChartTitle(text: 'Water consumption today'),
                      primaryXAxis: const CategoryAxis(),
                      legend: const Legend(isVisible: true),
                      series: <CartesianSeries>[
                        SplineAreaSeries<ChartData, String>(
                          color: Theme.of(context).colorScheme.onPrimary,
                          opacity: 1,
                          dataSource: chartdata,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y2,
                          name: "Target",
                        ),
                        SplineAreaSeries<ChartData, String>(
                          color: Theme.of(context).colorScheme.primary,
                          opacity: 0.7,
                          dataSource: chartdata,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          name: "You",
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoTWCircularProgressIndicator extends StatelessWidget {
  final String text;
  final double endTween;

  const DoTWCircularProgressIndicator({
    Key? key,
    required this.text,
    required this.endTween,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: endTween),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          builder: (context, value, _) => CircularProgressIndicator(
            value: value,
            strokeCap: StrokeCap.round,
            strokeWidth: 5,
          ),
        ),
        Text(text),
      ],
    );
  }
}
