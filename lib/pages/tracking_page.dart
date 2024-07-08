import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

const List<String> list = <String>[
  'today',
  'this week',
  'this month',
  'this year',
  'all time'
];

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  String dropdownValue = list.first;
  late List<ChartData> _chartData;
  late List<CircleChartData> _circleChartData;

  @override
  void initState() {
    _chartData = getChartData();
    _circleChartData = getCircleChartData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Water consumption "),
              DropdownButton<String>(
                value: dropdownValue,
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          SfCartesianChart(
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
          SfCircularChart(
            title: const ChartTitle(text: 'When you drink water'),
            palette: <Color>[
              Theme.of(context).colorScheme.inversePrimary,
              Theme.of(context).colorScheme.inverseSurface,
              Theme.of(context).colorScheme.onInverseSurface,
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.onSecondary,
              Theme.of(context).colorScheme.onSurface,
              Theme.of(context).colorScheme.onTertiary,
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.onPrimaryFixedVariant,
              Theme.of(context).colorScheme.tertiary,
            ],
            series: <CircularSeries<CircleChartData, String>>[
              DoughnutSeries<CircleChartData, String>(
                dataSource: _circleChartData,
                xValueMapper: (CircleChartData data, _) => data.x,
                yValueMapper: (CircleChartData data, _) => data.y,
                dataLabelMapper: (CircleChartData data, _) => data.x,
                sortingOrder: SortingOrder.ascending,
                dataLabelSettings: const DataLabelSettings(
                  showZeroValue: false,
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                ),
              ),
            ],
          )
        ],
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

  List<CircleChartData> getCircleChartData() {
    final List<CircleChartData> chartData = [
      CircleChartData('1am', 0),
      CircleChartData('2am', 0),
      CircleChartData('3am', 0),
      CircleChartData('4am', 0),
      CircleChartData('5am', 0),
      CircleChartData('6am', 0),
      CircleChartData('7am', 0),
      CircleChartData('8am', 0),
      CircleChartData('9am', 3),
      CircleChartData('10am', 5),
      CircleChartData('11am', 7),
      CircleChartData('12pm', 10),
      CircleChartData('1pm', 10),
      CircleChartData('2pm', 11),
      CircleChartData('3pm', 29),
      CircleChartData('4pm', 32),
      CircleChartData('5pm', 35),
      CircleChartData('6pm', 43),
      CircleChartData('7pm', 54),
      CircleChartData('8pm', 55),
      CircleChartData('9pm', 58),
      CircleChartData('10pm', 59),
      CircleChartData('11pm', 59),
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

class CircleChartData {
  CircleChartData(this.x, this.y);
  final String x;
  final double y;
}
