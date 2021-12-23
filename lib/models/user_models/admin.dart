import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/broadcastHandler/broadcastHandler.dart';
import 'package:the_cleaning_ladies/models/financeSummary/financeSummary.dart';
import 'package:the_cleaning_ladies/models/phoneHandler/phoneHandler.dart';
import 'package:the_cleaning_ladies/models/schedule/schedule.dart';
import 'package:the_cleaning_ladies/models/schedule/scheduleSettings.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';
import 'package:the_cleaning_ladies/models/user_models/workers.dart';
import 'package:the_cleaning_ladies/models/user_models/user.dart';
import 'package:the_cleaning_ladies/models/history_event.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/notification_model/notification_model.dart';

import 'package:the_cleaning_ladies/models/service/service.dart' as service;

class Admin extends User {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  EasyDB _easyDb = DataBaseRepo();
  int notificationCount;
  String businessCode;
  service.Service services;
  String twilioNumber;

  Schedule schedule;
  ScheduleSettings scheduleSettings;
  FinanceSummary financeSummary;
  BroadcastHandler broadcastHandler;
  PhoneHandler phoneHandler;

  Admin({
    String businessName,
    String firstName,
    String lastName,
    String id,
    String contactNumber,
    String email,
    String streetAddress,
    String buildingNumber,
    String city,
    String state,
    String zipCode,
    UserType userType,
    DocumentReference ref,
    this.templateFillInValues,
    this.templateReminderMsg,
    this.scheduleSettings,
    this.twilioNumber,
    this.notificationCount,
    this.businessCode,
  }) : super(
          businessName: businessName,
          firstName: firstName,
          lastName: lastName,
          id: id,
          contactNumber: contactNumber,
          email: email,
          streetAddress: streetAddress,
          buildingNumber: buildingNumber,
          city: city,
          state: state,
          zipCode: zipCode,
          userType: userType,
          ref: ref,
        ) {
    phoneHandler = PhoneHandler.init(admin: this);
    schedule = Schedule.init(admin: this, scheduleSettings: scheduleSettings);

    services = service.Service.init(admin: this);
    financeSummary = FinanceSummary.init(admin: this);
  }

  // A List that shows Groups and inside of Groups it shows how many workers
  List<Group> groups = [
    Group(<Worker>[
      Worker(
          firstName: 'Juanita',
          lastName: 'Morales',
          position: Position.nonDriver),
      Worker(
          firstName: 'Norma', lastName: 'Herrara', position: Position.driver),
    ])
  ];

  List<DateTime> timePreference = [];

  // DateTime earlyMorningsStart = DateTime(2020, 5, 24, 7, 0);
  // DateTime earlyMorningsEnd = DateTime(2020, 5, 24, 9, 15);
  // DateTime lateMorningsStart = DateTime(2020, 5, 24, 9, 15);
  // DateTime lateMorningsEnd = DateTime(2020, 5, 24, 11, 30);
  // DateTime startAfternoons = DateTime(2020, 5, 24, 12, 0);
  // DateTime endAfternoons = DateTime(2020, 5, 24, 15, 0);
  int timeToCleanHouse = 120;
  int travelTime = 15;
  String templateReminderMsg;
  List<dynamic> templateFillInValues = [];
  List<Client> customers = [];

  Future<List<NotificationModel>> fetchAwaitingNotifications(
      {bool isSet = false}) async {
    QuerySnapshot snap = await _db
        .collection('Users/$id/Notifications')
        .where('isSet', isEqualTo: isSet)
        // .orderBy('reminderFor')
        .get();

    return snap.docs.map((doc) => NotificationModel.fromDoc(doc)).toList();
  }

  Future<Client> getClient(String reference) async {
    DocumentSnapshot snap = await _db.doc(reference).get();

    return Client.fromDocumentSnap(snap);
  }

