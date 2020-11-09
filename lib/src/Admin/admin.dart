import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/src/Admin/EasyDB/EasyDb.dart';
import 'package:the_cleaning_ladies/src/Admin/workers.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/Models/SMS/message.dart';
import 'package:the_cleaning_ladies/src/Models/User/user.dart';
import 'package:the_cleaning_ladies/src/Models/historyEvent.dart';
import 'package:the_cleaning_ladies/src/Widgets/CalendarWidget/calendar.dart';
import 'package:twilioFlutter/models/sms.dart';
import 'package:twilioFlutter/twilioFlutter.dart';

class Admin extends User {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  EasyDB _easyDb = DataBaseRepo();
  Admin(
      {String firstName,
      String lastName,
      String id,
      UserType userType,
      this.templateFillInValues,
      this.templateReminderMsg})
      : super(
            firstName: firstName,
            lastName: lastName,
            id: id,
            userType: userType);

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
  TwilioFlutter _twilioFlutter;
  Future<Client> getClient(String reference) async {
    DocumentSnapshot snap = await _db.doc(reference).get();

    return Client.fromDocSnapDocument(snap);
  }

  Future<List<Appointment>> getFutureAppointments() async {
    List<Client> _clients = await _getAllClients();
    List<Appointment> appointments = [];
    _clients.forEach((client) {
      appointments.add(Appointment(
          '${client?.firstName ?? ''}${client.lastName.isEmpty ? '' : ','} ${client.lastName.isEmpty ? '' : '${(client?.lastName[0]) ?? ''}.'}',
          client.calculateNextCleaning()['from'],
          client.calculateNextCleaning()['to'],
          Colors.blue,
          false,
          client,
          isConfirmed: false,
          keyRequired: client.keyRequired));
    });
    // print(appointments);
    appointments.removeWhere(
        (appointment) => appointment.from.isBefore(DateTime.now()));
    return appointments;
  }

  void update(Map<String, dynamic> data) async =>
      await _easyDb.editDocumentData('Users/$id', data);

  void addHistoryToEachCustomer() async {
    List<Client> _clients = await _getAllClients();
    _clients.forEach((client) async {
      _db.doc('Users/${client.id}').update({'templateReminderMsg': ''});
    });
  }

  Future<List<Client>> _getAllClients() async {
    QuerySnapshot _customers = await _db
        .collection('Users')
        .where('userType', isEqualTo: 'UserType.client')
        .get();
    return _customers.docs
        .map((doc) => Client.fromQueryDocSnapDocument(doc))
        .toList();
  }

  Future<int> getWeekTotalMinusWorkerFees() async {
    List<Appointment> _appointments = await _getAppointments();

    _appointments.removeWhere((appointment) => appointment.checkInTheWeek(
        DateTime(2020, 10, 5), DateTime(2020, 10, 11)));
    int total = 0;
    print(_appointments.length);
    _appointments.forEach((appointment) => total += appointment.cleaningCost);
    return total;
  }

  Future<List<Appointment>> _getAppointments(
      {bool confirmedOnly = false, bool unconfirmedOnly = false}) async {
    if (!confirmedOnly && !unconfirmedOnly) {
      return await _db.collection('Appointments').get().then((snap) =>
          snap.docs.map((doc) => Appointment.fromDocument(doc)).toList());
    }
    return await _db
        .collection('Appointments')
        .where('isConfirmed',
            isEqualTo: confirmedOnly
                ? true
                : unconfirmedOnly
                    ? false
                    : true)
        .get()
        .then((snap) =>
            snap.docs.map((doc) => Appointment.fromDocument(doc)).toList());
  }

  Future<int> getDayTotal(int day, DateTime start) async {
    List<Appointment> _appointments = await _getAppointments();
    _appointments.removeWhere((appointment) => !appointment.fromDateOnly
        .isAtSameMomentAs(start.add(Duration(days: day))));
    // print(_appointments.length);
    int total = 0;
    _appointments.forEach((appointment) => total += appointment.cleaningCost);
    // print(total);
    return total;
  }

  Future<int> getWeekTotal(DateTime start) async {
    List<Appointment> _appointments = await _getAppointments();
    _appointments.removeWhere((appointment) =>
        appointment.checkInTheWeek(start, start.add(Duration(days: 6))));
    int total = 0;
    _appointments.forEach((appointment) => total += appointment.cleaningCost);
    return total;
  }

  Future<int> get getTotalClients async {
    List<Client> _customers = await _getAllClients();
    return _customers.length;
  }

