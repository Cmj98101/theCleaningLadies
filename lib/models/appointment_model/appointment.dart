import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';
import 'package:the_cleaning_ladies/models/service/service.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';

class Appointment {
  EasyDB _easyDb = DataBaseRepo();

  Appointment.creationFailure() {
    print('No Appointment Created');
  }

  Appointment(this.eventName, this.from, this.to, this.background,
      this.isAllDay, this.client,
      {this.appointmentId,
      this.recurrenceRule,
      this.isConfirmed,
      this.isRescheduling,
      this.noReply,
      this.clientReference,
      this.contactNumber,
      this.sendConfirmation,
      this.isReminderSent,
      this.serviceCost,
      this.keyRequired,
      this.note,
      this.flowSID,
      this.executionSID,
      this.admin,
      this.services,
      this.ref}) {
    assert(admin != null);
    if (admin != null) {
      services = <Service>[];
      for (Service service in admin.services.list) {
        services.add(Service.clone(service));
      }
    }
  }
  Appointment.fromDB(this.eventName, this.from, this.to, this.background,
      this.isAllDay, this.client,
      {this.appointmentId,
      this.recurrenceRule,
      this.isConfirmed,
      this.isRescheduling,
      this.noReply,
      this.clientReference,
      this.contactNumber,
      this.sendConfirmation,
      this.isReminderSent,
      this.serviceCost,
      this.keyRequired,
      this.note,
      this.flowSID,
      this.executionSID,
      this.admin,
      this.services,
      this.ref});

  Appointment.newAppointment(
      {this.eventName,
      this.from,
      this.to,
      this.background,
      this.isAllDay,
      this.client,
      this.appointmentId,
      this.recurrenceRule,
      this.exceptionDates,
      this.isConfirmed,
      this.contactNumber,
      this.note,
      this.flowSID,
      this.executionSID,
      this.ref});
  Client client;
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String appointmentId;
  String recurrenceRule;
  String clientReference;
  String contactNumber;
  String note;
  bool isExpanded = false;
  bool isConfirmed;
  bool isRescheduling;
  bool noReply;
  bool keyRequired;
  double serviceCost;
  List<Service> services = [];
  Admin admin;
  String flowSID;
  String executionSID;
  DocumentReference ref;

  // ignore: slash_for_doc_comments
  /**  
   *If true then send a reminder text
   *      
   *      if(sendConfirmation){ 
   *        sendReminderText(); // Sending Reminder Text...
   *      }
   * 
  */
  bool sendConfirmation = true;
  bool isReminderSent = false;
  List<DateTime> exceptionDates;

  DateTime get fromDateOnly => DateTime(from.year, from.month, from.day);
  bool checkInTheWeek(DateTime start, DateTime end) {
    bool isBefore = fromDateOnly.isBefore(start);
    bool isAfter = fromDateOnly.isAfter(end);
    return isBefore == false && isAfter == false ? false : true;
  }