  Future<List<Appointment>> getFutureAppointments() async {
    List<Client> _clients = await getAllClients();
    List<Appointment> appointments = [];
    _clients.forEach((client) {
      appointments.add(Appointment(
          client.firstAndLastFormatted,
          client.calculateTimeForCleaningAndSchedule(this).from,
          client.calculateTimeForCleaningAndSchedule(this).to,
          Colors.blue[400],
          false,
          client,
          isConfirmed: false,
          keyRequired: client.keyRequired,
          admin: this));
    });
    // print(appointments);
    appointments.removeWhere(
        (appointment) => appointment.from.isBefore(DateTime.now()));
    return appointments;
  }

  Future<void> updateAdminNotificationCount(
      {bool checkNotifications, Client client, Function onDone}) async {
    if (checkNotifications) {
      // print('checking Notifications...');
      return await _db.runTransaction((transaction) async {
        DocumentSnapshot freshAdminSnap = await transaction.get(ref);
        int newAdminNotificationCount = freshAdminSnap.get('notificationCount');
        print(
            'Transaction Admin Notification count $newAdminNotificationCount');
        notificationCount = newAdminNotificationCount;
        onDone();
        // print('Done Checking Notifications');
      });
    }
    return await _db.runTransaction((transaction) async {
      print('Updating... Notifications');
      DocumentSnapshot freshAdminSnap = await transaction.get(ref);
      DocumentSnapshot freshClientSnap = await transaction.get(client.ref);
      int newAdminNotificationCount = freshAdminSnap.get('notificationCount');
      int newClientNotificationCount = freshClientSnap.get('notificationCount');
      print(
          '$newAdminNotificationCount - $newClientNotificationCount = ${newAdminNotificationCount - newClientNotificationCount}');
      transaction.update(ref, {
        'notificationCount':
            newAdminNotificationCount - newClientNotificationCount
      });
      notificationCount =
          newAdminNotificationCount - newClientNotificationCount;
      transaction.update(client.reference, {'notificationCount': 0});
      onDone();
      print('Done Updating Notifications');
    });
  }

  void update(Map<String, dynamic> data) async =>
      await _easyDb.editDocumentData('Users/$id', data);

  Future<List<Client>> getAllClients({bool activeOnly = true}) async {
    if (activeOnly) {
      QuerySnapshot _customers = await _db
          .collection('Users')
          .where('businessCode', isEqualTo: businessCode)
          .where('activeForCleaning', isEqualTo: true)
          .where('userType', isEqualTo: 'UserType.client')
          .get();
      return _customers.docs
          .map((doc) => Client.fromDocumentSnap(doc))
          .toList();
    } else {
      QuerySnapshot _customers = await _db
          .collection('Users')
          .where('businessCode', isEqualTo: businessCode)
          .where('userType', isEqualTo: 'UserType.client')
          .get();
      return _customers.docs
          .map((doc) => Client.fromDocumentSnap(doc))
          .toList();
    }
  }

  void changeAllAppointments() async {
    List<Appointment> _appointments = await getAppointments();
    _appointments.forEach((appointment) async {
      Client client = await getClient('Users/${appointment.client.id}');
      appointment.ref
          .update({'serviceFrequency': client.serviceFrequency.toString()});
    });
  }

  Future<List<Appointment>> getAppointments(
      {bool confirmedOnly = false, bool unconfirmedOnly = false}) async {
    if (!confirmedOnly && !unconfirmedOnly) {
      return await _db.collection('Users/$id/Appointments').get().then((snap) =>
          snap.docs
              .map((doc) => Appointment.fromDocument(doc, admin: this))
              .toList());
    }
    return await _db
        .collection('Users/$id/Appointments')
        .where('isConfirmed',
            isEqualTo: confirmedOnly
                ? true
                : unconfirmedOnly
                    ? false
                    : true)
        .get()
        .then((snap) => snap.docs
            .map((doc) => Appointment.fromDocument(doc, admin: this))
            .toList());
  }

