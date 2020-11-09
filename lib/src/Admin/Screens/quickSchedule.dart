import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/addAppointment.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/scheduleSummary.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/AppointmentRepo/appointmentRepo.dart';
import 'package:the_cleaning_ladies/src/Widgets/CalendarWidget/calendar.dart';
import 'package:the_cleaning_ladies/src/Widgets/PresetWidget.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';

class QuickScheduleScreen extends StatefulWidget {
  final Admin admin;
  QuickScheduleScreen(this.admin);
  @override
  _QuickScheduleScreenState createState() => _QuickScheduleScreenState();
}

class _QuickScheduleScreenState extends State<QuickScheduleScreen> {
  DateTime selectedDate;
  bool dateSelected = false;
  bool startTimeSelected = false;
  DateTime timeToStart;
  AppointmentsRepository appointmentsRepository =
      FireBaseAppointmentsRepository();
  List<TimeTile> unconfirmedAppointments = [];
  List<TimeTile> listForSummary = [];
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Schedule'),
        actions: [
          FlatButton(
              onPressed: () {
                if (selectedDate != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleSummary(
                            listForSummary, selectedDate, widget.admin),
                      ));
                } else {
                  return showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('No Date & Time Selected!'),
                            content: Text(
                                'Please Select a Date & Time to view day summary.'),
                            actions: [
                              FlatButton(
                                color: Colors.green,
                                onPressed: () => Navigator.pop(context),
                                child: Text('Okay',
                                    style: TextStyle(color: Colors.white)),
                              )
                            ],
                          ));
                }
              },
              child: Icon(
                Icons.view_list,
                size: SizeConfig.safeBlockHorizontal * 5.5,
              )),
          FlatButton(
              onPressed: () {
                setState(() {
                  selectTime();
                });
              },
              child: Icon(
                Icons.av_timer,
                size: SizeConfig.safeBlockHorizontal * 5.5,
              )),
        ],
      ),
      body: quickScheduleBody(),
    );
  }

  Widget quickScheduleBody() {
    return ListView(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 15, right: 15, top: 20),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: ITextHeading('Select Date & Time'),
              ),
              Container(
                height: SizeConfig.safeBlockVertical * 50,
                child: SfDateRangePicker(
                  enablePastDates: false,
                  onSelectionChanged: (arg) {
                    setState(() {
                      startTimeSelected = false;
                      selectedDate = arg.value;
                      dateSelected = true;
                      unconfirmedAppointments = [];
                      selectTime();
                    });
                  },
                  selectionMode: DateRangePickerSelectionMode.single,
                ),
              ),
              !dateSelected || timeToStart == null
                  ? Container()
                  : startTimeSelected
                      ? Container(
                          child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                              Container(
                                child: ITextHeading(
                                  '@',
                                  fontSize:
                                      SizeConfig.safeBlockHorizontal * 6.5,
                                ),
                                alignment: Alignment.topLeft,
                              ),
                              Container(
                                  child: FutureBuilder(
                                future:
                                    appointmentsRepository.getAppointments(),
                                builder: (context,
                                    AsyncSnapshot<List<Appointment>> snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Center(
                                          child: CircularProgressIndicator());
                                      break;
                                    case ConnectionState.done:
                                      List<Appointment> reservedTimes =
                                          snapshot.data;
                                      reservedTimes.removeWhere((appointment) {
                                        DateTime from = appointment.from;
                                        DateTime appointmentDate = DateTime(
                                            from.year, from.month, from.day);
                                        if (appointmentDate != selectedDate) {
                                          return true;
                                        }
                                        return false;
                                      });
                                      List<TimeTile> availableTimes = [];

                                      for (var i = 0; i < 4; i++) {
                                        i == 0
                                            ? availableTimes.add(TimeTile(
                                                selectedDate
                                                    .add(Duration(
                                                        hours: timeToStart.hour,
                                                        minutes:
                                                            timeToStart.minute))
                                                    .add(
                                                        Duration(hours: 2 * i)),
                                              ))
                                            : availableTimes.add(TimeTile(
                                                selectedDate
                                                    .add(Duration(
                                                        hours: timeToStart.hour,
                                                        minutes:
                                                            timeToStart.minute))
                                                    .add(Duration(
                                                        hours: 2 * i,
                                                        minutes: 15 * i)),
                                              ));
                                      }
                                      availableTimes.forEach((timeTile) {
                                        for (int i = 0;
                                            i < reservedTimes.length;
                                            i++) {
                                          if (timeTile.time ==
                                              reservedTimes[i].from) {
                                            timeTile.timeSlotTaken = true;
                                            timeTile.appointment =
                                                reservedTimes[i];
                                            timeTile.color = Colors.green;
                                            reservedTimes.removeAt(i);
                                            break;
                                          } else {
                                            timeTile.timeSlotTaken = false;
                                          }
                                        }
                                      });
                                      if (reservedTimes.length != 0) {
                                        for (var reserved in reservedTimes) {
                                          availableTimes.add(TimeTile(
                                              reserved.from,
                                              appointment: reserved,
                                              timeSlotTaken: true,
                                              color: Colors.green));
                                        }
                                      }
                                      listForSummary = availableTimes;
                                      return DisplayAvailableTimesWidget(
                                        availableTimes,
                                        (DateTime from) {
                                          // widget.appointment.from = from;
                                          // widget.appointment.to =
                                          //     from.add(Duration(minutes: 45));
                                        },
                                        true,
                                        appointmentsToConfirm: (appointments) {
                                          // setState(() {
                                          unconfirmedAppointments =
                                              appointments;
                                          // });
                                        },
                                      );
                                      break;
                                    case ConnectionState.active:
                                      break;
                                    case ConnectionState.none:
                                      break;
                                    default:
                                      return Container();
                                  }
                                  return Container();
                                },
                              )),
                            ]))
                      : Container(),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width * .9,
                margin: EdgeInsets.only(bottom: 50),
                child: RaisedButton(
                  color: Colors.green,
                  onPressed: () => confirmSchedule(),
                  child: Text('Add To Schedule'),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void selectTime() async {
    TimeOfDay time = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.input,
        initialTime: TimeOfDay(hour: 7, minute: 0));
    if (time != null) {
      print(time.format(context));
      setState(() {
        startTimeSelected = true;
        timeToStart = DateTime(2020, 3, 10, time.hour, time.minute);
      });
    } else {
      print(time);
      setState(() {
        timeToStart = null;
      });
    }
  }

  void confirmSchedule() {
    if (unconfirmedAppointments.isNotEmpty) {
      setState(() {
        unconfirmedAppointments.forEach((timeTile) {
          widget.admin.createAppointment(timeTile.appointment);
        });
      });
    } else {
      print('No Appointments to Schedule');
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  'No Appointments to Schedule!',
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'Please add appointments to schedule.',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  RaisedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Ok'),
                    color: Colors.green,
                  )
                ],
              ));
    }
  }
}
