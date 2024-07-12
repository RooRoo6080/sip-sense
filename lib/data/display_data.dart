class DisplayData {
  static Map displayData() {
    final Map data = {};
    data.addAll({"consumedToday": 32});
    data.addAll({"consumeGoal": 45});
    data.addAll({"waterInBottle": 6});
    data.addAll({"sundayConsumed": 38});
    data.addAll({"sundayGoal": 38});
    data.addAll({"mondayConsumed": 38});
    data.addAll({"mondayGoal": 38});
    data.addAll({"tuesdayConsumed": 38});
    data.addAll({"tuesdayGoal": 38});
    data.addAll({"wednesdayConsumed": 38});
    data.addAll({"wednesdayGoal": 38});
    data.addAll({"thursdayConsumed": 38});
    data.addAll({"thursdayGoal": 38});
    data.addAll({"fridayConsumed": 38});
    data.addAll({"fridayGoal": 38});
    data.addAll({"saturdayConsumed": 38});
    data.addAll({"saturdayGoal": 38});
    return data;
  }

  static List<ChartData> dayChartData() {
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

  static List<ChartData> weekChartData() {
    final List<ChartData> chartData = [
      ChartData('Sun.', 10, 30),
      ChartData('Mon.', 11, 35),
      ChartData('Tue.', 29, 40),
      ChartData('Wed.', 32, 45),
      ChartData('Thu.', 35, 50),
      ChartData('Fri.', 43, 55),
      ChartData('Sat.', 54, 60),
    ];
    return chartData;
  }

  static List<ChartData> monthChartData() {
    final List<ChartData> chartData = [
      ChartData('1', 0, 0),
      ChartData('2', 0, 0),
      ChartData('3', 0, 0),
      ChartData('4', 0, 0),
      ChartData('5', 0, 0),
      ChartData('6', 0, 0),
      ChartData('7', 0, 0),
      ChartData('8', 0, 5),
      ChartData('9', 3, 10),
      ChartData('10', 5, 15),
      ChartData('11', 7, 20),
      ChartData('12', 10, 25),
      ChartData('13', 10, 30),
      ChartData('14', 11, 35),
      ChartData('15', 29, 40),
      ChartData('16', 32, 45),
      ChartData('17', 35, 50),
      ChartData('18', 43, 55),
      ChartData('19', 54, 60),
      ChartData('20', 55, 65),
      ChartData('21', 58, 70),
      ChartData('22', 59, 75),
      ChartData('23', 59, 75),
      ChartData('24', 10, 30),
      ChartData('25', 11, 35),
      ChartData('26', 29, 40),
      ChartData('27', 32, 45),
      ChartData('28', null, 50),
      ChartData('29', null, 55),
      ChartData('30', null, 60),
      ChartData('31', null, 65),
    ];
    return chartData;
  }

  static List<ChartData> yearChartData() {
    final List<ChartData> chartData = [
      ChartData('January', 11, 35),
      ChartData('February', 29, 40),
      ChartData('March', 32, 45),
      ChartData('April', 35, 50),
      ChartData('May', 43, 55),
      ChartData('June', 54, 60),
      ChartData('July', 55, 65),
      ChartData('August', 58, 70),
      ChartData('September', 59, 75),
      ChartData('October', 59, 75),
      ChartData('November', 10, 30),
      ChartData('December', 11, 35),
    ];
    return chartData;
  }

  static List<ChartData> allTimeChartData() {
    final List<ChartData> chartData = [
      ChartData('2024', 11, 35),
    ];
    return chartData;
  }

  static List<ChartData> whenDrinkWaterAverage() {
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
