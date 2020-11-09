import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/appointmentOnTapDetails.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/AppointmentRepo/appointmentRepo.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/appointment_bloc.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/appointment_event.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/appointment_state.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';

class CalendarWidget extends StatefulWidget {
  final Admin admin;
  final List<Appointment> futureAppointments;
  final bool viewFutureAppointments;
  CalendarWidget(this.admin,
      {this.viewFutureAppointments, this.futureAppointments});
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  AppointmentBloc _appointmentBloc =
      AppointmentBloc(appointmentsRepository: FireBaseAppointmentsRepository());
  void cancelAppointment(Appointment appointment) {
    BlocProvider.of<AppointmentBloc>(context)
      ..add(DeleteAppointmentEvent(appointment));
  }

  void updateAppointment(Appointment appointment) {
    BlocProvider.of<AppointmentBloc>(context)
      ..add(UpdateAppointmentEvent(appointment));
  }

  @override
  void dispose() {
    super.dispose();
    _appointmentBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return widget.viewFutureAppointments
        ? SfCalendar(
            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.appointment ||
                  details.targetElement == CalendarElement.agenda) {
                if (details.appointments.length <= 0) {
                  return print("No Appointment");
                }
                Appointment appointmentDetails = details.appointments[0];
              }
            },
            view: CalendarView.month,
            dataSource: _getCalendarDataSource(widget.futureAppointments),
            monthViewSettings: MonthViewSettings(
                showAgenda: true,
                appointmentDisplayMode:
                    MonthAppointmentDisplayMode.appointment),
          )
        : BlocBuilder<AppointmentBloc, AppointmentState>(
            cubit: _appointmentBloc..add(LoadAppointmentsEvent()),
            builder: (BuildContext context, AppointmentState state) {
              if (state is AppointmentsLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is AppointmentsLoaded) {
                return SfCalendar(
                  onTap: (CalendarTapDetails details) {
                    if (details.targetElement == CalendarElement.appointment ||
                        details.targetElement == CalendarElement.agenda) {
                      if (details.appointments.length <= 0) {
                        return print("No Appointment");
                      }
                      Appointment appointmentDetails = details.appointments[0];

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AppointmentOnTapDetailsScreen(
                                      appointmentDetails,
                                      widget.admin,
                                      cancelAppointment,
                                      updateAppointment)));
                    }
                  },
                  view: CalendarView.month,
                  dataSource: _getCalendarDataSource(state.appointments),
                  allowedViews: [
                    CalendarView.month,
                    CalendarView.day,
                  ],
                  monthViewSettings: MonthViewSettings(
                      showAgenda: true,
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment),
                );
              } else {
                return Container();
              }
            },
          );
  }

  int getCleaningInterval(CleaningFrequency cleaningFrequency) {
    int weeklyCleaning = 7;
    int biWeeklyCleaning = 14;
    int monthlyCleaning = 30;
    int customCleaning = 60;
    switch (cleaningFrequency) {
      case CleaningFrequency.weekly:
        return weeklyCleaning;
        break;
      case CleaningFrequency.biWeekly:
        return biWeeklyCleaning;
        break;
      case CleaningFrequency.monthly:
        return monthlyCleaning;
        break;
      case CleaningFrequency.custom:
        return customCleaning;
        break;
      default:
        print('unknown Cleaning Frequency');

        return 1;
    }
  }

  void addRecurrencePropertyToAppointment(List<Appointment> appointments) {
    RecurrenceProperties recurrence = new RecurrenceProperties();

    appointments.forEach((appointment) {
      recurrence.recurrenceType = RecurrenceType.daily;
      recurrence.recurrenceRange = RecurrenceRange.count;
      recurrence.interval =
          getCleaningInterval(appointment.client.cleaningFrequency);

      recurrence.recurrenceCount = 1;
      appointment.exceptionDates = [DateTime(2020, 8, 5)];
      List<DateTime> list = SfCalendar.getRecurrenceDateTimeCollection(
          SfCalendar.generateRRule(
              recurrence, appointment.from, appointment.to),
          appointment.from);
      list.forEach((date) {
        print(DateFormat('MM/dd/yyyy H:mm a').format(date));
      });
      return appointment.recurrenceRule = SfCalendar.generateRRule(
          recurrence, appointment.from, appointment.to);
    });
  }

  List<Appointment> checkForConfirmed(List<Appointment> appointments) {
    List<Appointment> confirmedAppointments = List.from(appointments);
    confirmedAppointments
        .removeWhere((appointment) => !appointment.isConfirmed);
    return confirmedAppointments;
  }

  bool confirmedAppointmentDatePassed(Appointment appointment) {
    return appointment.fromDateOnly.isAfter(DateTime.now());
  }

  void updateLastCleaning(Appointment appointment) {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    var _client = _db.doc(appointment.clientReference);
    _client.get().then((documentSnap) {
      if (documentSnap.exists) {
        Client client = Client.fromMap(documentSnap.data());
        if (client.lastCleaningDateOnly
            .isAtSameMomentAs(appointment.fromDateOnly)) {
          // print('No Need to change ${appointment.appointmentId}');
          return;
        }
        bool isAfter = appointment.from.isAfter(client.lastCleaningDateOnly);

        if (isAfter) {
          print(
              '${client.lastCleaningDateOnly} isAfter ${appointment.from} changing ${client.firstName}');
          _client.update({'lastCleaning': appointment.from});
        } else {
          // print(
          //     'No Need to change because ... ${appointment.from} not after ${client.lastCleaningDateOnly} :  ${appointment.eventName}');
        }
        return;
      } else {
        print('${appointment.clientReference} does not exist');
      }
    });
  }

  AppointmentDataSource _getCalendarDataSource(List<Appointment> appointments) {
    // addRecurrencePropertyToAppointment(appointments);
    if (widget.viewFutureAppointments) {
    } else {
      List<Appointment> confirmedAppointments = checkForConfirmed(appointments);
      confirmedAppointments.forEach((appointment) {
        if (!confirmedAppointmentDatePassed(appointment)) {
          updateLastCleaning(appointment);
        }
      });
    }

    return AppointmentDataSource(appointments);
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }

  @override
  String getRecurrenceRule(int index) {
    return appointments[index].recurrenceRule;
  }

  @override
  List<DateTime> getRecurrenceExceptionDates(int index) {
    return appointments[index].exceptionDates;
  }
}

