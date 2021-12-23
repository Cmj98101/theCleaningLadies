import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/appointment_event.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/time_tile/time_title.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/notification_model/push_notification.dart';
import 'package:the_cleaning_ladies/src/admin/views/QuickSchedule/quickSchedule.dart';
import 'package:the_cleaning_ladies/src/admin/views/QuickSchedule/selectClientForAppointment.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/AppointmentRepo/appointmentRepo.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/appointment_bloc.dart';
import 'package:the_cleaning_ladies/src/admin/views/MyClients/messageInbox.dart';
import 'package:the_cleaning_ladies/widgets/PresetWidget.dart';

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
  PushNotifications _pushNotifications;
  List<TimeTile> unconfirmedAppointments;

  AppointmentsRepository appointmentsRepository =
      FireBaseAppointmentsRepository();
  Client client = Client();
  DateTime selectedDate;
  bool startTimeSelected = false;
  DateTime timeToStart;
  bool clientSelected = false;
  bool dateSelected = false;

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
    setSelectedDate();

    if (widget.isRescheduling) {
      clientSelected = true;
    }
  }

  void setSelectedDate() {
    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
  }

  void createNewAppointment(dynamic appointment) {
    if (widget.isRescheduling) {
      appointment.client = client;
      appointment.isConfirmed = false;
      appointment.isRescheduling = false;
      appointment.noReply = false;

      BlocProvider.of<AppointmentBloc>(context)
          .add(UpdateAppointmentEvent(appointment, widget.admin));
      Navigator.pop(context, appointment);
    } else {
      // appointment.client = client;
      // appointment.isConfirmed = false;
      // appointment.isRescheduling = false;
      // appointment.noReply = false;
      // appointment.serviceCost = client.costPerCleaning;
      // appointment.note = client.note;
      unconfirmedAppointments.forEach((timeTile) {
        // widget.admin.createAppointment(timeTile.appointment);
        if (timeTile?.appointment != null) {
          BlocProvider.of<AppointmentBloc>(context)
              .add(AddAppointmentEvent(timeTile.appointment, widget.admin));
        }
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Appointment appointment = Appointment.newAppointment();
    int unconfirmedAppointmentSlots = 100;
    unconfirmedAppointments = List<TimeTile>(unconfirmedAppointmentSlots);
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
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: ITextHeading(
                      widget.isRescheduling ? 'Customer' : 'Select Customer'),
                  alignment: Alignment.centerLeft,
                ),
                widget.isRescheduling
                    ? ListTile(
                        title: Text(widget.appointment.eventName.toString()),
                        subtitle: Text(
                            '${widget.appointment.formattedAppointmentDateTime}'),
                      )
                    : clientSelected
                        ? ListTile(
                            title: Text(client.firstAndLastFormatted),
                            subtitle: Text(clientSelected
                                ? client?.lastAndNextService ?? ''
                                : ''),
                            onTap: () async => await selectClient(context),
                          )
                        : Container(
                            // width: 400,
                            height: 70,
                            child: Card(
                              child: InkWell(
                                onTap: () async => selectClient(context),
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
                        ? BuildAvailibilityView(
                            admin: widget.admin,
                            selectedDate: selectedDate,
                            timeToStart: timeToStart,
                            client: client,
                            isQuickSchedule: false,
                            unconfirmedAppointments: unconfirmedAppointments,
                            isRescheduling: widget.isRescheduling,
                            rescheduleDateTime: (from) {
                              appointment.from = from;
                              appointment.to = from.add(Duration(minutes: 45));
                            })
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
                        : () {
                            if (widget.isRescheduling) {
                              widget.appointment.from = appointment.from;
                              widget.appointment.to = appointment.to;
                            }

                            return createNewAppointment(widget.isRescheduling
                                ? widget.appointment
                                : unconfirmedAppointments);
                          },
                    child: Text(widget.isRescheduling
                        ? 'Reschedule'
                        : 'Create New Appointment'),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Future selectClient(BuildContext context) async {
    Client _client = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectClientForAppointment(
                  admin: widget.admin,
                )));
    setState(() {
      if (_client != null) {
        client = _client;
        clientSelected = true;
      }
    });
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
