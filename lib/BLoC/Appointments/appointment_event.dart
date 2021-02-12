import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';

abstract class AppointmentEvent {}

class LoadAppointmentsEvent extends AppointmentEvent {
  final Admin admin;
  LoadAppointmentsEvent(this.admin);
}

class AddAppointmentEvent extends AppointmentEvent {
  final Appointment appointment;
  final Admin admin;

  AddAppointmentEvent(this.appointment, this.admin);
}

class UpdateAppointmentEvent extends AppointmentEvent {
  final Appointment appointment;
  final Admin admin;

  UpdateAppointmentEvent(this.appointment, this.admin);
}

class AppointmentsUpdatedEvent extends AppointmentEvent {
  final List<Appointment> appointments;

  AppointmentsUpdatedEvent(this.appointments);
}

class DeleteAppointmentEvent extends AppointmentEvent {
  final Appointment appointment;
  final Admin admin;

  DeleteAppointmentEvent(this.appointment, this.admin);
}
