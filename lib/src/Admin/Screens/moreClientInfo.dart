import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/addClient.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/clientReminderMsgEditor.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';

import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/Models/historyEvent.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';

class MoreClientInfo extends StatefulWidget {
  final Client client;
  final Admin admin;
  MoreClientInfo({@required this.client, this.admin});
  @override
  _MoreClientInfoState createState() => _MoreClientInfoState();
}

enum Mode { viewing, editing }

class _MoreClientInfoState extends State<MoreClientInfo> {
  Mode currentMode;
  @override
  void initState() {
    super.initState();
    currentMode = Mode.viewing;
  }

  Widget keyboardDismisser({BuildContext context, Widget child}) {
    final gesture = GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        // debugPrint("!!!");
      },
      child: child,
    );
    return gesture;
  }

  @override
  Widget build(BuildContext context) {
    Client client = widget.client;

    SizeConfig().init(context);
    return keyboardDismisser(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            // FlatButton(
            //     onPressed: () {
            //       widget.admin.updateClientHistory();
            //     },
            //     child: Icon(Icons.add)),
            FlatButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClientReminderMsgEditor(
                              admin: widget.admin,
                              isClientSide: true,
                              client: widget.client,
                            ))),
                child: Icon(Icons.message_outlined)),
            FlatButton(
                onPressed: handleCurrentMode,
                child: Icon(currentMode == Mode.editing
                    ? Icons.remove_red_eye
                    : Icons.mode_edit)),
          ],
          // title: Text('More Info on ${client.firstName}',
          //     style: TextStyle(
          //       fontSize: SizeConfig.safeBlockHorizontal * 3.7,
          //     )),
        ),
        body: currentMode == Mode.editing
            ? AddClient(
                true,
                exitEditing: handleCurrentMode,
                admin: widget.admin,
                client: client,
              )
            : ListView(children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 25,
                  ),
                  width: MediaQuery.of(context).size.width,
                  // height: 300,
                  child: Card(
                      child: Container(
                          padding: EdgeInsets.all(15),
                          child: Stack(
                            children: [
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: widget.client?.keyRequired ?? false
                                      ? Icon(
                                          Icons.vpn_key,
                                          color: Colors.green,
                                        )
                                      : Container()),
                              Column(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Customer Information',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                SizeConfig.safeBlockHorizontal *
                                                    5.5)),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 15, top: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                            child: Text('Active: ',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        Container(
                                            child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              client.handleIsActive;
                                            });
                                          },
                                          child: Text(
                                            '${client.active ? 'Yes' : 'No'}',
                                            style: TextStyle(
                                                color: client.active
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 15, top: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${client.firstName}, ${client.lastName}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 15, top: 15),
                                    alignment: Alignment.centerLeft,
                                    child: InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                                text: client
                                                    .formattedContactNumber))
                                            .then((result) {
                                          final snackBar = SnackBar(
                                            content: Text(
                                                'Copied to Clipboard ${client.formattedContactNumber}'),
                                            action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () {},
                                            ),
                                          );
                                          Scaffold.of(context)
                                              .showSnackBar(snackBar);
                                        });
                                      },
                                      child: Text(
                                        '${client.formattedContactNumber}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 15, top: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      client.formattedAddress,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ))),
                ),
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15, top: 25),
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text('Cleaning Information',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 5.5)),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, top: 15),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Per Cleaning: \$${client.costPerCleaning}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, top: 15),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Frequency: ${client.showCleaningFrequencyText}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, top: 15),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Likes ${client.showCleaningTimePreferenceText}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, top: 15),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Last Cleaning: ${DateFormat('MM/dd/yy').format(client.lastCleaning)}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, top: 15),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Next Cleaning: ${client.nextCleaning} lands on ${client.nextCleaningWeekDay}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                for (var day in client.dayPreferences)
                                  Container(
                                      margin: EdgeInsets.only(left: 0, top: 15),
                                      child: Text(
                                        day.name,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: day.favoribleScale ==
                                                    FavoribleScale.isOkay
                                                ? Colors.blue[400]
                                                : day.favoribleScale ==
                                                        FavoribleScale
                                                            .isPrefered
                                                    ? Colors.green[400]
                                                    : Colors.red[400]),
                                      ))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                client.family.length < 1
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(left: 15, right: 15, top: 25),
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    client.family.length < 1
                                        ? Container()
                                        : Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text('Relatives',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: SizeConfig
                                                            .safeBlockHorizontal *
                                                        5.5)),
                                          ),
                                    client.family.length < 1
                                        ? Container()
                                        : Column(
                                            children: <Widget>[
                                              for (var fam in client.family)
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        top: 20),
                                                    child: Text(
                                                      '${fam.firstName} ${fam.lastName}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ))
                                            ],
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                Container(
                    height: SizeConfig.safeBlockVertical * 48,
                    margin: EdgeInsets.only(left: 15, right: 15, top: 25),
                    child: NotesWidget(
                      client: widget.client,
                    )),
                Container(
                  height: SizeConfig.safeBlockVertical * 37,
                  margin: EdgeInsets.only(left: 15, right: 15, top: 25),
                  child: ShowHistory(
                    admin: widget.admin,
                    client: widget.client,
                  ),
                )
              ]),
      ),
    );
  }

  void handleCurrentMode() {
    setState(() {
      if (currentMode == Mode.viewing) {
        currentMode = Mode.editing;
      } else if (currentMode == Mode.editing) {
        currentMode = Mode.viewing;
      }
    });
  }
}

