import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:waterbottle/data/display_data.dart';


class MyDayPage extends StatefulWidget {
  const MyDayPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyDayPageState createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  late List<ChartData> _chartData;
  var number = 0;

  @override
  void initState() {
    _chartData = getChartData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Circular status graphic
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: DisplayData.displayData()["consumedToday"] / DisplayData.displayData()["consumeGoal"]),
                              duration: const Duration(milliseconds: 3500),
                              curve: Curves.bounceInOut,
                              builder: (context, value, _) =>
                                  CircularProgressIndicator(
                                value: value,
                                strokeCap: StrokeCap.round,
                                strokeWidth: 25,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                    ),
                                    DisplayData.displayData()["consumedToday"].toString(),
                                  ),
                                  const SizedBox(
                                    width: 40,
                                    child: Divider(
                                        thickness: 1, color: Colors.white),
                                  ),
                                  Text(
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                    ),
                                    DisplayData.displayData()["consumeGoal"].toString(),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  number++;
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
                                  number++;
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
            // Linear status bar
            Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12.5)),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: .3),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    builder: (context, value, _) => LinearProgressIndicator(
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
                  '${DisplayData.displayData()["waterInBottle"]} oz left in bottle',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(
              thickness: 1,
            ),
            const SizedBox(height: 20),
            // Data points
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DoTWCircularProgressIndicator(text: 'S', endTween: 0.1),
                DoTWCircularProgressIndicator(text: 'M', endTween: 1.1),
                DoTWCircularProgressIndicator(text: 'T', endTween: 0.4),
                DoTWCircularProgressIndicator(text: 'W', endTween: 0.2),
                DoTWCircularProgressIndicator(text: 'T', endTween: 0.8),
                DoTWCircularProgressIndicator(text: 'F', endTween: 0.5),
                DoTWCircularProgressIndicator(text: 'S', endTween: 0.0),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            SfCartesianChart(
              title: const ChartTitle(text: 'Water consumption today'),
              primaryXAxis: const CategoryAxis(),
              legend: const Legend(isVisible: true),
              series: <CartesianSeries>[
                AreaSeries<ChartData, String>(
                  color: Theme.of(context).colorScheme.onPrimary,
                  opacity: 1,
                  dataSource: _chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y2,
                  name: "Target",
                ),
                AreaSeries<ChartData, String>(
                  color: Theme.of(context).colorScheme.primary,
                  opacity: 0.7,
                  dataSource: _chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  name: "You",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> getChartData() {
    final List<ChartData> chartData = [
      ChartData('1am', 0, 0),
      ChartData('2am', 0, 0),
      ChartData('3am', 0, 0),
      ChartData('4am', 0, 0),
      ChartData('5am', 0, 0),
      ChartData('6am', 0, 0),
      ChartData('7am', 0, 0),
      ChartData('8am', 0, 5),
      ChartData('9am', 3, 10),
      ChartData('10am', 5, 15),
      ChartData('11am', 7, 20),
      ChartData('12pm', 10, 25),
      ChartData('1pm', 10, 30),
      ChartData('2pm', 11, 35),
      ChartData('3pm', 29, 40),
      ChartData('4pm', 32, 45),
      ChartData('5pm', 35, 50),
      ChartData('6pm', 43, 55),
      ChartData('7pm', 54, 60),
      ChartData('8pm', 55, 65),
      ChartData('9pm', 58, 70),
      ChartData('10pm', 59, 75),
      ChartData('11pm', 59, 75),
    ];
    return chartData;
  }
}

class ChartData {
  ChartData(this.x, this.y, this.y2);
  final String x;
  final double? y;
  final double? y2;
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
