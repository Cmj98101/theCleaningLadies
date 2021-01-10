import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/models/service/service.dart' as service;

class Service {
  final Client client;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Service(this.client);
  Stream<List<HistoryEvent>> get history {
    return _db
        .collection('Users/${client.id}/Cleaning History')
        .orderBy('from', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => HistoryEvent.fromDocument(doc))
            .toList());
  }

  Stream<List<HistoryEvent>> get profits {
    return _db
        .collection('Users/${client.id}/Cleaning History')
        .orderBy('from', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => HistoryEvent.fromDocument(doc))
            .toList());
  }

  factory Service.create(Client client) {
    return Service(client);
  }
}

class HistoryEvent {
  final DateTime from;
  final String appointmentId;
  final bool isConfirmed;
  final double fee;
  final List<service.Service> services;
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
  HistoryEvent({
    @required this.from,
    @required this.appointmentId,
    @required this.fee,
    this.services,
    this.isConfirmed = false,
  });
  String get formattedFrom => DateFormat('MM/dd/yy').format(from);
  String get weekDay => weekDays[from.weekday];
  String get formattedMonth => month[from.month];
  String get formattedDate => '$weekDay $formattedMonth ${from.day}';
  factory HistoryEvent.fromDocument(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data();
    return HistoryEvent(
        from: (data['from'] as Timestamp).toDate(),
        appointmentId: doc.id,
        fee: data['fee'],
        isConfirmed: data['isConfirmed']);
  }
  factory HistoryEvent.fromAppointmentDocument(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data();
    return HistoryEvent(
        from: (data['from'] as Timestamp).toDate(),
        appointmentId: data['id'],
        fee: data['cleaningCost'],
        isConfirmed: data['isConfirmed']);
  }
  factory HistoryEvent.fromAppointment(Appointment appointment) {
    return HistoryEvent(
        from: appointment.from,
        appointmentId: appointment.appointmentId,
        fee: appointment.serviceCost,
        isConfirmed: appointment.isConfirmed,
        services: appointment.services);
  }
  Map<String, Object> toDocument() {
    return {
      'from': from,
      'fee': fee,
      'isConfirmed': isConfirmed,
      'services': services.map((service) => service.toDocument()).toList()
    };
  }

  // Map<String, Object> fromMap(Map<String, Object> data) {
  //   return {
  //     'from': data['from'],
  //     'appointmentId': data['id'],
  //     'fee': data['cleaningCost'],
  //     'isConfirmed': data['isConfirmed']
  //   };
  // }
}
