import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/service/service.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/models/time_tile/time_title.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/my_services/my_services.dart';
import 'package:the_cleaning_ladies/src/admin/views/selectClientForAppointment.dart';

class DisplayAvailableTimesWidget extends StatefulWidget {
  final List<TimeTile> availableTimes;
  final Function(DateTime) rescheduleDateTime;
  final bool quickSchedule;
  final Function(List<TimeTile>) appointmentsToConfirm;
  final Admin admin;
  DisplayAvailableTimesWidget(this.availableTimes, this.quickSchedule,
      {@required this.rescheduleDateTime,
      this.appointmentsToConfirm,
      @required this.admin});

  @override
  _DisplayAvailableTimesWidgetState createState() =>
      _DisplayAvailableTimesWidgetState();
}

class _DisplayAvailableTimesWidgetState
    extends State<DisplayAvailableTimesWidget> {
  Client client;
  List<TimeTile> appointmentsToConfirm = [];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SizeConfig.screenWidth < 600 ? phoneDisplay() : tabletDisplay();
  }

  List<Widget> list() {
    List<Widget> listOfWidget = [];

    for (var i = 0; i < widget.availableTimes.length; i++) {
      List<TimeTile> availableTimes = widget.availableTimes;
      TimeTile time = availableTimes[i];
      listOfWidget.add(time?.timeSlotTaken ?? false
          ? Container(
              margin: EdgeInsets.only(top: 10, right: 15, left: 15),
              alignment: Alignment.center,
              child: Card(
                  // color: time.color,
                  elevation: 3,
                  child: InkWell(
                    onTap: time.timeSlotTaken
                        ? null
                        : () {
                            for (var tile in widget.availableTimes) {
                              tile.color = Colors.white;
                            }
                            setState(() {
                              time.color = Colors.green;
                              widget.rescheduleDateTime(time.time);
                            });
                          },
                    onLongPress: time.undoAvailable
                        ? () {
                            print('doubleTAPPED');
                            setState(() {
                              time.reset();
                              appointmentsToConfirm = [];
                              widget
                                  .appointmentsToConfirm(appointmentsToConfirm);
                            });
                          }
                        : null,
                    child: Container(
                      width: SizeConfig.safeBlockHorizontal * 74,
                      // height: SizeConfig.safeBlockVertical * 10,
                      child: ExpansionServiceTile(time: time),
                    ),
                  )))
          : Container(
              width: SizeConfig.safeBlockHorizontal * 75,
              height: SizeConfig.safeBlockVertical * 10,
              margin: EdgeInsets.only(top: 10, right: 15, left: 15),
              alignment: Alignment.center,
              child: Card(
                  color: time.color,
                  elevation: 3,
                  child: InkWell(
                    onTap: time?.timeSlotTaken ?? false
                        ? null
                        : widget.quickSchedule
                            ? () async {
                                client = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SelectClientForAppointment(
                                              admin: widget.admin,
                                            )));
                                print(client?.firstName ?? 'Null First Name');
                                if (client != null) {
                                  time.appointment = Appointment(
                                      client?.firstAndLastFormatted,
                                      time.time,
                                      time.time.add(Duration(minutes: 45)),
                                      Colors.green,
                                      false,
                                      client,
                                      isConfirmed: false,
                                      isRescheduling: false,
                                      noReply: false,
                                      serviceCost: client.costPerCleaning,
                                      keyRequired: client.keyRequired,
                                      note: client.note,
                                      admin: widget.admin);
                                  setState(() {
                                    time
                                      ..timeSlotTaken = true
                                      ..undoAvailable = true
                                      ..color = Colors.yellow;

                                    appointmentsToConfirm.add(time);

                                    widget.appointmentsToConfirm(
                                        appointmentsToConfirm);
                                  });

                                  for (var i = 0;
                                      i < availableTimes.length;
                                      i++) {
                                    if (availableTimes[i].timeSlotTaken !=
                                            null &&
                                        availableTimes[i].timeSlotTaken) {
                                      int addedMinutes = 0;
                                      availableTimes[i]
                                          .appointment
                                          .services
                                          .forEach((service) {
                                        if (service.selected) {
                                          addedMinutes +=
                                              service.duration.inMinutes;
                                        }
                                      });
                                      // availableTimes[i + 1].reset();
                                      availableTimes[i + 1]
                                          .time
                                          .add(Duration(minutes: addedMinutes));
                                      print(availableTimes[i + 1].time.hour);
                                      continue;
                                    }
                                  }
                                }
                              }
                            : () {
                                for (var tile in widget.availableTimes) {
                                  tile.color = Colors.white;
                                }
                                setState(() {
                                  time.color = Colors.green;
                                  widget.rescheduleDateTime(time.time);
                                });
                              },
                    child: Container(
                      alignment: Alignment.center,
                      // margin: EdgeInsets.all(20),
                      width: SizeConfig.safeBlockHorizontal * 75,
                      height: SizeConfig.safeBlockVertical * 10,
                      child: Text(
                          '${time.fromTimeFormatted} - ${time.toTimeFormatted}',
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center),
                    ),
                  ))));
    }
    return listOfWidget;
  }

  Widget phoneDisplay() {
    return Column(mainAxisSize: MainAxisSize.max, children: list());
  }

  Widget tabletDisplay() {
    return Column(
      children: <Widget>[
        for (var time in widget.availableTimes)
          time?.timeSlotTaken ?? false
              ? Container(
                  margin: EdgeInsets.only(top: 10, right: 15, left: 15),
                  alignment: Alignment.center,
                  child: Card(
                      // color: time.color,
                      elevation: 3,
                      child: InkWell(
                        onTap: time.timeSlotTaken
                            ? null
                            : () {
                                for (var tile in widget.availableTimes) {
                                  tile.color = Colors.white;
                                }
                                setState(() {
                                  time.color = Colors.green;
                                  widget.rescheduleDateTime(time.time);
                                });
                              },
                        onDoubleTap: time.undoAvailable
                            ? () {
                                print('doubleTAPPED');
                                setState(() {
                                  time.reset();
                                  appointmentsToConfirm = [];
                                  widget.appointmentsToConfirm(
                                      appointmentsToConfirm);
                                });
                              }
                            : null,
                        child: Container(
                          width: SizeConfig.safeBlockHorizontal * 85,
                          height: SizeConfig.safeBlockVertical * 10,
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                top: 0,
                                left: 0,
                                bottom: 0,
                                child: Container(
                                  width: 15,
                                  color: time.timeSlotTaken
                                      ? time.color
                                      : Colors.white,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  margin: EdgeInsets.all(40),
                                  width: SizeConfig.safeBlockHorizontal * 83,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                          '${time.fromTimeFormatted} - ${time.toTimeFormatted}',
                                          style: TextStyle(fontSize: 15),
                                          textAlign: TextAlign.center),
                                      Container(
                                        child: Text(
                                            '${time.appointment?.eventName ?? ''}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green),
                                            textAlign: TextAlign.center),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )))
              : Container(
                  width: SizeConfig.safeBlockHorizontal * 75,
                  height: SizeConfig.safeBlockVertical * 10,
                  margin: EdgeInsets.only(top: 10, right: 15, left: 15),
                  alignment: Alignment.center,
                  child: Card(
                      color: time.color,
                      elevation: 3,
                      child: InkWell(
                        onTap: time?.timeSlotTaken ?? false
                            ? null
                            : widget.quickSchedule
                                ? () async {
                                    client = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SelectClientForAppointment(
                                                  admin: widget.admin,
                                                )));
                                    print(
                                        client?.firstName ?? 'Null First Name');
                                    if (client != null) {
                                      time.appointment = Appointment(
                                          client.firstAndLastFormatted,
                                          time.time,
                                          time.time.add(Duration(minutes: 45)),
                                          Colors.green,
                                          false,
                                          client,
                                          isConfirmed: false,
                                          isRescheduling: false,
                                          noReply: false,
                                          serviceCost: client.costPerCleaning,
                                          keyRequired: client.keyRequired,
                                          note: client.note,
                                          admin: widget.admin);
                                      setState(() {
                                        time
                                          ..timeSlotTaken = true
                                          ..undoAvailable = true
                                          ..color = Colors.yellow;

                                        appointmentsToConfirm.add(time);
                                        widget.appointmentsToConfirm(
                                            appointmentsToConfirm);
                                      });
                                    }
                                  }
                                : () {
                                    for (var tile in widget.availableTimes) {
                                      tile.color = Colors.white;
                                    }
                                    setState(() {
                                      time.color = Colors.green;
                                      widget.rescheduleDateTime(time.time);
                                    });
                                  },
                        child: Container(
                          alignment: Alignment.center,
                          // margin: EdgeInsets.all(20),
                          width: SizeConfig.safeBlockHorizontal * 75,
                          height: SizeConfig.safeBlockVertical * 10,
                          child: Text(
                              '${time.fromTimeFormatted} - ${time.toTimeFormatted}',
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center),
                        ),
                      ))),
      ],
    );
  }
}

