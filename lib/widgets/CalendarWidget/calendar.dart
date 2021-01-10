import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sf;
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/src/Admin/views/appointmentOnTapDetails.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/AppointmentRepo/appointmentRepo.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/appointment_bloc.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/appointment_event.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/appointment_state.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';

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
      ..add(DeleteAppointmentEvent(appointment, widget.admin));
  }

  void updateAppointment(Appointment appointment) {
    BlocProvider.of<AppointmentBloc>(context)
      ..add(UpdateAppointmentEvent(appointment, widget.admin));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _appointmentBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return widget.viewFutureAppointments
        ? sf.SfCalendar(
            onTap: (sf.CalendarTapDetails details) {
              if (details.targetElement == sf.CalendarElement.appointment ||
                  details.targetElement == sf.CalendarElement.agenda) {
                if (details.appointments.length <= 0) {
                  return print("No Appointment");
                }
                Appointment appointmentDetails = details.appointments[0];
              }
            },
            view: sf.CalendarView.month,
            dataSource: _getCalendarDataSource(widget.futureAppointments),
            monthViewSettings: sf.MonthViewSettings(
                showAgenda: true,
                appointmentDisplayMode:
                    sf.MonthAppointmentDisplayMode.appointment),
          )
        : BlocBuilder<AppointmentBloc, AppointmentState>(
            cubit: _appointmentBloc..add(LoadAppointmentsEvent(widget.admin)),
            builder: (BuildContext context, AppointmentState state) {
              if (state is AppointmentsLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is AppointmentsLoaded) {
                return sf.SfCalendar(
                  onTap: (sf.CalendarTapDetails details) {
                    if (details.targetElement ==
                            sf.CalendarElement.appointment ||
                        details.targetElement == sf.CalendarElement.agenda) {
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
                  view: sf.CalendarView.month,
                  dataSource: _getCalendarDataSource(state.appointments),
                  allowedViews: [
                    sf.CalendarView.month,
                    sf.CalendarView.day,
                  ],
                  monthViewSettings: sf.MonthViewSettings(
                      showAgenda: true,
                      appointmentDisplayMode:
                          sf.MonthAppointmentDisplayMode.appointment),
                );
              } else {
                return Container();
              }
            },
          );
  }

  int getCleaningInterval(ServiceFrequency serviceFrequency) {
    int weeklyService = 7;
    int biWeeklyService = 14;
    int monthlyService = 30;
    int customService = 60;
    switch (serviceFrequency) {
      case ServiceFrequency.weekly:
        return weeklyService;
        break;
      case ServiceFrequency.biWeekly:
        return biWeeklyService;
        break;
      case ServiceFrequency.monthly:
        return monthlyService;
        break;
      case ServiceFrequency.custom:
        return customService;
        break;
      default:
        print('unknown Service Frequency');

        return 1;
    }
  }

  void addRecurrencePropertyToAppointment(List<Appointment> appointments) {
    sf.RecurrenceProperties recurrence = new sf.RecurrenceProperties();

    appointments.forEach((appointment) {
      recurrence.recurrenceType = sf.RecurrenceType.daily;
      recurrence.recurrenceRange = sf.RecurrenceRange.count;
      recurrence.interval =
          getCleaningInterval(appointment.client.serviceFrequency);

      recurrence.recurrenceCount = 1;
      appointment.exceptionDates = [DateTime(2020, 8, 5)];
      List<DateTime> list = sf.SfCalendar.getRecurrenceDateTimeCollection(
          sf.SfCalendar.generateRRule(
              recurrence, appointment.from, appointment.to),
          appointment.from);
      list.forEach((date) {
        print(DateFormat('MM/dd/yyyy H:mm a').format(date));
      });
      return appointment.recurrenceRule = sf.SfCalendar.generateRRule(
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
        Client client = Client.fromDocumentSnap(documentSnap);
        if (client.lastServiceDateOnly
            .isAtSameMomentAs(appointment.fromDateOnly)) {
          // print('No Need to change ${appointment.appointmentId}');
          return;
        }
        bool isAfter = appointment.from.isAfter(client.lastServiceDateOnly);

        if (isAfter) {
          print(
              '${client.lastServiceDateOnly} isAfter ${appointment.from} changing ${client.firstName}');
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

class AppointmentDataSource extends sf.CalendarDataSource {
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
