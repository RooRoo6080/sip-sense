import 'package:waterbottle/data/db.dart';

class DisplayData {
  static Future<Map<String, double>> displayData() async {
    final consumptionData = await ConsumptionData.loadConsumptionData();
    final Map<String, double> data = {};

    if (consumptionData != null) {
      data['consumedToday'] = consumptionData.consumedToday;
      data['consumeGoal'] = consumptionData.consumeGoal;
      data['waterInBottle'] = consumptionData.waterInBottle;
      data['bottleCapacity'] = consumptionData.bottleCapacity;
      data.addAll({"sundayConsumed": 38});
      data.addAll({"mondayConsumed": 45});
      data.addAll({"tuesdayConsumed": 38});
      data.addAll({"wednesdayConsumed": 32});
      data.addAll({"thursdayConsumed": 13});
      data.addAll({"fridayConsumed": 63});
      data.addAll({"saturdayConsumed": 38});
    }
    return data;
  }

  static Future<List<ChartData>> dayChartData() async {
    final consumptionData = await ConsumptionData.loadConsumptionData();
    final goal = consumptionData?.consumeGoal;

    final List<ChartData> chartData = [
      ChartData('1am', 0, 0),
      ChartData('2am', 0, 0),
      ChartData('3am', 0, 0),
      ChartData('4am', 0, 0),
      ChartData('5am', 0, 0),
      ChartData('6am', 0, 0),
      ChartData('7am', 0, 0),
      ChartData('8am', 0, goal! * 1 / 15),
      ChartData('9am', 3, goal * 2 / 16),
      ChartData('10am', 5, goal * 3 / 16),
      ChartData('11am', 7, goal * 4 / 16),
      ChartData('12pm', 10, goal * 5 / 16),
      ChartData('1pm', 10, goal * 6 / 16),
      ChartData('2pm', 11, goal * 7 / 16),
      ChartData('3pm', 29, goal * 8 / 16),
      ChartData('4pm', 32, goal * 9 / 16),
      ChartData('5pm', 35, goal * 10 / 16),
      ChartData('6pm', 43, goal * 11 / 16),
      ChartData('7pm', 54, goal * 12 / 16),
      ChartData('8pm', 55, goal * 13 / 16),
      ChartData('9pm', 58, goal * 14 / 16),
      ChartData('10pm', 59, goal * 15 / 16),
      ChartData('11pm', 59, goal),
      ChartData('12am', 59, goal),
    ];
    return chartData;
  }

  static Future<List<ChartData>> weekChartData() async {
    final consumptionData = await ConsumptionData.loadConsumptionData();
    final goal = consumptionData?.consumeGoal;
    final List<ChartData> chartData = [
      ChartData('Sun.', 10, goal),
      ChartData('Mon.', 11, goal),
      ChartData('Tue.', 29, goal),
      ChartData('Wed.', 32, goal),
      ChartData('Thu.', 35, goal),
      ChartData('Fri.', 43, goal),
      ChartData('Sat.', 54, goal),
    ];
    return chartData;
  }

  static Future<List<ChartData>> monthChartData() async {
    final consumptionData = await ConsumptionData.loadConsumptionData();
    final goal = consumptionData?.consumeGoal;
    final List<ChartData> chartData = [
      ChartData('1', 0, goal),
      ChartData('2', 0, goal),
      ChartData('3', 0, goal),
      ChartData('4', 0, goal),
      ChartData('5', 0, goal),
      ChartData('6', 0, goal),
      ChartData('7', 0, goal),
      ChartData('8', 0, goal),
      ChartData('9', 3, goal),
      ChartData('10', 5, goal),
      ChartData('11', 7, goal),
      ChartData('12', 10, goal),
      ChartData('13', 10, goal),
      ChartData('14', 11, goal),
      ChartData('15', 29, goal),
      ChartData('16', 32, goal),
      ChartData('17', 35, goal),
      ChartData('18', 43, goal),
      ChartData('19', 54, goal),
      ChartData('20', 55, goal),
      ChartData('21', 58, goal),
      ChartData('22', 59, goal),
      ChartData('23', 59, goal),
      ChartData('24', 10, goal),
      ChartData('25', 11, goal),
      ChartData('26', 29, goal),
      ChartData('27', 32, goal),
      ChartData('28', null, goal),
      ChartData('29', null, goal),
      ChartData('30', null, goal),
      ChartData('31', null, goal),
    ];
    return chartData;
  }

  static Future<List<ChartData>> yearChartData() async {
    final consumptionData = await ConsumptionData.loadConsumptionData();
    final goal = consumptionData?.consumeGoal;
    final List<ChartData> chartData = [
      ChartData('January', 11, goal! * 31),
      ChartData('February', 29, goal * 28),
      ChartData('March', 32, goal * 31),
      ChartData('April', 35, goal * 30),
      ChartData('May', 43, goal * 31),
      ChartData('June', 54, goal * 30),
      ChartData('July', 55, goal * 31),
      ChartData('August', 58, goal * 31),
      ChartData('September', 59, goal * 30),
      ChartData('October', 59, goal * 31),
      ChartData('November', 10, goal * 30),
      ChartData('December', 11, goal * 31),
    ];
    return chartData;
  }

  static Future<List<ChartData>> allTimeChartData() async {
    final consumptionData = await ConsumptionData.loadConsumptionData();
    final goal = consumptionData?.consumeGoal;
    final List<ChartData> chartData = [
      ChartData('2024', 11, goal! * 365),
    ];
    return chartData;
  }

  static Future<List<ChartData>> whenDrinkWaterAverage() async {
    final consumptionData = await ConsumptionData.loadConsumptionData();
    final goal = consumptionData?.consumeGoal;
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
