import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_cleaning_ladies/src/Widgets/CalendarWidget/calendar.dart';

abstract class AppointmentsRepository {
  Future<void> addNewAppointment(Appointment appointment);
  Future<void> deleteClientAppointment(Appointment appointment);
  Future<void> deleteAppointment(Appointment appointment);
  Stream<List<Appointment>> appointments();
  Future<void> updateAppointment(Appointment update);
  Future<List<Appointment>> getAppointments();
}

class FireBaseAppointmentsRepository implements AppointmentsRepository {
  final appointmentCollection =
      FirebaseFirestore.instance.collection('Appointments');
  final userCollection = FirebaseFirestore.instance.collection('Users');
  @override
  Future<void> addNewAppointment(Appointment appointment) {
    // TODO: implement addNewAppointment
    throw UnimplementedError();
  }

  @override
  Stream<List<Appointment>> appointments() {
    return appointmentCollection.snapshots().map((snap) {
      return snap.docs.map((doc) => Appointment.fromDocument(doc)).toList();
    });
  }

  @override
  Future<void> deleteAppointment(Appointment appointment) {
    userCollection
        .doc(
            '${appointment.client.id}/Cleaning History/${appointment.appointmentId}')
        .delete();
    return appointmentCollection.doc(appointment.appointmentId).delete();
  }

  @override
  Future<void> deleteClientAppointment(Appointment appointment) {
    // TODO: implement deleteClientAppointment
    throw UnimplementedError();
  }

  @override
  Future<void> updateAppointment(Appointment appointment) {
    return appointmentCollection
        .doc(appointment.appointmentId)
        .update({'from': appointment.from, 'to': appointment.to});
  }

  Future<List<Appointment>> getAppointments() {
    return appointmentCollection.get().then((snapshot) =>
        snapshot.docs.map((doc) => Appointment.fromDocument(doc)).toList());
  }
}
