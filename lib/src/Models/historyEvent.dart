import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/src/Widgets/CalendarWidget/calendar.dart';

class HistoryEvent {
  final DateTime from;
  final String appointmentId;
  final bool isConfirmed;
  final int fee;

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
        fee: appointment.cleaningCost,
        isConfirmed: appointment.isConfirmed);
  }
  Map<String, Object> toDocument() {
    return {'from': from, 'fee': fee, 'isConfirmed': isConfirmed};
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
