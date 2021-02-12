import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/AppointmentRepo/appointmentRepo.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/appointment_event.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/appointment_state.dart';

// Appointment Repository

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentsRepository _appointmentsRepository;

  StreamSubscription _appointmentsSubscription;
  AppointmentState get initialState => AppointmentsLoading();
  AppointmentBloc({@required AppointmentsRepository appointmentsRepository})
      : assert(appointmentsRepository != null),
        _appointmentsRepository = appointmentsRepository,
        super(null);
  @override
  Stream<AppointmentState> mapEventToState(AppointmentEvent event) async* {
    if (event is LoadAppointmentsEvent) {
      yield* _loadAppointmentsToState(event);
    } else if (event is AddAppointmentEvent) {
      yield* _mapAddAppointmentToState(event);
    } else if (event is UpdateAppointmentEvent) {
      yield* _mapUpdateAppointmentToState(event);
    } else if (event is DeleteAppointmentEvent) {
      yield* _mapDeleteAppointmentToState(event);
    } else if (event is AppointmentsUpdatedEvent) {
      yield* _mapAppointmentsUpdateToState(event);
    }
  }

  Stream<AppointmentState> _loadAppointmentsToState(
      LoadAppointmentsEvent event) async* {
    _appointmentsSubscription?.cancel();
    _appointmentsSubscription =
        _appointmentsRepository.appointments(event.admin).listen(
              (appointments) => add(AppointmentsUpdatedEvent(appointments)),
            );
  }

  Stream<AppointmentState> _mapAddAppointmentToState(
      AddAppointmentEvent event) async* {
    _appointmentsRepository.addNewAppointment(event.appointment, event.admin);
  }

  Stream<AppointmentState> _mapUpdateAppointmentToState(
      UpdateAppointmentEvent event) async* {
    _appointmentsRepository.updateAppointment(event.appointment, event.admin);
  }

  Stream<AppointmentState> _mapDeleteAppointmentToState(
      DeleteAppointmentEvent event) async* {
    _appointmentsRepository.deleteAppointment(event.appointment, event.admin);
  }

  Stream<AppointmentState> _mapAppointmentsUpdateToState(
      AppointmentsUpdatedEvent event) async* {
    yield AppointmentsLoaded(event.appointments);
  }

  @override
  Future<void> close() {
    _appointmentsSubscription?.cancel();
    return super.close();
  }
}