class Appointment {
  Appointment(this.eventName, this.from, this.to, this.background,
      this.isAllDay, this.client,
      {this.appointmentId,
      this.recurrenceRule,
      this.isConfirmed,
      this.isRescheduling,
      this.noReply,
      this.clientReference,
      this.contactNumber,
      this.sendConfirmation,
      this.isReminderSent,
      this.cleaningCost,
      this.keyRequired,
      this.note});
  Appointment.newAppointment(
      {this.eventName,
      this.from,
      this.to,
      this.background,
      this.isAllDay,
      this.client,
      this.appointmentId,
      this.recurrenceRule,
      this.exceptionDates,
      this.isConfirmed,
      this.contactNumber,
      this.note});
  Client client;
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String appointmentId;
  String recurrenceRule;
  String clientReference;
  String contactNumber;
  String note;
  bool isConfirmed;
  bool isRescheduling;
  bool noReply;
  bool keyRequired;
  int cleaningCost;
  // ignore: slash_for_doc_comments
  /**  
   *If true then send a reminder text
   *      
   *      if(sendConfirmation){ 
   *        sendReminderText(); // Sending Reminder Text...
   *      }
   * 
  */
  bool sendConfirmation = true;
  bool isReminderSent = false;
  List<DateTime> exceptionDates;

  DateTime get fromDateOnly => DateTime(from.year, from.month, from.day);
  bool checkInTheWeek(DateTime start, DateTime end) {
    bool isBefore = fromDateOnly.isBefore(start);
    bool isAfter = fromDateOnly.isAfter(end);
    return isBefore == false && isAfter == false ? false : true;
  }

