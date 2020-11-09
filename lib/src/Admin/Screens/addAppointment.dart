import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/selectClientForAppointment.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/AppointmentRepo/appointmentRepo.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/appointment_bloc.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/appointment_event.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/Widgets/CalendarWidget/calendar.dart';
import 'package:the_cleaning_ladies/src/Widgets/PresetWidget.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';

class AddAppointmentScreen extends StatefulWidget {
  final Admin admin;
  final Appointment appointment;
  final bool isRescheduling;
  AddAppointmentScreen(this.isRescheduling,
      {@required this.admin, this.appointment});
  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final formKey = GlobalKey<FormState>();
  AppointmentsRepository appointmentsRepository =
      FireBaseAppointmentsRepository();
  Client client = Client();
  DateTime selectedDate;
  bool startTimeSelected = false;
  DateTime timeToStart;
  bool clientSelected = false;
  bool dateSelected = false;
  bool validateAndSaveAppointmentForm() {
    var form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  submitNewAppointmentForm() {
    if (validateAndSaveAppointmentForm()) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    if (widget.isRescheduling) {
      clientSelected = true;
    }
  }

  void createNewAppointment(Appointment appointment) {
    if (widget.isRescheduling) {
      appointment.client = client;
      appointment.isConfirmed = false;
      appointment.isRescheduling = false;
      appointment.noReply = false;

      BlocProvider.of<AppointmentBloc>(context)
          .add(UpdateAppointmentEvent(appointment));
      Navigator.pop(context, appointment);
    } else {
      appointment.client = client;
      appointment.isConfirmed = false;
      appointment.isRescheduling = false;
      appointment.noReply = false;
      appointment.cleaningCost = client.costPerCleaning;
      appointment.note = client.note;
      widget.admin.createAppointment(appointment);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Appointment appointment = Appointment.newAppointment();
    if (widget.isRescheduling) {
      setState(() {
        client = widget.appointment.client;
        clientSelected = true;
      });
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          clientSelected
              ? FlatButton(
                  onPressed: () {
                    setState(() {
                      selectTime();
                    });
                  },
                  child: Icon(Icons.av_timer))
              : Container(),
        ],
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          widget.isRescheduling ? 'Rescheduling' : 'Add Appointment',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
          margin: EdgeInsets.only(left: 15, right: 15, top: 20),
          child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: ITextHeading(widget.isRescheduling
                          ? 'Customer'
                          : 'Select Customer'),
                      alignment: Alignment.centerLeft,
                    ),
                    widget.isRescheduling
                        ? ListTile(
                            title:
                                Text(widget.appointment.eventName.toString()),
                            subtitle: Text(
                                '${widget.appointment.formattedAppointmentDateTime}'),
                          )
                        : clientSelected
                            ? ListTile(
                                title: Text(
                                    '${client?.firstName ?? ''} ${client?.lastName ?? ''} '),
                                subtitle: Text(
                                    'Last Cleaning: ${clientSelected ? (client?.formattedLastCleaning ?? '') : ''} -> ${clientSelected ? (client?.nextCleaning ?? '') : ''}'),
                                onTap: () async {
                                  Client _client = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SelectClientForAppointment()));
                                  setState(() {
                                    if (_client != null) {
                                      client = _client;
                                      clientSelected = true;
                                    }
                                  });
                                },
                              )
                            : Container(
                                // width: 400,
                                height: 70,
                                child: Card(
                                  child: InkWell(
                                    onTap: () async {
                                      Client _client = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SelectClientForAppointment()));
                                      // Client _client = await Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             SelectClientForAppointment()));
                                      setState(() {
                                        if (_client != null) {
                                          client = _client;
                                          clientSelected = true;
                                        }
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Select Client',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    !clientSelected
                        ? Container()
                        : Container(
                            child: ITextHeading('Select Date & Time'),
                            alignment: Alignment.centerLeft,
                          ),
                    !clientSelected
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(top: 20),
                          ),
                    !clientSelected
                        ? Container()
                        : SfDateRangePicker(
                            // enablePastDates: false,
                            onSelectionChanged: (arg) {
                              setState(() {
                                startTimeSelected = false;

                                selectedDate = arg.value;
                                dateSelected = true;
                                selectTime();
                              });
                            },
                            selectionMode: DateRangePickerSelectionMode.single,
                          ),
                    !dateSelected
                        ? Container()
                        : startTimeSelected
                            ? Container(
                                child: Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                    Container(
                                      child: ITextHeading(
                                        '@',
                                        fontSize:
                                            SizeConfig.safeBlockHorizontal *
                                                6.5,
                                      ),
                                      alignment: Alignment.topLeft,
                                    ),
                                    Container(
                                        child: FutureBuilder(
                                      future: appointmentsRepository
                                          .getAppointments(),
                                      builder: (context,
                                          AsyncSnapshot<List<Appointment>>
                                              snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.waiting:
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                            break;
                                          case ConnectionState.done:
                                            List<Appointment> reservedTimes =
                                                snapshot.data;
                                            reservedTimes
                                                .removeWhere((appointment) {
                                              DateTime from = appointment.from;
                                              DateTime appointmentDate =
                                                  DateTime(from.year,
                                                      from.month, from.day);
                                              if (appointmentDate !=
                                                  selectedDate) {
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
                                                              hours: timeToStart
                                                                  .hour,
                                                              minutes:
                                                                  timeToStart
                                                                      .minute))
                                                          .add(Duration(
                                                              hours: 2 * i)),
                                                    ))
                                                  : availableTimes.add(TimeTile(
                                                      selectedDate
                                                          .add(Duration(
                                                              hours: timeToStart
                                                                  .hour,
                                                              minutes:
                                                                  timeToStart
                                                                      .minute))
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
                                                  timeTile.timeSlotTaken =
                                                      false;
                                                }
                                              }
                                            });
                                            if (reservedTimes.length != 0) {
                                              for (var reserved
                                                  in reservedTimes) {
                                                availableTimes.add(TimeTile(
                                                    reserved.from,
                                                    appointment: reserved,
                                                    timeSlotTaken: true,
                                                    color: Colors.green));
                                              }
                                            }
                                            return DisplayAvailableTimesWidget(
                                                availableTimes,
                                                (DateTime from) {
                                              if (widget.isRescheduling ==
                                                  false) {
                                                appointment.eventName =
                                                    '${client?.firstName ?? ''}${client.lastName.isEmpty ? '' : ','} ${client.lastName.isEmpty ? '' : '${(client?.lastName[0]) ?? ''}.'}';
                                                appointment.from = from;
                                                appointment.to = from
                                                    .add(Duration(minutes: 45));
                                              } else {
                                                widget.appointment.note =
                                                    client.note;
                                                widget.appointment.from = from;
                                                widget.appointment.to = from
                                                    .add(Duration(minutes: 45));
                                              }
                                            }, false);
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
                      padding: EdgeInsets.only(top: 30),
                    ),
                    Container(
                      height: 65,
                      width: MediaQuery.of(context).size.width,
                      child: RaisedButton(
                        color: Colors.green[300],
                        onPressed: !dateSelected
                            ? null
                            : () => createNewAppointment(widget.isRescheduling
                                ? widget.appointment
                                : appointment),
                        child: Text('Create New Appointment'),
                      ),
                    )
                  ],
                ),
              ))),
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
      selectedDate = null;
    }
  }
}

