import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:waterbottle/data/display_data.dart';
import 'package:animated_digit/animated_digit.dart';

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
    _chartData = DisplayData.dayChartData();
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
                              tween: Tween<double>(
                                  begin: 0.0,
                                  end: DisplayData.displayData()[
                                          "consumedToday"] /
                                      DisplayData.displayData()["consumeGoal"]),
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
                                  AnimatedDigitWidget(
                                    textStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                      fontFamily: GoogleFonts.montserrat()
                                          .toString(),
                                    ),
                                    duration:
                                        const Duration(milliseconds: 3500),
                                    curve: Curves.bounceInOut,
                                    value: DisplayData.displayData()[
                                        "consumedToday"],
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Divider(
                                        thickness: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                  ),
                                  Text(
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                    ),
                                    DisplayData.displayData()["consumeGoal"]
                                        .toString(),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DoTWCircularProgressIndicator(
                    text: 'S',
                    endTween: DisplayData.displayData()["sundayConsumed"] /
                        DisplayData.displayData()["sundayGoal"]),
                DoTWCircularProgressIndicator(
                    text: 'M',
                    endTween: DisplayData.displayData()["mondayConsumed"] /
                        DisplayData.displayData()["mondayGoal"]),
                DoTWCircularProgressIndicator(
                    text: 'T',
                    endTween: DisplayData.displayData()["tuesdayConsumed"] /
                        DisplayData.displayData()["tuesdayGoal"]),
                DoTWCircularProgressIndicator(
                    text: 'W',
                    endTween: DisplayData.displayData()["wednesdayConsumed"] /
                        DisplayData.displayData()["wednesdayGoal"]),
                DoTWCircularProgressIndicator(
                    text: 'T',
                    endTween: DisplayData.displayData()["thursdayConsumed"] /
                        DisplayData.displayData()["thursdayGoal"]),
                DoTWCircularProgressIndicator(
                    text: 'F',
                    endTween: DisplayData.displayData()["fridayConsumed"] /
                        DisplayData.displayData()["fridayGoal"]),
                DoTWCircularProgressIndicator(
                    text: 'S',
                    endTween: DisplayData.displayData()["saturdayConsumed"] /
                        DisplayData.displayData()["saturdayGoal"]),
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
