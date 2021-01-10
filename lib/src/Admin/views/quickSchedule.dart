import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/time_tile/time_title.dart';
import 'package:the_cleaning_ladies/notifications/notifications.dart';
import 'package:the_cleaning_ladies/src/Admin/views/Settings/quickScheduleSettings.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/AppointmentRepo/appointmentRepo.dart';
import 'package:the_cleaning_ladies/src/Admin/views/messageInbox.dart';
import 'package:the_cleaning_ladies/src/Admin/views/scheduleSummary.dart';
import 'package:the_cleaning_ladies/widgets/PresetWidget.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/src/Admin/views/display_available_slots.dart';

class QuickScheduleScreen extends StatefulWidget {
  final Admin admin;
  QuickScheduleScreen(this.admin);
  @override
  _QuickScheduleScreenState createState() => _QuickScheduleScreenState();
}

enum QuickScheduleOptions { showSettings, showSummary, changeTime }

class _QuickScheduleScreenState extends State<QuickScheduleScreen> {
  DateTime selectedDate;
  bool dateSelected = false;
  bool startTimeSelected = false;
  DateTime timeToStart;
  PushNotifications _pushNotifications;
  AppointmentsRepository appointmentsRepository =
      FireBaseAppointmentsRepository();
  List<TimeTile> unconfirmedAppointments = [];
  List<TimeTile> listForSummary = [];

  @override
  void initState() {
    super.initState();

    _pushNotifications = PushNotifications(
        admin: widget.admin,
        context: context,
        isMounted: () => mounted,
        onNotification: (admin, client) async {
          return await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MessageInboxScreen(admin, client)));
        });
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
        title: Text('Quick Schedule'),
        actions: SizeConfig.screenWidth < 600
            ? [
                PopupMenuButton(
                  itemBuilder: (context) => <Map>[
                    {
                      'title': 'Show Settings',
                      'action': QuickScheduleOptions.showSettings
                    },
                    {
                      'title': 'Show Summary',
                      'action': QuickScheduleOptions.showSummary
                    },
                    {
                      'title': 'change Time',
                      'action': QuickScheduleOptions.changeTime
                    }
                  ]
                      .map<PopupMenuEntry<String>>((value) => PopupMenuItem(
                            child: FlatButton(
                              onPressed: () {
                                switch (value['action']) {
                                  case QuickScheduleOptions.showSettings:
                                    return Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                QuickScheduleDefaultSettings(
                                                    admin: widget.admin)));
                                    break;
                                  case QuickScheduleOptions.showSummary:
                                    // Navigator.pop(context);
                                    return onshowSummary();
                                    break;
                                  case QuickScheduleOptions.changeTime:
                                    // return onshowSummary();
                                    setState(() {
                                      selectTime();
                                    });
                                    break;
                                  default:
                                }
                              },
                              child: Container(child: Text(value['title'])),
                            ),
                          ))
                      .toList(),
                  // value: dropdownValue,
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                  // iconSize: 24,
                  // elevation: 16,
                  // style: TextStyle(color: Colors.deepPurple),
                  // underline: Container(
                  //   height: 2,
                  //   color: Colors.deepPurpleAccent,
                  // ),
                ),
              ]
            : [
                FlatButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuickScheduleDefaultSettings(
                                admin: widget.admin))),
                    child: Icon(Icons.settings)),
                FlatButton(
                    onPressed: () => onshowSummary(),
                    child: Icon(
                      Icons.view_list,
                      // size: SizeConfig.safeBlockHorizontal * 5.5,
                    )),
                FlatButton(
                    onPressed: () {
                      setState(() {
                        selectTime();
                      });
                    },
                    child: Icon(
                      Icons.av_timer,
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
                      ? BuildAvailibilityView(
                          admin: widget.admin,
                          selectedDate: selectedDate,
                          timeToStart: timeToStart,
                          isQuickSchedule: true,
                          onSummaryReady: (availableTimes) =>
                              listForSummary = availableTimes,
                          appointmentsToConfirm: (appointments) {
                            // setState(() {
                            unconfirmedAppointments = appointments;
                            // });
                          },
                        )
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
        selectedDate = null;
      });
    }
  }

  Future<void> onshowSummary() {
    if (selectedDate != null) {
      return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScheduleSummary(listForSummary, selectedDate, widget.admin),
          ));
    } else {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('No Date & Time Selected!'),
                content:
                    Text('Please Select a Date & Time to view day summary.'),
                actions: [
                  FlatButton(
                    color: Colors.green,
                    onPressed: () => Navigator.pop(context),
                    child: Text('Okay', style: TextStyle(color: Colors.white)),
                  )
                ],
              ));
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

class BuildAvailibilityView extends StatefulWidget {
  final Admin admin;
  final DateTime selectedDate;
  final DateTime timeToStart;
  final Function(DateTime) rescheduleDateTime;
  final Function(List<TimeTile>) onSummaryReady;
  final Function(List<TimeTile>) appointmentsToConfirm;
  final bool isQuickSchedule;
  BuildAvailibilityView(
      {@required this.selectedDate,
      @required this.timeToStart,
      @required this.admin,
      this.rescheduleDateTime,
      this.onSummaryReady,
      this.appointmentsToConfirm,
      @required this.isQuickSchedule});

  @override
  _BuildAvailibilityViewState createState() => _BuildAvailibilityViewState();
}

class _BuildAvailibilityViewState extends State<BuildAvailibilityView> {
  AppointmentsRepository appointmentsRepository =
      FireBaseAppointmentsRepository();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          Container(
            child: ITextHeading(
              '@',
              fontSize: SizeConfig.safeBlockHorizontal * 6.5,
            ),
            alignment: Alignment.topLeft,
          ),
          Container(
              child: FutureBuilder(
            future: appointmentsRepository.getAppointments(widget.admin),
            builder: (context, AsyncSnapshot<List<Appointment>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                  break;
                case ConnectionState.done:
                  List<Appointment> reservedTimes = snapshot.data;
                  assert(reservedTimes != null);
                  reservedTimes
                      .removeWhere((appointment) => checkDateSame(appointment));
                  List<TimeTile> availableTimes = [];
                  availableTimes = widget.admin.generateAvailabilities(
                      widget.selectedDate, widget.timeToStart, reservedTimes);

                  if (reservedTimes.length != 0) {
                    print('reserved Times != 0');
                    for (var reserved in reservedTimes) {
                      availableTimes.add(TimeTile(reserved.from,
                          appointment: reserved,
                          timeSlotTaken: true,
                          color: Colors.green));
                    }
                  }
                  if (widget.isQuickSchedule) {
                    widget.onSummaryReady(availableTimes);
                  }

                  return DisplayAvailableTimesWidget(
                    availableTimes,
                    widget.isQuickSchedule,
                    rescheduleDateTime: (DateTime from) {
                      widget.rescheduleDateTime(from);
                    },
                    appointmentsToConfirm: (appointments) =>
                        widget.appointmentsToConfirm(appointments),
                    admin: widget.admin,
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
        ]));
  }

  bool checkDateSame(Appointment appointment) {
    DateTime from = appointment.from;
    DateTime appointmentDate = DateTime(from.year, from.month, from.day);
    if (appointmentDate != widget.selectedDate) {
      return true;
    }
    return false;
  }
}
