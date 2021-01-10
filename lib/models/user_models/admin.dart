import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/time_tile/time_title.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';
import 'package:the_cleaning_ladies/models/user_models/workers.dart';
import 'package:the_cleaning_ladies/models/SMS/message.dart';
import 'package:the_cleaning_ladies/models/user_models/user.dart';
import 'package:the_cleaning_ladies/models/history_event.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:twilioFlutter/models/sms.dart';
import 'package:twilioFlutter/twilioFlutter.dart';
import 'package:the_cleaning_ladies/models/service/service.dart' as service;

class ElapsedTime {
  int hour;
  int min;
  ElapsedTime({@required this.hour, @required this.min});
  int get totalInMin => ((hour * 60) + min);

  Map<String, Object> toDocument() {
    return {'hour': hour, 'min': min};
  }
}

class ScheduleSettings {
  ElapsedTime timePerService;
  ElapsedTime timeBetweenService;
  int servicesPerGroup;
  ScheduleSettings(
      {@required this.timePerService,
      @required this.timeBetweenService,
      @required this.servicesPerGroup});

  Map<String, Object> toDocument() {
    return {
      'servicesPerGroup': servicesPerGroup,
      'timeBetweenService': timeBetweenService.toDocument(),
      'timePerService': timePerService.toDocument()
    };
  }

  factory ScheduleSettings.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> doc = document.data();

    return ScheduleSettings(
        servicesPerGroup: doc['scheduleSettings']['servicesPerGroup'],
        timeBetweenService: ElapsedTime(
            hour: doc['scheduleSettings']['timeBetweenService']['hour'],
            min: doc['scheduleSettings']['timeBetweenService']['min']),
        timePerService: ElapsedTime(
            hour: doc['scheduleSettings']['timePerService']['hour'],
            min: doc['scheduleSettings']['timePerService']['min']));
  }
}

class Admin extends User {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String testSID = 'AC1ac1530f724c58596d7bb13e9d8b6f1a';
  String testAuth = 'c0017e86bd2259221fb3a479445c9019';