  Future<int> get getTotalClientsMonthlyPay async {
    int total = 0;
    List<Client> _customers = await _getAllClients();
    _customers.forEach((client) {
      if (client.active) {
        switch (client.cleaningFrequency) {
          case CleaningFrequency.weekly:
            total += client.costPerCleaning * 4;

            break;
          case CleaningFrequency.biWeekly:
            total += client.costPerCleaning * 2;

            break;
          default:
            total += client.costPerCleaning;
        }
      } else {
        total += 0;
      }
    });
    return total;
  }

  void updateClientHistory() async {
    List<Client> clients = await _getAllClients();
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

  void updateContactNumber() async {
    List<Client> clients = await _getAllClients();
    clients.forEach((client) async {
      await _db
          .doc('Users/${client.id}')
          .update({'contactNumber': client.formatPhoneNumber});
    });
    print('done');
  }

  void updateAppointment(Appointment appointment, Map<String, dynamic> data,
      Map<String, dynamic> duplicateData) async {
    await _easyDb.editDocumentData(
        'Users/${appointment.client.id}/Cleaning History/${appointment.appointmentId}',
        duplicateData);
    return await _easyDb.editDocumentData(
        "Appointments/${appointment.appointmentId}", data);
  }

  void updateClient(Client client, Map<String, dynamic> data) async =>
      await _easyDb.editDocumentData('Users/${client.id}', data);

  void _setupTwilioFlutter() {
    _twilioFlutter = TwilioFlutter(
      accountSid: 'AC96526016b76c4b23da1433373f5207e0',
      authToken: '2537da78be327dd38acad822dfc97949',
      twilioNumber: '+16503752428',
    );
  }

  void reply(String body, String to, Client client) async {
    _setupTwilioFlutter();
    await _twilioFlutter
        .sendSMS(toNumber: to, messageBody: body)
        .whenComplete(() {
      _db.collection('Users/${client.id}/SMS').add({
        'to': to,
        'from': '+16503752428',
        'body': body,
        'createdAt': DateTime.now()
      });
      print('Message sent');
    });
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

  String _createDynamicMessage(
      String message, Appointment appointment, Client client,
      {List<dynamic> values}) {
    int index = 1;
    Map<String, dynamic> fillInValues = {
      'firstName': client.firstName,
      'lastName': client.lastName,
      'getMsgReadyFullDateTime': appointment.getMsgReadyFullDateTime,
    };
    return message.replaceAllMapped(
        RegExp(r'(\{\d{1}\})', multiLine: true, caseSensitive: false), (m) {
      // Add all values not found in Map to a list and list those
      // values in a User Friendly way
      String value = fillInValues[values[index - 1]] ??
          '{${values[index - 1]} value is unknown}';
      index++;
      return value;
    });
  }

  void sendAutoReminder(
      Appointment appointment, Function(bool) requestResponse) async {
    _setupTwilioFlutter();
    DocumentSnapshot clientSnap =
        await _db.doc(appointment.clientReference).get();
    Client client = Client.fromDocSnapDocument(clientSnap);
    String msg;
    if (client.templateReminderMsg.isEmpty) {
      msg = _createDynamicMessage(templateReminderMsg, appointment, client,
          values: templateFillInValues);
      print(_createDynamicMessage(templateReminderMsg, appointment, client,
          values: templateFillInValues));
    } else {
      msg = _createDynamicMessage(
          client.templateReminderMsg, appointment, client,
          values: client.templateFillInValues);
      print(_createDynamicMessage(
          client.templateReminderMsg, appointment, client,
          values: client.templateFillInValues));
    }
    Future.delayed(Duration(seconds: 1), () async {
      await _twilioFlutter.sendAutoReminder((res) => requestResponse(res),
          toNumber: client.formatPhoneNumber,
          id: appointment.appointmentId,
          clientId: appointment.client.id,
          message: """$msg""");
    }).whenComplete(() {
      // _db.collection('Users/${client.id}/SMS').add({
      //   'to': client.formatPhoneNumber,
      //   'from': '+16503752428',
      //   'body': """$msg""",
      //   'createdAt': DateTime.now()
      // });
    });
  }

  Future<List<SMS>> getSmSList() async {
    _setupTwilioFlutter();
    return await _twilioFlutter.getSmsList();
  }

  Stream<List<Message>> getSMS(Client client) {
    return _db
        .collection('Users/${client.id}/SMS')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => Message.fromDocument(doc)).toList();
    });
  }

  Future<List<SMS>> getSpecificSmSList(String from, String to) async {
    _setupTwilioFlutter();
    return await _twilioFlutter.getSpecificSmsList(from, to);
  }

  void createAppointment(Appointment appointment) async {
    Client _client = appointment.client;

    print('creating appointment for Customner ID: ${_client.id}');
    return await _easyDb.createUserData(
        'Appointments', appointment.toDocument(),
        duplicateDoc: true,
        duplicatedCollectionPath: 'Users/${_client.id}/Cleaning History',
        duplicatedData: HistoryEvent.fromAppointment(appointment).toDocument());
  }

  void createSchedule() async {
    print('creating schedule');
    _tryScheduling(await getAllCustomersFromDB());
  }

  Future<List<Client>> getAllCustomersFromDB() async {
    return _db
        .collection('Users')
        //TODO: BusinessCode Dynamic
        .where('businessCode', isEqualTo: 'TCL')
        .where('activeForCleaning', isEqualTo: true)
        .get()
        .then((snap) => snap.docs
            .map((doc) => Client.fromQueryDocSnapDocument(doc))
            .toList());
  }

  void _tryScheduling(List<Client> customers) {
    for (Client customer in customers) {
      Map<String, DateTime> nextCleaning = calculateNextCleaning(customer);
      calculateTimeForCleaningAndSchedule(nextCleaning, customer);
    }
  }

  String readFrequencyFromDB(String freq) {
    switch (freq) {
      case 'CleaningFrequency.weekly':
        return 'weekly';
        break;
      case 'CleaningFrequency.biWeekly':
        return 'biWeekly';

        break;
      case 'CleaningFrequency.monthly':
        return 'monthly';

        break;
      case 'CleaningFrequency.custom':
        return 'custom';

        break;
      default:
        return 'Unknown';
    }
  }

  Map<String, DateTime> calculateNextCleaning(Client customer) {
    DateTime lC = customer.lastCleaning;
    switch (customer.cleaningFrequency) {
      case CleaningFrequency.weekly:
        return {
          'from': lC.add(Duration(days: 7)),
          'to': lC.add(Duration(days: 7))
        };
        break;
      case CleaningFrequency.biWeekly:
        return {
          'from': lC.add(Duration(days: 14)),
          'to': lC.add(Duration(days: 14))
        };
        break;
      case CleaningFrequency.monthly:
        return {
          'from': lC.add(Duration(days: 31)),
          'to': lC.add(Duration(days: 31))
        };
        break;
      case CleaningFrequency.custom:
        return {
          'from': lC.add(Duration(days: 60)),
          'to': lC.add(Duration(days: 60))
        };
        break;
      default:
        return {};
    }
  }

  void calculateTimeForCleaningAndSchedule(
      Map<String, DateTime> nextCleaning, Client customer) {
    switch (customer.cleaningTimePreference) {
      case CleaningTimePreference.earlyMornings:
        Appointment appointment = Appointment(
            'Cleaning',
            nextCleaning['from'].add(Duration(
              hours: 8,
            )),
            nextCleaning['to'].add(Duration(hours: 8, minutes: 45)),
            Colors.green,
            false,
            customer,
            keyRequired: customer.keyRequired);
        _easyDb.createUserData('Appointments', appointment.toDocument());
        break;
      case CleaningTimePreference.lateMornings:
        Appointment appointment = Appointment(
            'Cleaning',
            nextCleaning['from'].add(Duration(hours: 10, minutes: 15)),
            nextCleaning['to'].add(Duration(hours: 11)),
            Colors.green,
            false,
            customer,
            keyRequired: customer.keyRequired);
        _easyDb.createUserData('Appointments', appointment.toDocument());
        break;
      case CleaningTimePreference.afternoons:
        Appointment appointment = Appointment(
            'Cleaning',
            nextCleaning['from'].add(Duration(hours: 12, minutes: 30)),
            nextCleaning['to'].add(Duration(hours: 13, minutes: 15)),
            Colors.green,
            false,
            customer,
            keyRequired: customer.keyRequired);
        _easyDb.createUserData('Appointments', appointment.toDocument());

        break;
      default:
    }
  }

  factory Admin.fromDocument(DocumentSnapshot document) {
    Map<String, UserType> userTypes = {
      'UserType.admin': UserType.admin,
      'UserType.client': UserType.client
    };
    Map<String, dynamic> doc = document.data();
    return Admin(
        firstName: doc['firstName'],
        lastName: doc['lastName'],
        userType: userTypes['${doc['userType']}'],
        id: document.id,
        templateReminderMsg: doc['templateReminderMsg'],
        templateFillInValues: doc['templateFillInValues']);
  }
}
