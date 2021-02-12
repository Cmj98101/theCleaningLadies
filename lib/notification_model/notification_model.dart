import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  /// Notification Title
  String title;

  /// Notification Body
  String body;

  /// Notification Id
  final int id;

  /// Notification payload
  String payload;

  /// Document Reference
  final DocumentReference ref;

  /// Date/Time to be reminded at
  DateTime reminderFor;

  /// Is the Notification set to notify Admin
  bool isSet;
  NotificationModel(
      {@required this.title,
      @required this.body,
      @required this.id,
      @required this.payload,
      @required this.ref,
      @required this.reminderFor,
      @required this.isSet});

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    return NotificationModel(
        title: doc['title'],
        body: doc['body'],
        id: doc['id'],
        payload: doc['payload'],
        reminderFor: (doc['reminderFor'] as Timestamp).toDate(),
        isSet: doc['isSet'],
        ref: doc.reference);
  }
  Map<String, Object> toDoc() {
    return {
      'title': title,
      'body': body,
      'id': id,
      'payload': '',
      'reminderFor': reminderFor,
      'isSet': isSet,
    };
  }

  @override
  String toString() =>
      'isSet: $isSet, \n reminderFor: $reminderFor, \n title: $title, \n body: $body, \n id: $id';
}
