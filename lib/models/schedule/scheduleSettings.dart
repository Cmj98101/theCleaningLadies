import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/elapsedTime.dart';

class ScheduleSettings {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  ElapsedTime timePerService;
  ElapsedTime timeBetweenService;
  ElapsedTime leadTime;
  ElapsedTime reminderNotificationTime;
  Duration get remindBeforeTime => Duration(
      days: reminderNotificationTime.days,
      hours: reminderNotificationTime.hour,
      minutes: reminderNotificationTime.min);
  String get reminderInDays =>
      '${reminderNotificationTime.days == 0 ? '' : reminderNotificationTime.days == 1 ? '${reminderNotificationTime.days} day' : '${reminderNotificationTime.days} days'}';
  String get reminderInHour =>
      '${reminderNotificationTime.hour == 0 ? '' : reminderNotificationTime.hour == 1 ? '${reminderNotificationTime.hour} hr.' : '${reminderNotificationTime.hour} hrs.'}';

  String get reminderInMin =>
      '${reminderNotificationTime.min == 0 ? '' : reminderNotificationTime.min == 1 ? '${reminderNotificationTime.min} min.' : '${reminderNotificationTime.min} minutes'}';

  String get remindBeforeTimeToString {
    return '$reminderInDays $reminderInHour $reminderInMin';
  }

  int servicesPerGroup;
  ScheduleSettings(
      {@required this.timePerService,
      @required this.timeBetweenService,
      @required this.servicesPerGroup,
      @required this.reminderNotificationTime,
      @required this.leadTime});
  factory ScheduleSettings.standard() {
    return ScheduleSettings(
        servicesPerGroup: 4,
        timeBetweenService: ElapsedTime(days: 0, hour: 00, min: 20),
        timePerService: ElapsedTime(days: 0, hour: 2, min: 00),
        leadTime: ElapsedTime(
          days: 0,
          hour: 0,
          min: 45,
        ),
        reminderNotificationTime: ElapsedTime(days: 0, hour: 2, min: 0));
  }
  void update(String adminId) {
    _db.doc('Users/$adminId').update({'scheduleSettings': this.toDocument()});
  }

  Map<String, Object> toDocument() {
    return {
      'servicesPerGroup': servicesPerGroup,
      'timeBetweenService': timeBetweenService.toDocument(),
      'timePerService': timePerService.toDocument(),
      'leadTime': leadTime.toDocument(),
      'remindBeforeTime': reminderNotificationTime.toDocument()
    };
  }

  factory ScheduleSettings.fromDoc(DocumentSnapshot document) {
    Map<String, dynamic> doc = document.data();

    return ScheduleSettings(
        servicesPerGroup: doc['scheduleSettings']['servicesPerGroup'],
        timeBetweenService: ElapsedTime(
            days: (doc['scheduleSettings']['timeBetweenService']['days']) ?? 0,
            hour: (doc['scheduleSettings']['timeBetweenService']['hour']) ?? 0,
            min: (doc['scheduleSettings']['timeBetweenService']['min']) ?? 0),
        timePerService: ElapsedTime(
            days: (doc['scheduleSettings']['timePerService']['days']) ?? 0,
            hour: (doc['scheduleSettings']['timePerService']['hour']) ?? 0,
            min: (doc['scheduleSettings']['timePerService']['min']) ?? 0),
        reminderNotificationTime: ElapsedTime(
            days: (doc['scheduleSettings']['remindBeforeTime']['days']) ?? 0,
            hour: (doc['scheduleSettings']['remindBeforeTime']['hour']) ?? 0,
            min: (doc['scheduleSettings']['remindBeforeTime']['min']) ?? 0),
        leadTime: ElapsedTime(
            days: (doc['scheduleSettings']['leadTime']['days']) ?? 0,
            hour: (doc['scheduleSettings']['leadTime']['hour']) ?? 0,
            min: (doc['scheduleSettings']['leadTime']['min']) ?? 0));
  }
}