  String liveSID = 'AC96526016b76c4b23da1433373f5207e0';
  String liveAuth = '2537da78be327dd38acad822dfc97949';
  EasyDB _easyDb = DataBaseRepo();
  String twilioNumber;
  int notificationCount;
  String businessCode;
  service.Service services;
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
    services = service.Service.init(admin: this);
  }

  ScheduleSettings scheduleSettings;
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
  void updateScheduleSettings() {
    _db
        .doc('Users/$id')
        .update({'scheduleSettings': scheduleSettings.toDocument()});
  }

  void addPaymentType() async {
    List<Client> clients = await getAllCustomersFromDB();
    for (Client client in clients) {
      client.reference.update({'paymentType': PaymentType.unknown.toString()});
    }
  }

  void addaddPropertyToCustomer() async {
    List<Client> clients = await _getAllClients(activeOnly: false);
    clients.forEach((client) {
      client.reference.update({'notificationCount': 0});
    });
  }

  // void changeTypes() async {
  //   List<Client> clients = await _getAllClients(activeOnly: false);
  //   List<Appointment> _appointment = await _getAppointments();
  //   print('hello');
  //   _appointment.forEach((appointment) {
  //     print(appointment.eventName);
  //     print('helo');
  //     _db.doc('Users/$id/Appointments/${appointment.appointmentId}');
  //   });
  // }
  // void fixCleaningHistory() async {
  //   List<Appointment> appointments = await _getAppointments();
  //   appointments.forEach((appointment) {
  //     _db
  //         .doc(
  //             '${appointment.clientReference}/Cleaning History/${appointment.appointmentId}')
  //         .update({'from': appointment.from}).catchError((onError) {
  //       print(appointment.clientReference);

  //       print(onError);
  //     });
  //   });
  // }

  List<TimeTile> generateAvailabilities(DateTime selectedDate,
      DateTime timeToStart, List<Appointment> reservedTimes) {
    List<TimeTile> _availableTimes = [];
    for (var i = 0; i < scheduleSettings.servicesPerGroup; i++) {
      i == 0
          ? _availableTimes.add(TimeTile(selectedDate
              .add(Duration(
                  hours: timeToStart.hour, minutes: timeToStart.minute))
              .add(Duration(
                minutes: ((scheduleSettings.timePerService.totalInMin * i)),
              ))))
          : _availableTimes.add(TimeTile(
              selectedDate
                  .add(Duration(
                      hours: timeToStart.hour, minutes: timeToStart.minute))
                  .add(Duration(
                    minutes: (scheduleSettings.timePerService.totalInMin +
                            scheduleSettings.timeBetweenService.totalInMin) *
                        i,
                  )),
            ));
    }
    _availableTimes = removeReservedTimes(_availableTimes, reservedTimes);
    return _availableTimes;
  }

  List<TimeTile> removeReservedTimes(
      List<TimeTile> availableTimes, List<Appointment> reservedTimes) {
    availableTimes.forEach((timeTile) {
      for (int i = 0; i < reservedTimes.length; i++) {
        if (timeTile.time == reservedTimes[i].from) {
          timeTile.timeSlotTaken = true;
          timeTile.appointment = reservedTimes[i];
          timeTile.color = Colors.green;
          reservedTimes.removeAt(i);
          break;
        } else {
          timeTile.timeSlotTaken = false;
        }
      }
    });
    return availableTimes;
  }

  Future<Client> getClient(String reference) async {
    DocumentSnapshot snap = await _db.doc(reference).get();

    return Client.fromDocumentSnap(snap);
  }

  Future<List<Appointment>> getFutureAppointments() async {
    List<Client> _clients = await _getAllClients();
    List<Appointment> appointments = [];
    _clients.forEach((client) {
      appointments.add(Appointment(
          client.firstAndLastFormatted,
          client.calculateTimeForCleaningAndSchedule().from,
          client.calculateTimeForCleaningAndSchedule().to,
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
        print('$newAdminNotificationCount');
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

  void updateClient(Client client, Map<String, dynamic> data) async =>
      await _easyDb.editDocumentData('Users/${client.id}', data);

  // void addHistoryToEachCustomer() async {
  //   List<Client> _clients = await _getAllClients();
  //   _clients.forEach((client) async {
  //     _db.doc('Users/${client.id}').update({'templateReminderMsg': ''});
  //   });
  // }

  Future<List<Client>> _getAllClients({bool activeOnly = true}) async {
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

  Future<double> getWeekTotalMinusWorkerFees() async {
    List<Appointment> _appointments = await _getAppointments();

    _appointments.removeWhere((appointment) => appointment.checkInTheWeek(
        DateTime(2020, 10, 5), DateTime(2020, 10, 11)));
    double total = 0;
    print(_appointments.length);
    _appointments.forEach((appointment) => total += appointment.serviceCost);
    return total;
  }

  Future<List<Appointment>> _getAppointments(
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

  Future<double> getDayTotal(int day, DateTime start) async {
    List<Appointment> _appointments = await _getAppointments();
    _appointments.removeWhere((appointment) => !appointment.fromDateOnly
        .isAtSameMomentAs(start.add(Duration(days: day))));
    // print(_appointments.length);
    double total = 0;
    _appointments.forEach((appointment) {
      if (appointment.services.isNotEmpty) {
        appointment.services.forEach((service) {
          if (service.selected) {
            total += service.cost;
          }
        });
      }
      total += appointment.serviceCost;
    });
    // print(total);
    return total;
  }

  Future<double> getWeekTotal(DateTime start) async {
    List<Appointment> _appointments = await _getAppointments();
    _appointments.removeWhere((appointment) =>
        appointment.checkInTheWeek(start, start.add(Duration(days: 6))));
    double total = 0;
    _appointments.forEach((appointment) {
      if (appointment.services.isNotEmpty) {
        appointment.services.forEach((service) {
          if (service.selected) {
            total += service.cost;
          }
        });
      }
      total += appointment.serviceCost;
    });
    return total;
  }

  Future<int> get getTotalClients async {
    List<Client> _customers = await _getAllClients();
    return _customers.length;
  }

  Future<double> getTotalMonthlyProfit(int month) async {
    double total = 0;
    List<Appointment> _appointments =
        await _getAppointments(confirmedOnly: true);
    _appointments.forEach((appointment) {
      if (appointment.from.month == month) {
        if (appointment.services.isNotEmpty) {
          appointment.services.forEach((service) {
            if (service.selected) {
              total += service.cost;
            }
          });
        }
        total += appointment.serviceCost;
      }
    });
    return total;
  }

  Future<double> get getTotalClientsMonthlyPay async {
    double total = 0;
    List<Client> _customers = await _getAllClients(activeOnly: true);
    _customers.forEach((client) {
      switch (client.serviceFrequency) {
        case ServiceFrequency.weekly:
          total += client.costPerCleaning * 4;

          break;
        case ServiceFrequency.biWeekly:
          total += client.costPerCleaning * 2;

          break;
        default:
          total += client.costPerCleaning;
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

  // Future<void> moveAppointments() async {
  //   List<Appointment> appointments = await _getAppointments();
  //   appointments.forEach((appointment) {
  //     _easyDb.createUserData(
  //         'Users/$id/Appointments/${appointment.appointmentId}',
  //         appointment.toDocument(),
  //         createAutoId: false,
  //         addAutoIDToDoc: false);
  //   });
  // }

  void updateAppointment(Appointment appointment, Map<String, dynamic> data,
      Map<String, dynamic> duplicateData) async {
    await _easyDb.editDocumentData(
        'Users/${appointment.client.id}/Cleaning History/${appointment.appointmentId}',
        duplicateData);
    return await _easyDb.editDocumentData(
        "Users/$id/Appointments/${appointment.appointmentId}", data);
  }

  TwilioFlutter setupTwilioFlutter() => _twilioFlutter = TwilioFlutter(
        accountSid: liveSID,
        authToken: liveAuth,
        twilioNumber: twilioNumber,
      );

  Future<List<PhoneNumber>> searchAvailbleNumbers(Function(bool) isLoading,
      {String areaCode = '',
      int pageSize = 20,
      bool smsEnabled = true,
      bool voiceEnabled = true}) async {
    setupTwilioFlutter();
    return await _twilioFlutter.getAvailablePhoneNumbers(isLoading,
        areaCode: areaCode,
        pageSize: pageSize,
        smsEnabled: smsEnabled,
        voiceEnabled: voiceEnabled);
  }

  Future<List<PhoneNumber>> getActivePhoneNumbers(
    Function(bool) isLoading,
  ) async {
    setupTwilioFlutter();
    return await _twilioFlutter.getActivePhoneNumbers(
      isLoading,
    );
  }

  Future<void> provisionPhoneNumber(Function(bool) isLoading,
      {String phoneNumber, @required Function() onDone}) async {
    setupTwilioFlutter();
    return await _twilioFlutter.provisionPhoneNumber(
      isLoading,
      phoneNumber: phoneNumber,
      onDone: () => onDone(),
    );
  }

  void reply(String body, String to, Client client) async {
    setupTwilioFlutter();
    await _twilioFlutter
        .sendSMS(toNumber: to, messageBody: body)
        .whenComplete(() {
      _db.collection('Users/${client.id}/SMS').add({
        'to': to,
        'from': twilioNumber,
        'body': body,
        'adminUserId': id,
        'createdAt': DateTime.now()
      });
      print('Message sent');
    });
  }

  void replyMedia(
      String body, String to, Client client, String mediaUrl) async {
    setupTwilioFlutter();
    await _twilioFlutter
        .sendMediaSMS(toNumber: to, messageBody: body, mediaUrl: mediaUrl)
        .whenComplete(() {
      _db.collection('Users/${client.id}/SMS').add({
        'to': to,
        'from': twilioNumber,
        'body': body,
        'mediaUrl': mediaUrl,
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

  String createDynamicMessage(
      String message, Appointment appointment, Client client,
      {List<dynamic> values}) {
    int index = 1;
    Map<String, dynamic> fillInValues = {
      'firstName': client.firstName,
      'lastName': client.lastName,
      'cleaningCost': appointment.serviceCost.toString(),
      'fullDateTime': appointment.getMsgReadyFullDateTime,
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
    setupTwilioFlutter();
    DocumentSnapshot clientSnap =
        await _db.doc(appointment.clientReference).get();
    Client client = Client.fromDocumentSnap(clientSnap);
    String msg;
    if (client.templateReminderMsg.isEmpty) {
      msg = createDynamicMessage(templateReminderMsg, appointment, client,
          values: templateFillInValues);
      print(createDynamicMessage(templateReminderMsg, appointment, client,
          values: templateFillInValues));
    } else {
      msg = createDynamicMessage(
          client.templateReminderMsg, appointment, client,
          values: client.templateFillInValues);
      print(createDynamicMessage(
          client.templateReminderMsg, appointment, client,
          values: client.templateFillInValues));
    }
    Future.delayed(Duration(seconds: 1), () async {
      await _twilioFlutter.flow.sendAutoReminderRequest(
          (res, statusCode, data) => requestResponse(res),
          toNumber: client.formatPhoneNumber,
          id: appointment.appointmentId,
          clientId: appointment.client.id,
          adminUserId: id,
          firstName: client.firstName,
          message: """$msg""",
          flowSID: 'FWa0015a82a19e38f4b8348943762f0ba4');
    }).whenComplete(() {
      // _db.collection('Users/${client.id}/SMS').add({
      //   'to': client.formatPhoneNumber,
      //   'from': twilioNumber,
      //   'body': """$msg""",
      //   'createdAt': DateTime.now()
      // });
    });
  }

  void sendBroadcastMessageWithMedia(String mediaUrl) async {
    List<Client> clients = await _getAllClients(activeOnly: true);
    clients.forEach((client) {
      String msg = """
Dear ${client.firstName},

There is no better time than the holidays to reminisce on the past year. It has been a tough transition since my mom passed away, but I thank you ${client.firstName} for your patience and for supporting my business "The Cleaning Ladies". May you have a merry holiday and a prosperous New Year.
""";
      // print(
      //     '(${client.firstName}, ${client?.lastName ?? ''} active: ${client.active}) sending...');
      // if (client.contactNumber == '+19092223241') {
      sendSMSForBroadcast(client, mediaUrl, msg);
      // }
    });
  }

  void sendSMSForBroadcast(Client client, String mediaUrl, String messageBody) {
    setupTwilioFlutter();

    Future.delayed(Duration(seconds: 2), () async {
      await _twilioFlutter.sendMediaSMS(
          toNumber: client.formatPhoneNumber,
          messageBody: """$messageBody""",
          mediaUrl: mediaUrl);
    }).whenComplete(() {
      _db.collection('Users/${client.id}/SMS').add({
        'to': client.formatPhoneNumber,
        'from': twilioNumber,
        'mediaUrl': mediaUrl,
        'body': """$messageBody""",
        'createdAt': DateTime.now()
      });
    });
  }

  Future<List<SMS>> getSmSList() async {
    setupTwilioFlutter();
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
    setupTwilioFlutter();
    return await _twilioFlutter.getSpecificSmsList(from, to);
  }

  void createAppointment(Appointment appointment) async {
    Client _client = appointment.client;
    print('creating appointment for Customer ID: ${_client.id}');
    return await _easyDb.createUserData(
        'Users/$id/Appointments', appointment.toDocument(),
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
        .where('businessCode', isEqualTo: '$businessCode')
        .where('activeForCleaning', isEqualTo: true)
        .get()
        .then((snap) =>
            snap.docs.map((doc) => Client.fromDocumentSnap(doc)).toList());
  }

  void _tryScheduling(List<Client> customers) {
    for (Client customer in customers) {
      // Map<String, DateTime> nextCleaning = customer.calculateNextCleaning();
      Appointment appointment = customer.calculateTimeForCleaningAndSchedule();
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
        userType: userTypes['${doc['userType']}'],
        id: document.id,
        ref: document.reference,
        templateReminderMsg: doc['templateReminderMsg'],
        templateFillInValues: doc['templateFillInValues'],
        scheduleSettings: ScheduleSettings.fromDocument(document),
        twilioNumber: doc['apiPN'],
        notificationCount: doc['notificationCount'],
        businessCode: doc['businessCode']);
  }
  Map<String, Object> toDocument() {
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
      'templateReminderMsg': '',
      'templateFillInValues': [],
      'scheduleSettings': ScheduleSettings(
              servicesPerGroup: 4,
              timeBetweenService: ElapsedTime(hour: 00, min: 20),
              timePerService: ElapsedTime(hour: 2, min: 00))
          .toDocument(),
      'apiPN': '',
      'notificationCount': 0,
      'businessCode': businessCode,
    };
  }
}
