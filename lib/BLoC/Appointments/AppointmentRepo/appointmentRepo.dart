import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';
import 'package:the_cleaning_ladies/models/history_event.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/notification_model/notification_model.dart';
import 'package:the_cleaning_ladies/notification_model/push_notification.dart';

abstract class AppointmentsRepository {
  Future<void> addNewAppointment(
      Appointment appointment, Admin admin, VoidCallback onCreationError);
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
  EasyDB _easyDb = DataBaseRepo();

  int generateId() {
    DateTime now = DateTime.now();
    String idCombination = '${now.minute}${now.second}${now.millisecond}';
    int id = int.parse(idCombination);
    return id;
  }

  @override
  Future<void> addNewAppointment(Appointment appointment, Admin admin,
      VoidCallback onCreationError) async {
    Client _client = appointment.client;
    print('creating appointment for Customer ID: ${_client.id}');
    NotificationModel notification = NotificationModel(
        title: 'Urgent Reminder!',
        body:
            'Don\'t forget you have an appointment with ${appointment.client.firstAndLastFormatted} ${appointment.formattedAppointmentDateTime} in ${admin.schedule.scheduleSettings.remindBeforeTimeToString}!',
        id: generateId(),
        payload: 'Payload',
        ref: null,
        reminderFor:
            appointment.from.subtract(admin.scheduleSettings.remindBeforeTime),
        isSet: false);
    PushNotifications.schedule(
        admin: admin,
        notification: notification,
        onError: (error) async {
          // Notification Not Scheduled due to error do not add to db
          print(
              'Error Scheduling for ${appointment.client.firstAndLastFormatted}');

          return await _easyDb
              .createUserData(
                  'Users/${admin.id}/Appointments', appointment.toDocument(),
                  duplicateDoc: true,
                  duplicatedCollectionPath: [
                    'Users/${_client.id}/Cleaning History',
                  ],
                  duplicatedData: [
                    HistoryEvent.fromAppointment(appointment).toDocument(),
                  ],
                  onCreation: (docId) async {})
              .catchError((onError) => onCreationError);
        },
        onQueueFull: () async {
          // Notification Not Schedled
          print('Queue Full for ${appointment.client.firstAndLastFormatted}');

          notification.isSet = false;
          return await _easyDb
              .createUserData(
                  'Users/${admin.id}/Appointments', appointment.toDocument(),
                  duplicateDoc: true,
                  duplicatedCollectionPath: [
                    'Users/${_client.id}/Cleaning History',
                    'Users/${admin.id}/Notifications'
                  ],
                  duplicatedData: [
                    HistoryEvent.fromAppointment(appointment).toDocument(),
                    notification.toDoc()
                  ],
                  onCreation: (docId) async {})
              .catchError((onError) => onCreationError);
        },
        onNotificationScheduled: () async {
          // Schedule was successful
          print(
              'Scheduling Successfull for ${appointment.client.firstAndLastFormatted}');
          notification.isSet = true;
          return await _easyDb
              .createUserData(
                  'Users/${admin.id}/Appointments', appointment.toDocument(),
                  duplicateDoc: true,
                  duplicatedCollectionPath: [
                    'Users/${_client.id}/Cleaning History',
                    'Users/${admin.id}/Notifications'
                  ],
                  duplicatedData: [
                    HistoryEvent.fromAppointment(appointment).toDocument(),
                    notification.toDoc()
                  ],
                  onCreation: (docId) async {})
              .catchError((onError) => onCreationError);
        });
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
    admin.phoneHandler
        .setupTwilioFlutter()
        .flow
        .endActiveExecution(appointment.executionSID, isActive: () {});
    userCollection
        .doc(
            '${appointment.client.id}/Cleaning History/${appointment.appointmentId}')
        .delete();
    DocumentSnapshot dbNotification = await userCollection
        .doc('${admin.id}/Notifications/${appointment.appointmentId}')
        .get();
    if (dbNotification.exists) {
      NotificationModel notification =
          NotificationModel.fromDoc(dbNotification);
      PushNotifications.deleteScheduled(
          admin: admin, notification: notification);
      notification.ref.delete();
    }

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
    await admin.phoneHandler
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

    // Update Scheduled Notification
    DocumentSnapshot dbNotification = await userCollection
        .doc('${admin.id}/Notifications/${appointment.appointmentId}')
        .get();
    if (dbNotification.exists) {
      NotificationModel notification =
          NotificationModel.fromDoc(dbNotification);
      notification.reminderFor = appointment.from
          .subtract(admin.schedule.scheduleSettings.remindBeforeTime);
      PushNotifications.updateScheduled(
          admin: admin,
          notification: notification,
          onError: (error) async {
            // Notification Not Scheduled due to error delete notification
            print('Error Scheduling for ${appointment.eventName}');
            notification.ref.delete();
          },
          onQueueFull: () {
            print('Queue Full for ${appointment.eventName}');

            notification.isSet = false;
            notification.ref.update({
              'reminderFor': appointment.from
                  .subtract(admin.schedule.scheduleSettings.remindBeforeTime),
              'isSet': notification.isSet
            });
          },
          onNotificationScheduled: () {
            // Schedule was successful
            print('Scheduling Successfull for ${appointment.eventName}');
            notification.isSet = true;

            notification.ref.update({
              'reminderFor': appointment.from
                  .subtract(admin.schedule.scheduleSettings.remindBeforeTime),
              'isSet': notification.isSet
            });
          });
    } else {
      NotificationModel notification = NotificationModel(
          title: 'Urgent Reminder!',
          body:
              'Don\'t forget you have an appointment with ${appointment.eventName} in ${admin.schedule.scheduleSettings.remindBeforeTimeToString}!',
          id: generateId(),
          payload: 'Payload',
          ref: null,
          reminderFor: appointment.from
              .subtract(admin.schedule.scheduleSettings.remindBeforeTime),
          isSet: false);
      _easyDb.createUserData(
          'Users/${admin.id}/Notifications/${appointment.appointmentId}',
          notification.toDoc(),
          addAutoIDToDoc: false,
          createAutoId: false,
          onCreation: (id) {});
      DocumentSnapshot dbNotification = await userCollection
          .doc('${admin.id}/Notifications/${appointment.appointmentId}')
          .get();
      NotificationModel notificationFromDB =
          NotificationModel.fromDoc(dbNotification);
      PushNotifications.updateScheduled(
          admin: admin,
          notification: notificationFromDB,
          onError: (error) async {
            // Notification Not Scheduled due to error delete notification
            print('Error Scheduling for ${appointment.eventName}');
            notificationFromDB.ref.delete();
          },
          onQueueFull: () {
            print('Queue Full for ${appointment.eventName}');

            notificationFromDB.isSet = false;
            notificationFromDB.ref.update({'isSet': notificationFromDB.isSet});
          },
          onNotificationScheduled: () {
            // Schedule was successful
            print('Scheduling Successfull for ${appointment.eventName}');
            notificationFromDB.isSet = true;

            notificationFromDB.ref.update({'isSet': notificationFromDB.isSet});
          });
    }
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
