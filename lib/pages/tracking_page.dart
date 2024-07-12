import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:waterbottle/data/display_data.dart';

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
  late List<ChartData> _circleChartData;

  @override
  void initState() {
    _chartData = DisplayData.dayChartData();
    _circleChartData = DisplayData.whenDrinkWaterAverage();
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
                    if (dropdownValue == "today") {
                      _chartData = DisplayData.dayChartData();
                    } else if (dropdownValue == "this week") {
                      _chartData = DisplayData.weekChartData();
                    } else if (dropdownValue == "this month") {
                      _chartData = DisplayData.monthChartData();
                    } else if (dropdownValue == "this year") {
                      _chartData = DisplayData.yearChartData();
                    } else if (dropdownValue == "all time") {
                      _chartData = DisplayData.allTimeChartData();
                    }
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
            series: <CircularSeries<ChartData, String>>[
              DoughnutSeries<ChartData, String>(
                dataSource: _circleChartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                dataLabelMapper: (ChartData data, _) => data.x,
                sortingOrder: SortingOrder.ascending,
                explode: true,
                strokeWidth: 0.5,
                strokeColor: Theme.of(context).colorScheme.surface,
                dataLabelSettings: const DataLabelSettings(
                  showZeroValue: false,
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(fontSize: 10),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
