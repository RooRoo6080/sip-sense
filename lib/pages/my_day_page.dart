import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:waterbottle/data/display_data.dart';
import 'package:waterbottle/data/db.dart';
import 'package:waterbottle/data/logs.dart';
import 'dart:core';

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
    // await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _consumptionData = data ??
          ConsumptionData(
            waterInBottle: 0,
            bottleCapacity: 24,
            consumedToday: 0,
            consumeGoal: 35,
            lastUpdated: DateTime.now().toIso8601String(),
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

  void _onBottleFilled(double amount) {
    setState(() {
      _consumptionData.waterInBottle = _consumptionData.bottleCapacity;
    });
    _updateConsumptionData();
  }

  void _onWaterDrunk(double amount) {
    setState(() {
      _consumptionData.consumedToday += amount;
      _consumptionData.waterInBottle -= amount;
    });
    _updateConsumptionData();
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
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
                    final displayData = snapshot.data!;
                    final consumedToday = displayData["consumedToday"];
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
                                              strokeWidth: 25,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Countup(
                                                  begin: 0.0,
                                                  end: consumedToday,
                                                  curve: Curves.easeInOut,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 40,
                                                  ),
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                ),
                                                SizedBox(
                                                  width: 40,
                                                  child: Divider(
                                                    thickness: 1,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                                Text(
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 40,
                                                  ),
                                                  consumeGoal.toString(),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 10),
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('oz\nconsumed'),
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
                                          child: FloatingActionButton(
                                            onPressed: () {
                                              setState(() {
                                                _onBottleFilled(0);
                                                // rebuildAllChildren(context);
                                                // Navigator.popAndPushNamed(
                                                //     context, '/screenname');
                                              });
                                            },
                                            child: const Icon(
                                              Icons.water_drop,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 170),
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: FloatingActionButton(
                                            onPressed: () {
                                              setState(() {
                                                _onWaterDrunk(2);
                                                // rebuildAllChildren(context);
                                                // Navigator.popAndPushNamed(
                                                //     context, '/screenname');
                                              });
                                            },
                                            child: const Icon(
                                              Icons.add,
                                              size: 20,
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
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                '$waterInBottle oz left in bottle',
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
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              const Divider(),
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
                        AreaSeries<ChartData, String>(
                          color: Theme.of(context).colorScheme.onPrimary,
                          opacity: 1,
                          dataSource: chartdata,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y2,
                          name: "Target",
                        ),
                        AreaSeries<ChartData, String>(
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
