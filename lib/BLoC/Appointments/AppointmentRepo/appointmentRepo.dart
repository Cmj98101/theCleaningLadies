import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';

abstract class AppointmentsRepository {
  Future<void> addNewAppointment(Appointment appointment);
  Future<void> deleteClientAppointment(Appointment appointment);
  Future<void> deleteAppointment(Appointment appointment, Admin admin);
  Stream<List<Appointment>> appointments(Admin admin);
  Future<void> updateAppointment(Appointment update, Admin admin);
  Future<List<Appointment>> getAppointments(Admin admin);
}

class FireBaseAppointmentsRepository implements AppointmentsRepository {
  final appointmentCollection =
      FirebaseFirestore.instance.collection('Appointments');
  final userCollection = FirebaseFirestore.instance.collection('Users');
  final _db = FirebaseFirestore.instance;
  @override
  Future<void> addNewAppointment(Appointment appointment) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Appointment>> appointments(Admin admin) {
    return _db
        .collection('Users/${admin.id}/Appointments')
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => Appointment.fromDocument(doc, admin: admin))
          .toList();
    });
  }

  @override
  Future<void> deleteAppointment(Appointment appointment, Admin admin) async {
    admin
        .setupTwilioFlutter()
        .flow
        .endActiveExecution(appointment.executionSID, isActive: () {});
    userCollection
        .doc(
            '${appointment.client.id}/Cleaning History/${appointment.appointmentId}')
        .delete();
    return _db
        .collection('Users/${admin.id}/Appointments')
        .doc(appointment.appointmentId)
        .delete();
  }

  @override
  Future<void> deleteClientAppointment(Appointment appointment) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateAppointment(Appointment appointment, Admin admin) async {
    await admin
        .setupTwilioFlutter()
        .flow
        .endActiveExecution(appointment.executionSID, isActive: () async {
      appointment.executionSID = '';
      appointment.flowSID = '';
      await _db
          .collection('Users/${admin.id}/Appointments')
          .doc(appointment.appointmentId)
          .update({
        'isReminderSent': false,
        'isRescheduling': false,
        'isConfirmed': false,
        'noReply': false,
        'executionSID': '',
        'flowSID': ''
      });
    });

    userCollection
        .doc(
            '${appointment.client.id}/Cleaning History/${appointment.appointmentId}')
        .update({'from': appointment.from});
    return _db
        .collection('Users/${admin.id}/Appointments')
        .doc(appointment.appointmentId)
        .update({'from': appointment.from, 'to': appointment.to});
  }

  Future<List<Appointment>> getAppointments(Admin admin) {
    return _db.collection('Users/${admin.id}/Appointments').get().then(
        (snapshot) => snapshot.docs
            .map((doc) => Appointment.fromDocument(doc, admin: admin))
            .toList());
  }
}