  Map month = {
    1: 'Jan.',
    2: 'Feb.',
    3: 'Mar.',
    4: 'Apr.',
    5: 'May',
    6: 'Jun.',
    7: 'Jul.',
    8: 'Aug.',
    9: 'Sep.',
    10: 'Oct.',
    11: 'Nov.',
    12: 'Dec.',
  };
  Map weekDays = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };
  String get getMsgReadyFullDateTime =>
      '$fromMonth ${from.day}, $day @ ~$fromTimeFormatted - $toTimeFormatted';
  String get day => weekDays[from.weekday];
  String get fromMonth => month[from.month];
  String get toMonth => month[to.month];
  String get fromFullyFormatted => DateFormat('MM/dd/yy h:mm a').format(from);
  String get toFullyFormatted => DateFormat('MM/dd/yy h:mm a').format(to);
  String get fromDateFormatted => DateFormat('MM/dd/yy').format(from);
  String get toDateFormatted => DateFormat('MM/dd/yy').format(to);
  String get fromTimeFormatted => DateFormat('h:mm a').format(from);
  String get toTimeFormatted => DateFormat('h:mm a').format(to);
  String get formattedAppointmentDateTime =>
      '$fromDateFormatted \n@ $fromTimeFormatted - $toTimeFormatted';
  String get formattedAppointmentTimeComplete =>
      '@ $fromTimeFormatted - $toTimeFormatted';

  Future<Client> getClientData(String ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snap = await db.doc(ref).get();
    // print(snap.data()['businessCode']);
    return Client.fromMap(snap.data());
  }

  Future<void> getIsReminderSent() async {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    DocumentSnapshot appointmentSnap =
        await _db.doc('Appointments/$appointmentId').get();
    Map<String, dynamic> data = appointmentSnap.data();
    isReminderSent = data['isReminderSent'];
  }

  factory Appointment.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> doc = document.data();
    Client client = Client();
    CleaningFrequency cleaningFrequency =
        client.cleaningFrequencyFromDoc(document);
    return Appointment(
        '${doc['eventName']}',
        (doc['from'] as Timestamp).toDate(),
        (doc['to'] as Timestamp).toDate(),
        doc['isConfirmed']
            ? Colors.green
            : doc['isRescheduling']
                ? Colors.yellow[700]
                : Colors.red,
        false,
        Client(
          id: doc['clientId'],
          cleaningFrequency: cleaningFrequency,
          contactNumber: doc['contactNumber'],
        ),
        clientReference: doc['clientReference'],
        appointmentId: document.id,
        isConfirmed: doc['isConfirmed'],
        isRescheduling: doc['isRescheduling'],
        noReply: doc['noReply'],
        sendConfirmation: true,
        isReminderSent: doc['isReminderSent'],
        cleaningCost: doc['cleaningCost'],
        keyRequired: doc['keyRequired'],
        note: doc['note'] ?? '');
  }
  Map<String, Object> toDocument() => {
        'eventName':
            '${client?.firstName ?? ''}${client.lastName.isEmpty ? '' : ', ${(client?.lastName[0]) ?? ''}.'}',
        'from': from,
        'to': to,
        'isAllDay': false,
        'clientId': "${client.id}",
        'clientReference': 'Users/${client.id}',
        'cleaningFrequency': '${client.cleaningFrequency.toString()}',
        'isConfirmed': isConfirmed,
        'isRescheduling': isRescheduling,
        'noReply': noReply,
        'contactNumber': client.contactNumber,
        'isReminderSent': false,
        'cleaningCost': cleaningCost,
        'keyRequired': keyRequired,
        'note': note
      };
  factory Appointment.demo() {
    return Appointment(
      'eventName',
      DateTime.now(),
      DateTime.now(),
      Colors.red,
      false,
      Client(
        firstName: 'firstName',
        lastName: 'lastName',
        id: 'clientId',
        cleaningFrequency: CleaningFrequency.monthly,
        contactNumber: 'contactNumber',
      ),
      clientReference: 'clientReference',
      appointmentId: 'document.id',
      isConfirmed: false,
      isRescheduling: false,
      noReply: false,
      sendConfirmation: true,
      isReminderSent: false,
      cleaningCost: 1,
      keyRequired: false,
    );
  }
}
