import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';

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
  Future<int> futureTotalClientsValue;

  @override
  void initState() {
    super.initState();
    futureTotalClients = _getTotalClients();
    futureTotalClientsValue = _getTotalClientsValue();
  }

  Future<int> _getTotalClients() async {
    return await widget.admin.getTotalClients;
  }

  Future<int> _getTotalClientsValue() async {
    return await widget.admin.getTotalClientsMonthlyPay;
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
            children: [
              Container(
                margin: EdgeInsets.all(10),
                height: SizeConfig.safeBlockVertical * 20,
                child: Card(
                  elevation: 6,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                child: Text(
                                  'Total Customers',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          SizeConfig.safeBlockHorizontal * 4.5),
                                ),
                              ),
                              Card(
                                color: Colors.green[300],
                                elevation: 4,
                                child: Container(
                                    // height: 30,
                                    // width: 30,
                                    padding: EdgeInsets.all(5),
                                    child: buildFuture(
                                        futureTotalClients,
                                        (snap) => Text(
                                              '${snap.data}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: SizeConfig
                                                          .safeBlockHorizontal *
                                                      5),
                                              textAlign: TextAlign.center,
                                            ))),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                child: Text(
                                  'All Customers Total Value',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          SizeConfig.safeBlockHorizontal * 4.5),
                                ),
                              ),
                              Card(
                                color: Colors.green[300],
                                elevation: 4,
                                child: Container(
                                    // height: 30,
                                    // width: 30,
                                    padding: EdgeInsets.all(5),
                                    child: buildFuture(
                                        futureTotalClientsValue,
                                        (snap) => Text(
                                              '\$${snap.data}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: SizeConfig
                                                          .safeBlockHorizontal *
                                                      5),
                                              textAlign: TextAlign.center,
                                            ))),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              WeeklySummary(widget.admin)
            ],
          ),
        ));
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

  Future<List<int>> futureDayTotal;
  Future<int> futureWeekTotal;

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

    futureDayTotal = _getDayTotal();
    futureWeekTotal = _getWeekTotal();
  }

  Future<List<int>> _getDayTotal() async {
    List<int> totals = [];
    for (var i = 0; i < days.length; i++) {
      totals.add(await widget.admin.getDayTotal(i, start));
    }

    return totals;
  }

  Future<int> _getWeekTotal() async {
    return await widget.admin.getWeekTotal(start);
  }

  void changeDate({bool subtract = false}) {
    subtract
        ? start = DateTime(start.year, start.month, start.day - 7)
        : start = DateTime(start.year, start.month, start.day + 7);
    setState(() {
      futureDayTotal = _getDayTotal();
      futureWeekTotal = _getWeekTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    String startDayFormatted = DateFormat('M/dd/yy').format(start);
    String endDayFormatted =
        DateFormat('M/dd/yy').format(start.add(Duration(days: 6)));
    return Container(
      margin: EdgeInsets.all(10),
      height: SizeConfig.safeBlockVertical * 35,
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
                    Container(
                      child: FlatButton(
                        onPressed: () {
                          changeDate(subtract: true);
                        },
                        child: Icon(Icons.arrow_left),
                      ),
                    ),
                    Container(
                      // margin: EdgeInsets.only(bottom: 20),
                      child: Text('$startDayFormatted - $endDayFormatted',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.safeBlockHorizontal * 4)),
                    ),
                    Container(
                      child: FlatButton(
                        onPressed: () {
                          changeDate();
                        },
                        child: Icon(Icons.arrow_right),
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
                        builder: (context, AsyncSnapshot<List<int>> snap) {
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
                                              '\$${snap.data[i]}',
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
                Row(
                  children: [
                    Container(
                      child: Text(
                        'Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.safeBlockHorizontal * 4.5),
                      ),
                    ),
                    Container(
                      child: Card(
                        color: Colors.green[300],
                        elevation: 4,
                        child: Container(
                            // height: 30,
                            // width: 30,
                            padding: EdgeInsets.all(5),
                            child: buildFuture(
                                futureWeekTotal,
                                (snap) => Text(
                                      '\$${snap.data}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              SizeConfig.safeBlockHorizontal *
                                                  5),
                                      textAlign: TextAlign.center,
                                    ))),
                      ),
                    ),
                  ],
                ),
                // Row(
                //   children: [
                //     Container(
                //       child: Text(
                //         '-Worker Fees',
                //         style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             fontSize:
                //                 SizeConfig.safeBlockHorizontal * 4.5),
                //       ),
                //     ),
                //     Container(
                //       child: Card(
                //         color: Colors.green[300],
                //         elevation: 4,
                //         child: Container(
                //             // height: 30,
                //             // width: 30,
                //             padding: EdgeInsets.all(5),
                //             child: buildFuture(
                //                 widget.admin.getWeekTotalMinusWorkerFees(),
                //                 (snap) => Text(
                //                       '\$${snap.data}',
                //                       style: TextStyle(
                //                           fontWeight: FontWeight.bold,
                //                           fontSize: SizeConfig
                //                                   .safeBlockHorizontal *
                //                               5),
                //                       textAlign: TextAlign.center,
                //                     ))),
                //       ),
                //     )
                //   ],
                // )
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
