import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  String from;
  String to;
  String body;
  DateTime createdAt;
  Message(
      {@required this.from,
      @required this.to,
      @required this.body,
      @required this.createdAt});

  factory Message.fromDocument(DocumentSnapshot document) {
    Map<String, dynamic> doc = document.data();

    return Message(
        from: doc['from'],
        to: doc['to'],
        body: doc['body'],
        createdAt: (doc['createdAt'] as Timestamp).toDate());
  }
}