  void updateClientHistory() async {
    List<Client> clients = await getAllClients();
    for (Client client in clients) {
      QuerySnapshot snap =
          await _db.collection('Users/${client.id}/Cleaning History').get();
      snap.docs.forEach((doc) {
        HistoryEvent historyEvent = HistoryEvent.fromDocument(doc);

        if (historyEvent.from.isBefore(DateTime.now())) {
          doc.reference.update({'isConfirmed': true});
        }
      });
    }
  }

//   void sendCleaningReminder() async {
//     setupTwilioFlutter();
//     List<Appointment> unconfirmedAppointments =
//         await _getUnconfirmedAppointments();
//     for (Appointment appointment in unconfirmedAppointments) {
//       DocumentSnapshot clientSnap =
//           await _db.doc(appointment.clientReference).get();
//       Client client = Client.fromDocument(clientSnap);

//       Future.delayed(Duration(seconds: 1), () async {
//         await twilioFlutter
//             .sendSMS(toNumber: '${client.formatPhoneNumber}', messageBody: """
// Hello from The Cleaning Ladies!
// ${client.firstName},

// This is just your reminder text that the Cleaning Ladies will be stopping by ${appointment.fromMonth} ${appointment.from.day}, ${appointment.day}
// @ ~${appointment.fromTimeFormatted} - ${appointment.toTimeFormatted}

// Please confirm. Thank you and have a great day.
// """);
//       });
//     }
//   }
  List<String> findMatches(String message) {
    List<String> matches = [];
    RegExp regExp =
        RegExp(r'(\{\d{1}\})', multiLine: true, caseSensitive: false);
    regExp.allMatches(message).toList().forEach((m) {
      print(m.group(1));
      matches.add(m.group(1));
    });
    return matches;
  }

  void createSchedule() async {
    print('creating schedule');
    _tryScheduling(await getAllCustomersFromDB());
  }

  Future<List<Client>> getAllCustomersFromDB() async {
    return _db
        .collection('Users')
        .where('businessCode', isEqualTo: '$businessCode')
        .where('activeForCleaning', isEqualTo: true)
        .get()
        .then((snap) =>
            snap.docs.map((doc) => Client.fromDocumentSnap(doc)).toList());
  }

  void _tryScheduling(List<Client> customers) {
    for (Client customer in customers) {
      // Map<String, DateTime> nextCleaning = customer.calculateNextCleaning();
      Appointment appointment =
          customer.calculateTimeForCleaningAndSchedule(this);
      print(
          '${appointment.client.firstAndLastFormatted}  ${appointment.formattedAppointmentDateTime}');
      // _easyDb.createUserData('Users/$id/Appointments', appointment.toDocument());
    }
  }

  factory Admin.fromDocumentSnap(DocumentSnapshot document) {
    Map<String, UserType> userTypes = {
      'UserType.admin': UserType.admin,
      'UserType.client': UserType.client
    };
    Map<String, dynamic> doc = document.data();
    return Admin(
        businessName: doc['businessName'],
        firstName: doc['firstName'],
        lastName: doc['lastName'],
        state: doc['state'],
        city: doc['city'],
        userType: userTypes['${doc['userType']}'],
        id: document.id,
        ref: document.reference,
        templateReminderMsg: doc['templateReminderMsg'],
        templateFillInValues: doc['templateFillInValues'],
        scheduleSettings: ScheduleSettings.fromDoc(document),
        twilioNumber: doc['apiPN'],
        notificationCount: doc['notificationCount'],
        businessCode: doc['businessCode']);
  }
  Map<String, Object> toDocument() {
    String templateReminderMsg = """
Hello from $businessName (Automated Reminder System)!

{1},
    
This is just your reminder text that you have an appointment with $businessName.

Scheduled Date:
{2}
    
Please reply "1" to confirm and "2" to reschedule.
""";
    return {
      'businessName': businessName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'state': state,
      'city': city,
      'zipCode': zipCode,
      'contactNumber': contactNumber,
      'userType': UserType.admin.toString(),
      'templateReminderMsg': templateReminderMsg,
      'templateFillInValues': ['firstName', 'fullDateTime'],
      'scheduleSettings': ScheduleSettings.standard().toDocument(),
      'apiPN': '',
      'notificationCount': 0,
      'businessCode': businessCode,
    };
  }
}
