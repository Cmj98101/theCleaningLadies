import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/notification_model/push_notification.dart';

class WeekDayTotal {
  Map<int, int> weekDayTotals = {};
  WeekDayTotal();
}

class SummaryScreen extends StatefulWidget {
  final Admin admin;
  SummaryScreen({@required this.admin});
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Future<int> futureTotalClients;
  Future<double> futureTotalClientsValue;
  PushNotifications _pushNotifications;

  @override
  void initState() {
    super.initState();
    print('Summary');
    futureTotalClients = _getTotalClients();
    futureTotalClientsValue = _getTotalClientsValue();
    _pushNotifications = PushNotifications(
        admin: widget.admin, context: context, isMounted: () => mounted);
  }

  Future<int> _getTotalClients() async {
    return await widget.admin.getTotalClients;
  }

  Future<double> _getTotalClientsValue() async {
    return await widget.admin.getTotalClientsMonthlyPay;
  }

  @override
  void dispose() {
    super.dispose();
    _pushNotifications.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Summary'),
        ),
        body: Container(
          child: Column(
            children: [mainInfo(), WeeklySummary(widget.admin)],
          ),
        ));
  }

  Widget mainInfo() {
    return Container(
      margin: EdgeInsets.all(10),
      height: SizeConfig.safeBlockVertical * 20,
      child: Card(
        elevation: 6,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildFuture(
                  futureTotalClients,
                  (snap) => TitleWithHighlightedText(
                      title: 'Total Customers',
                      highlightedText: '${snap.data}')),
              buildFuture(
                  futureTotalClientsValue,
                  (snap) => TitleWithHighlightedText(
                      title: 'All Customers Total Value',
                      highlightedText: '\$${snap.data.truncate()}')),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFuture(Future future, Widget Function(AsyncSnapshot) widget) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
          switch (snap.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: Container(
                  child: CircularProgressIndicator(),
                ),
              );

              break;

            case ConnectionState.done:
              return widget(snap);
              break;

            default:
              return (Container(
                child: Text('NA'),
              ));
          }
        });
  }
}

class WeeklySummary extends StatefulWidget {
  final Admin admin;

  WeeklySummary(this.admin);

  @override
  _WeeklySummaryState createState() => _WeeklySummaryState();
}

class _WeeklySummaryState extends State<WeeklySummary> {
  DateTime start;
  int selectedMonth = 1;
  Future<List<double>> futureDayTotal;
  Future<double> futureWeekTotal;
  Future<double> futureMonthTotal;
  List days = [
    'Mon.',
    'Tue.',
    'Wed.',
    'Thurs.',
    'Fri.',
    'Sat.',
    'Sun.',
  ];

  DateTime getStartOfWeek() {
    DateTime now = DateTime.now();
    DateTime dateOnly = DateTime(now.year, now.month, now.day);
    int weekDay = dateOnly.weekday;
    if (weekDay == 1) {
      return dateOnly;
    }
    return dateOnly.subtract(Duration(days: weekDay - 1));
  }

  @override
  void initState() {
    super.initState();
    start = getStartOfWeek();
    selectedMonth = start.month;
    futureDayTotal = _getDayTotal();
    futureWeekTotal = _getWeekTotal();
    futureMonthTotal = _getMonthlyTotal();
  }

  Future<List<double>> _getDayTotal() async {
    List<double> totals = [];
    for (var i = 0; i < days.length; i++) {
      totals.add(await widget.admin.getDayTotal(i, start));
    }

    return totals;
  }

  Future<double> _getWeekTotal() async =>
      await widget.admin.getWeekTotal(start);
  Future<double> _getMonthlyTotal() async =>
      await widget.admin.getTotalMonthlyProfit(start.month);

  void changeDate({bool subtract = false}) {
    subtract
        ? start = DateTime(start.year, start.month, start.day - 7)
        : start = DateTime(start.year, start.month, start.day + 7);
    setState(() {
      futureDayTotal = _getDayTotal();
      futureWeekTotal = _getWeekTotal();

      if (start.month == selectedMonth) {
        // Do Nothing
      } else {
        futureMonthTotal = _getMonthlyTotal();
      }
    });
    selectedMonth = start.month;
  }

  @override
  Widget build(BuildContext context) {
    String startDayFormatted = DateFormat('M/dd/yy').format(start);
    String endDayFormatted =
        DateFormat('M/dd/yy').format(start.add(Duration(days: 6)));
    return Container(
      margin: EdgeInsets.all(10),
      height: SizeConfig.safeBlockVertical * 40,
      child: SwipeDetector(
        onSwipeRight: () {
          changeDate(subtract: true);
        },
        onSwipeLeft: () {
          setState(() {
            print('swipe left');
            changeDate();
          });
        },
        child: Card(
          elevation: 6,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  // margin: EdgeInsets.only(bottom: 20),
                  child: Text('Week Of',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig.safeBlockHorizontal * 4.5)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        child: FlatButton(
                          onPressed: () {
                            changeDate(subtract: true);
                          },
                          child: Icon(Icons.arrow_left),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 0,
                      child: Container(
                        // margin: EdgeInsets.only(bottom: 20),
                        child: Text('$startDayFormatted - $endDayFormatted',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.safeBlockHorizontal * 4)),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: FlatButton(
                          onPressed: () {
                            changeDate();
                          },
                          child: Icon(Icons.arrow_right),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: FutureBuilder(
                        future: futureDayTotal,
                        builder: (context, AsyncSnapshot<List<double>> snap) {
                          switch (snap.connectionState) {
                            case ConnectionState.waiting:
                              return Center(
                                child: Container(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              break;

                            case ConnectionState.done:
                              return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (var i = 0; i < snap.data.length; i++)
                                      Column(
                                        children: [
                                          Container(
                                            child: Text(days[i],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: SizeConfig
                                                            .safeBlockHorizontal *
                                                        3)),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 15),
                                            child: Text(
                                              '\$${snap.data[i].truncate()}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: SizeConfig
                                                          .safeBlockHorizontal *
                                                      3),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        ],
                                      ),
                                  ]);
                              break;

                            default:
                              return (Container(
                                child: Text('NA'),
                              ));
                              break;
                          }
                        },
                      )),
                ),
                buildFuture(
                    futureWeekTotal,
                    (snap) => TitleWithHighlightedText(
                        title: 'Weekly Total',
                        highlightedText: '\$${snap.data.truncate()}')),
                buildFuture(
                    futureMonthTotal,
                    (snap) => TitleWithHighlightedText(
                        title: 'Monthly Total',
                        highlightedText: '\$${snap.data.truncate()}')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFuture(Future future, Widget Function(AsyncSnapshot) widget) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
          switch (snap.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: Container(
                  child: CircularProgressIndicator(),
                ),
              );

              break;

            case ConnectionState.done:
              return widget(snap);
              break;

            default:
              return (Container(
                child: Text('NA'),
              ));
          }
        });
  }
}

class TitleWithHighlightedText extends StatelessWidget {
  final String title;
  final String highlightedText;

  TitleWithHighlightedText(
      {@required this.title, @required this.highlightedText});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Flexible(
            child: Container(
              child: Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.safeBlockHorizontal * 4.5),
              ),
            ),
          ),
          Card(
            color: Colors.green[300],
            elevation: 4,
            child: Container(
                // height: 30,
                // width: 30,
                padding: EdgeInsets.all(5),
                child: Text(
                  highlightedText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.safeBlockHorizontal * 5),
                  textAlign: TextAlign.center,
                )),
          )
        ],
      ),
    );
  }
}