class ExpansionServiceTile extends StatefulWidget {
  final TimeTile time;
  ExpansionServiceTile({@required this.time});
  @override
  _ExpansionServiceTileState createState() => _ExpansionServiceTileState();
}

class _ExpansionServiceTileState extends State<ExpansionServiceTile> {
  @override
  Widget build(BuildContext context) {
    TimeTile time = widget.time;
    Appointment appointment = time.appointment;
    List<Service> services = List<Service>.of(appointment.services);
    return Container(
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          bool isExpanded = appointment.isExpanded;
          setState(() {
            appointment.isExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
              headerBuilder: (context, isExpanded) {
                return ListTile(
                    title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        child: Text('${appointment?.eventName ?? ''}'),
                      ),
                    ),
                    Flexible(
                      // flex: 0,
                      child: Container(
                        child: Text(
                            '${time.fromTimeFormatted} - ${time.toTimeFormatted}'),
                      ),
                    ),
                  ],
                ));
              },
              body: Container(
                  height: 200,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      Service service = services[index];
                      return InkWell(
                        onTap: time.appointment.appointmentId != null
                            ? null
                            : () {
                                bool selected = service.selected;
                                setState(() {
                                  service.selected = !selected;
                                });
                              },
                        child: ServiceTile(
                          service: service,
                          onlyShowing: true,
                        ),
                      );
                    },
                    itemCount: services.length,
                  )),
              isExpanded: appointment.isExpanded)
        ],
      ),
    );
  }
}
