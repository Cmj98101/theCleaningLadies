import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/addAppointment.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/Widgets/CalendarWidget/calendar.dart';
import 'package:flutter/services.dart';

class ScheduleSummary extends StatefulWidget {
  final List<TimeTile> appointments;
  final DateTime selectedDay;
  final Admin admin;
  ScheduleSummary(this.appointments, this.selectedDay, this.admin);

  @override
  _ScheduleSummaryState createState() => _ScheduleSummaryState();
}

class _ScheduleSummaryState extends State<ScheduleSummary> {
  bool showUnconfirmed = false;
  bool sendingInProgress = false;
  bool showOnlyConfirmedAppointments = false;
  @override
  Widget build(BuildContext context) {
    widget.appointments
        .sort((date1, date2) => date1.time.compareTo(date2.time));
    String formattedSelectedDate =
        DateFormat('M/d/yy').format(widget.selectedDay);

    Map weekDays = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    String day = weekDays[widget.selectedDay.weekday];

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Summary \n$day $formattedSelectedDate',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17),
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  if (showOnlyConfirmedAppointments) {
                    setState(() {
                      showOnlyConfirmedAppointments = false;
                    });
                  } else {
                    setState(() {
                      showOnlyConfirmedAppointments = true;
                    });
                  }
                },
                child: Icon(
                  showOnlyConfirmedAppointments == true
                      ? Icons.close
                      : Icons.remove_red_eye,
                  size: 34,
                )),
            FlatButton(
                onPressed: () {
                  if (showUnconfirmed) {
                    setState(() {
                      showUnconfirmed = false;
                    });
                  } else {
                    sendAutoReminderPressed();
                  }
                },
                child: Icon(
                  showUnconfirmed == true ? Icons.close : Icons.speaker_phone,
                  size: 34,
                )),
          ],
        ),
        body: ListView(
          children: [
            !showUnconfirmed
                ? Container()
                : Container(
                    margin: EdgeInsets.all(10),
                    child: RaisedButton(
                      onPressed: sendingInProgress
                          ? null
                          : () {
                              setState(() {
                                sendingInProgress = true;
                              });
                              for (TimeTile timeTile in widget.appointments) {
                                Appointment appointment = timeTile.appointment;

                                if (appointment != null &&
                                    appointment.isConfirmed != true &&
                                    appointment.isReminderSent == false) {
                                  if (appointment.sendConfirmation == true) {
                                    print(
                                        'Sending Reminders to : ${appointment.appointmentId}');

                                    widget.admin.sendAutoReminder(appointment,
                                        (res) {
                                      if (res == true) {
                                        setState(() {
                                          appointment.isReminderSent = true;
                                        });
                                        return showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              'Reminder Successfully Sent for ${appointment.eventName}',
                                              textAlign: TextAlign.center,
                                            ),
                                            actions: [
                                              RaisedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('Ok'),
                                              )
                                            ],
                                          ),
                                        );
                                      } else {
                                        setState(() {
                                          appointment.isReminderSent = false;
                                        });
                                        return showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              'Reminder Could Not Be Sent For ${appointment.eventName}',
                                              textAlign: TextAlign.center,
                                            ),
                                            actions: [
                                              RaisedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('Ok'),
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    });
                                  }
                                } else {
                                  print(
                                      'Cant Send Message to ${appointment?.appointmentId ?? 'Null'}');
                                }
                              }
                            },
                      child: sendingInProgress
                          ? CircularProgressIndicator()
                          : Text('Send Reminder'),
                    ),
                  ),
            for (TimeTile timeTile in widget.appointments)
              (timeTile.appointment?.clientReference ?? '') != ''
                  ? Container(
                      margin: EdgeInsets.all(10),
                      child: Card(
                          elevation: 5,
                          child: Stack(
                            children: [
                              Container(
                                child: FutureBuilder(
                                    future: timeTile.appointment.getClientData(
                                        timeTile.appointment.clientReference),
                                    builder:
                                        (context, AsyncSnapshot<Client> snap) {
                                      switch (snap.connectionState) {
                                        case ConnectionState.waiting:
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                          break;
                                        case ConnectionState.done:
                                          Client client = snap.data;
                                          Appointment appointment =
                                              timeTile.appointment;
                                          appointment.getIsReminderSent();

                                          return InkWell(
                                            onTap: () {
                                              String reminderMessage = """
Hello ${client.firstName},

This is just your reminder text that the Cleaning Ladies will be stopping by ${appointment.fromMonth} ${appointment.from.day}, ${appointment.day} 
@ ~${appointment.fromTimeFormatted} - ${appointment.toTimeFormatted}

Please confirm, Thank you in advance!
""";
                                              Clipboard.setData(ClipboardData(
                                                      text: reminderMessage))
                                                  .then((result) {
                                                final snackBar = SnackBar(
                                                  content: Text(
                                                      'Copied to Clipboard'),
                                                  action: SnackBarAction(
                                                    label: 'Undo',
                                                    onPressed: () {},
                                                  ),
                                                );
                                                Scaffold.of(context)
                                                    .showSnackBar(snackBar);
                                              });
                                            },
                                            onLongPress: () {
                                              DateTime clientSnapLastCleaning =
                                                  client.lastCleaning;
                                              DateTime appointmentFromDate =
                                                  timeTile.appointment.from;
                                              bool isTheSameLastCleaning =
                                                  DateTime(
                                                          clientSnapLastCleaning
                                                              .year,
                                                          clientSnapLastCleaning
                                                              .month,
                                                          clientSnapLastCleaning
                                                              .day)
                                                      .isAtSameMomentAs(
                                                          DateTime(
                                                appointmentFromDate.year,
                                                appointmentFromDate.month,
                                                appointmentFromDate.day,
                                              ));
                                              if (isTheSameLastCleaning) {
                                                return showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          title: Text(
                                                            'Last Cleaning Date',
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          content: Text(
                                                            'Updated Already \nto\n${appointment.fromDateFormatted}',
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          actions: [
                                                            RaisedButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child: Text('Ok'),
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          ],
                                                        ));
                                              } else {
                                                client.setLastCleaning(
                                                    timeTile.appointment.from,
                                                    () {
                                                  setState(() {
                                                    appointment.client
                                                            .lastCleaning =
                                                        timeTile
                                                            .appointment.from;
                                                  });

                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title: Text(
                                                              'Updated Last Cleaning\nTo',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            content: Text(
                                                              '${appointment.fromDateFormatted}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            actions: [
                                                              RaisedButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child:
                                                                    Text('Ok'),
                                                                color: Colors
                                                                    .green,
                                                              )
                                                            ],
                                                          ));
                                                });
                                              }
                                            },
                                            child: Stack(
                                              children: [
                                                !showUnconfirmed
                                                    ? Container()
                                                    : Container(
                                                        width: 40,
                                                        height: 80,
                                                        color: appointment
                                                                .isConfirmed
                                                            ? Colors.white
                                                            : Colors.yellow,
                                                        child: appointment
                                                                .isConfirmed
                                                            ? Container()
                                                            : Checkbox(
                                                                tristate: false,
                                                                value: appointment
                                                                            ?.isReminderSent ??
                                                                        false
                                                                    ? false
                                                                    : appointment
                                                                        .sendConfirmation,
                                                                onChanged:
                                                                    (val) {
                                                                  if (appointment
                                                                          ?.isReminderSent ??
                                                                      false) {
                                                                    return showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) =>
                                                                              AlertDialog(
                                                                        title:
                                                                            Text(
                                                                          'Reminder Sent Already!',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                        content:
                                                                            Text(
                                                                          'Reminder has already been sent and is pending a reply.',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                        actions: [
                                                                          RaisedButton(
                                                                              child: Text('Okay'),
                                                                              color: Colors.red,
                                                                              onPressed: () => Navigator.pop(context))
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }
                                                                  setState(() {
                                                                    appointment
                                                                            .sendConfirmation =
                                                                        val;
                                                                  });
                                                                }),
                                                      ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.all(10),
                                                  height: 60,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              '${client?.firstName ?? ''}${client.lastName.isEmpty ? '' : ', ${(client?.lastName[0]) ?? ''}.'}',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10),
                                                            child: Text(
                                                              '${appointment.formattedAppointmentTimeComplete} - ${client.city}',
                                                              style: TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  backgroundColor:
                                                                      Colors.yellow[
                                                                          300],
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          break;
                                        default:
                                          return Container();
                                      }
                                    }),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                    margin: EdgeInsets.only(right: 15, top: 5),
                                    child: Row(
                                      children: [
                                        timeTile.appointment.note.isNotEmpty
                                            ? Container(
                                                child: InkWell(
                                                  onTap: () {
                                                    String note = timeTile
                                                        .appointment.note;

                                                    return showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                              title:
                                                                  Text('NOTE:'),
                                                              content:
                                                                  Text(note),
                                                              actions: [
                                                                RaisedButton(
                                                                    color: Colors
                                                                        .green,
                                                                    child: Text(
                                                                        'OKAY'),
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context))
                                                              ],
                                                            ));
                                                  },
                                                  child: Icon(
                                                    Icons.note,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        timeTile.appointment?.keyRequired ??
                                                false
                                            ? Padding(
                                                padding:
                                                    EdgeInsets.only(right: 15))
                                            : Container(),
                                        timeTile.appointment?.keyRequired ??
                                                false
                                            ? Container(
                                                child: Icon(
                                                  Icons.vpn_key,
                                                  color: Colors.green,
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    )),
                              ),
                            ],
                          )),
                    )
                  : showOnlyConfirmedAppointments
                      ? Container()
                      : Container(
                          margin: EdgeInsets.all(10),
                          child: Card(
                              elevation: 5,
                              child: Container(
                                margin: EdgeInsets.all(10),
                                height: 60,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Text(
                                        '${timeTile.fromTimeFormatted}-${timeTile.toTimeFormatted}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        )
          ],
        ));
  }

  void sendAutoReminderPressed() {
    // widget.appointments.rem((timeTile) =>
    //     timeTile.appointment == null || timeTile.appointment.isConfirmed
    //         ? true
    //         : false);
    setShowUnconfirmed();
  }

  setShowOnlyConfirmed() {
    setState(() {
      showOnlyConfirmedAppointments = true;
    });
  }

  void setShowUnconfirmed() {
    setState(() {
      showUnconfirmed = true;
    });
  }

  void showSendReminderButton() {}
}
