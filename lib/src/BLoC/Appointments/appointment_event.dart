import 'package:the_cleaning_ladies/src/Widgets/CalendarWidget/calendar.dart';

abstract class AppointmentEvent {}

class LoadAppointmentsEvent extends AppointmentEvent {}

class AddAppointmentEvent extends AppointmentEvent {}

class UpdateAppointmentEvent extends AppointmentEvent {
  final Appointment appointment;

  UpdateAppointmentEvent(this.appointment);
}

class AppointmentsUpdatedEvent extends AppointmentEvent {
  final List<Appointment> appointments;

  AppointmentsUpdatedEvent(this.appointments);
}

class DeleteAppointmentEvent extends AppointmentEvent {
  final Appointment appointment;

  DeleteAppointmentEvent(this.appointment);
}
