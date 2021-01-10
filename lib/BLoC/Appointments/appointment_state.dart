import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';

class AppointmentState {
  AppointmentState();
}

class AppointmentsLoading extends AppointmentState {}

class AppointmentsLoaded extends AppointmentState {
  final List<Appointment> appointments;

  AppointmentsLoaded([this.appointments = const <Appointment>[]]);

  @override
  String toString() => 'AppointmentsLoaded { appointments: $appointments }';
}