class ShowHistory extends StatefulWidget {
  final Client client;
  final Admin admin;
  ShowHistory({@required this.client, @required this.admin});
  @override
  _ShowHistoryState createState() => _ShowHistoryState();
}

class _ShowHistoryState extends State<ShowHistory> {
  @override
  Widget build(BuildContext context) {
    int total;
    SizeConfig().init(context);
    return Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(20),
              child: Text(
                'Cleaning History',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeConfig.safeBlockHorizontal * 5.5,
                ),
              ),
            ),
            Container(
              height: SizeConfig.safeBlockHorizontal * 45,
              child: StreamBuilder(
                stream: widget.client.cleaningHistory,
                builder: (BuildContext context,
                    AsyncSnapshot<List<HistoryEvent>> snap) {
                  switch (snap.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                      break;

                    default:
                      return snap.hasData
                          ? Container(
                              // height: 50,
                              child: ListView(
                                children: snap.data.map((historyEvent) {
                                  return Column(
                                    children: [
                                      HistoryEventTile(
                                        historyEvent: historyEvent,
                                      ),
                                      Divider(
                                        height: 3,
                                        thickness: 2,
                                        // color: Colors.black45,
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            )
                          : Center(
                              child: CircularProgressIndicator(),
                            );
                      break;
                  }
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: SizeConfig.safeBlockHorizontal * 6,
                  right: SizeConfig.safeBlockHorizontal * 6),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Text(
                    'Total',
                    style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                // buildFuture(
                //   widget.client.totalEarnedFromCustomer,
                //   (snap) =>
                StreamBuilder<List<HistoryEvent>>(
                    stream: widget.client.totalEarnedFromCustomer,
                    builder: (context, snap) {
                      if (snap.hasData) {
                        total = 0;
                        snap.data.forEach(
                            (historyEvent) => total += historyEvent.fee);
                      }
                      return snap.hasData
                          ? Text(
                              '\$$total',
                              style: TextStyle(
                                  fontSize:
                                      SizeConfig.safeBlockHorizontal * 4.5,
                                  fontWeight: FontWeight.w800),
                            )
                          : CircularProgressIndicator();
                    }),
                // )

                // Container(
                //     child: buildFuture(
                //   widget.client.totalEarnedFromCustomer,
                //   (snap) => Text(
                //     '\$${snap.data}',
                //     style: TextStyle(
                //         fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                //         fontWeight: FontWeight.w800),
                //   ),
                // )),
              ]),
            ),
          ],
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
                child: Text('Default Switch Statement'),
              ));
          }
        });
  }
}

class NotesWidget extends StatefulWidget {
  final Client client;
  NotesWidget({@required this.client});
  @override
  _NotesWidgetState createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  TextEditingController _noteTextController = TextEditingController();

  bool textDidChange() =>
      _noteTextController.text == widget.client.note ? false : true;

  @override
  void initState() {
    super.initState();
    _noteTextController.text = widget.client.note;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: 20,
                left: 20,
              ),
              child: Text(
                'Customer Notes',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeConfig.safeBlockHorizontal * 5.5,
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                    color: Colors.black,
                  ))),
                  controller: _noteTextController,
                  style:
                      TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
                  maxLines: 10,
                )),
            Container(
              margin: EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              child: RaisedButton(
                onPressed: () {
                  bool didChange = textDidChange();
                  if (didChange) {
                    widget.client.note = _noteTextController.text;
                    widget.client.reference
                        .update({'note': widget.client.note});
                  }
                },
                child: Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HistoryEventTile extends StatelessWidget {
  final HistoryEvent historyEvent;
  HistoryEventTile({@required this.historyEvent});
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      // margin: EdgeInsets.only(bottom: 5),
      height: SizeConfig.safeBlockVertical * 6.4,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: Container(
              width: SizeConfig.safeBlockHorizontal * 3,
              // height: 60,
              color: historyEvent.isConfirmed ? Colors.green : Colors.yellow,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal * 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      historyEvent.formattedDate,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 4.5),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        right: SizeConfig.safeBlockHorizontal * 6),
                    child: Text(
                      '\$${historyEvent.fee}',
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
