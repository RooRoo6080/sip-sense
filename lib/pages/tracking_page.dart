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
  late Future<List<ChartData>> _chartDataFuture;
  late Future<List<ChartData>> _circleChartDataFuture;

  @override
  void initState() {
    super.initState();
    _chartDataFuture = DisplayData.dayChartData();
    _circleChartDataFuture = DisplayData.whenDrinkWaterAverage();
  }

  void _fetchChartData(String period) {
    setState(() {
      if (period == "today") {
        _chartDataFuture = DisplayData.dayChartData();
      } else if (period == "this week") {
        _chartDataFuture = DisplayData.weekChartData();
      } else if (period == "this month") {
        _chartDataFuture = DisplayData.monthChartData();
      } else if (period == "this year") {
        _chartDataFuture = DisplayData.yearChartData();
      } else if (period == "all time") {
        _chartDataFuture = DisplayData.allTimeChartData();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _chartDataFuture = DisplayData.dayChartData();
      _circleChartDataFuture = DisplayData.whenDrinkWaterAverage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
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
                        _fetchChartData(dropdownValue);
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
              FutureBuilder<List<ChartData>>(
                future: _chartDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  } else {
                    final chartData = snapshot.data!;
                    return SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      legend: const Legend(isVisible: true),
                      series: <CartesianSeries>[
                        AreaSeries<ChartData, String>(
                          color: Theme.of(context).colorScheme.onPrimary,
                          opacity: 1,
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y2,
                          name: "Target",
                        ),
                        AreaSeries<ChartData, String>(
                          color: Theme.of(context).colorScheme.primary,
                          opacity: 0.7,
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          name: "You",
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            showZeroValue: false,
                            overflowMode: OverflowMode.hide,
                            textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              FutureBuilder<List<ChartData>>(
                future: _circleChartDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  } else {
                    final circleChartData = snapshot.data!;
                    return SfCircularChart(
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
                          dataSource: circleChartData,
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
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