  Map month = {
    1: 'Jan.',
    2: 'Feb.',
    3: 'Mar.',
    4: 'Apr.',
    5: 'May',
    6: 'Jun.',
    7: 'Jul.',
    8: 'Aug.',
    9: 'Sep.',
    10: 'Oct.',
    11: 'Nov.',
    12: 'Dec.',
  };
  Map weekDays = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };
  String get getMsgReadyFullDateTime =>
      '$fromMonth ${from.day}, $day @ ~$fromTimeFormatted - $toTimeFormatted';
  String get day => weekDays[from.weekday];
  String get fromMonth => month[from.month];
  String get toMonth => month[to.month];
  String get fromFullyFormatted => DateFormat('MM/dd/yy h:mm a').format(from);
  String get toFullyFormatted => DateFormat('MM/dd/yy h:mm a').format(to);
  String get fromDateFormatted => DateFormat('MM/dd/yy').format(from);
  String get toDateFormatted => DateFormat('MM/dd/yy').format(to);
  String get fromTimeFormatted => DateFormat('h:mm a').format(from);
  String get toTimeFormatted => DateFormat('h:mm a').format(to);
  String get formattedAppointmentDateTime =>
      '$fromDateFormatted \n@ $fromTimeFormatted - $toTimeFormatted';
  String get formattedAppointmentTimeComplete =>
      '@ $fromTimeFormatted - $toTimeFormatted';

  Future<Client> getClientData(String ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snap = await db.doc(ref).get();
    // print(snap.data()['businessCode']);
    return Client.fromDocumentSnap(snap);
  }

  Future<void> getIsReminderSent(Admin admin) async {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    DocumentSnapshot appointmentSnap =
        await _db.doc('Users/${admin.id}/Appointments/$appointmentId').get();
    Map<String, dynamic> data = appointmentSnap.data();
    isReminderSent = data['isReminderSent'];
  }

  void update(Appointment appointment, Map<String, dynamic> data,
      Map<String, dynamic> duplicateData) async {
    await _easyDb.editDocumentData(
        'Users/${appointment.client.id}/Cleaning History/${appointment.appointmentId}',
        duplicateData);
    return await _easyDb.editDocumentData(
        "Users/${admin.id}/Appointments/${appointment.appointmentId}", data);
  }

  factory Appointment.clone(Appointment appointment,
      {DateTime from, DateTime to}) {
    return Appointment(
        appointment.eventName ?? '',
        from ?? appointment.from,
        to ?? appointment.to,
        appointment.background,
        appointment.isAllDay,
        appointment.client,
        isConfirmed: appointment.isConfirmed,
        isRescheduling: appointment.isRescheduling,
        noReply: appointment.noReply,
        serviceCost: appointment.client.costPerCleaning,
        keyRequired: appointment.client.keyRequired,
        note: appointment.client.note,
        admin: appointment.admin);
  }
  factory Appointment.fromDocument(DocumentSnapshot document,
      {@required Admin admin}) {
    Map<String, dynamic> doc = document.data();
    Client client = Client();
    ServiceFrequency serviceFrequency =
        client.serviceFrequencyFromDoc(document);
    return Appointment.fromDB(
        '${doc['eventName']}',
        (doc['from'] as Timestamp).toDate(),
        (doc['to'] as Timestamp).toDate(),
        doc['isConfirmed']
            ? Colors.green
            : doc['isRescheduling']
                ? Colors.yellow[700]
                : Colors.red,
        false,
        Client(
          id: doc['clientId'],
          serviceFrequency: serviceFrequency,
          contactNumber: doc['contactNumber'],
        ),
        clientReference: doc['clientReference'],
        appointmentId: document.id,
        isConfirmed: doc['isConfirmed'],
        isRescheduling: doc['isRescheduling'],
        noReply: doc['noReply'],
        sendConfirmation: true,
        isReminderSent: doc['isReminderSent'],
        serviceCost: (doc['cleaningCost'] is int)
            ? (doc['cleaningCost'] as int).toDouble()
            : doc['cleaningCost'],
        keyRequired: doc['keyRequired'],
        note: doc['note'] ?? '',
        flowSID: doc['flowSID'] ?? '',
        executionSID: doc['executionSID'] ?? '',
        admin: admin,
        services: doc['services'] != null
            ? (doc['services'] as List<dynamic>)
                .map((map) => Service.fromMap(map))
                .toList()
            : <Service>[],
        ref: document.reference);
  }
  Map<String, Object> toDocument() {
    List<Map<String, Object>> servicesSelected = [];
    services.forEach((service) {
      if (service.selected) {
        return servicesSelected.add(service.toDocument());
      }
    });
    return {
      'eventName': client.firstAndLastFormatted,
      'from': from,
      'to': to,
      'isAllDay': false,
      'clientId': "${client.id}",
      'clientReference': 'Users/${client.id}',
      'serviceFrequency': '${client.serviceFrequency.toString()}',
      'isConfirmed': isConfirmed,
      'isRescheduling': isRescheduling,
      'noReply': noReply,
      'contactNumber': client.contactNumber,
      'isReminderSent': false,
      'cleaningCost': serviceCost,
      'keyRequired': keyRequired,
      'note': note,
      'flowSID': flowSID,
      'executionSID': executionSID,
      'services': servicesSelected
    };
  }

  factory Appointment.demo(Admin admin) {
    return Appointment(
        'eventName',
        DateTime.now(),
        DateTime.now(),
        Colors.red,
        false,
        Client(
          firstName: 'firstName',
          lastName: 'lastName',
          id: 'clientId',
          serviceFrequency: ServiceFrequency.monthly,
          contactNumber: 'contactNumber',
        ),
        clientReference: 'clientReference',
        appointmentId: 'document.id',
        isConfirmed: false,
        isRescheduling: false,
        noReply: false,
        sendConfirmation: true,
        isReminderSent: false,
        serviceCost: 1,
        keyRequired: false,
        flowSID: '',
        executionSID: '',
        admin: admin);
  }
}