class TimeTile {
  DateTime time;
  List<TimeTile> availableTimes;
  Color color = Colors.white;
  String get fromTimeFormatted => DateFormat('h:mm a').format(time);
  String get toTimeFormatted =>
      DateFormat('h:mm a').format(time.add(Duration(minutes: 45)));
  bool timeSlotTaken;
  Appointment appointment;
  bool undoAvailable = false;
  TimeTile(this.time, {this.appointment, this.timeSlotTaken, this.color});

  void reset() {
    timeSlotTaken = false;
    appointment = null;
    undoAvailable = false;
    color = Colors.white;
  }
}

class DisplayAvailableTimesWidget extends StatefulWidget {
  final List<TimeTile> availableTimes;
  final Function(DateTime) dateTime;
  final bool quickSchedule;
  final Function(List<TimeTile>) appointmentsToConfirm;
  DisplayAvailableTimesWidget(
      this.availableTimes, this.dateTime, this.quickSchedule,
      {this.appointmentsToConfirm});

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
                                  widget.dateTime(time.time);
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
                        child: Stack(
                          children: <Widget>[
                            Container(
                              width: 15,
                              height: 60,
                              color: time.timeSlotTaken
                                  ? time.color
                                  : Colors.white,
                            ),
                            Container(
                              margin: EdgeInsets.all(20),
                              width: SizeConfig.screenWidth > 600
                                  ? SizeConfig.safeBlockHorizontal * 83
                                  : SizeConfig.safeBlockHorizontal * 65,
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
                                            fontSize: 14, color: Colors.green),
                                        textAlign: TextAlign.center),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )))
              : Container(
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
                                                SelectClientForAppointment()));
                                    print(
                                        client?.firstName ?? 'Null First Name');
                                    if (client != null) {
                                      time.appointment = Appointment(
                                          '${client?.firstName ?? ''}${client.lastName.isEmpty ? '' : ', ${(client?.lastName[0]) ?? ''}.'}',
                                          time.time,
                                          time.time.add(Duration(minutes: 45)),
                                          Colors.green,
                                          false,
                                          client,
                                          isConfirmed: false,
                                          isRescheduling: false,
                                          noReply: false,
                                          cleaningCost: client.costPerCleaning,
                                          keyRequired: client.keyRequired,
                                          note: client.note);
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
                                      widget.dateTime(time.time);
                                    });
                                  },
                        child: Container(
                          margin: EdgeInsets.all(20),
                          width: SizeConfig.screenWidth > 600
                              ? SizeConfig.safeBlockHorizontal * 83
                              : SizeConfig.safeBlockHorizontal * 65,
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
