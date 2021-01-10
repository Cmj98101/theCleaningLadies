import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';

class Service {
  Admin admin;
  String name;
  Duration duration;
  double cost;
  bool selected = false;
  DocumentReference ref;
  List<Service> list = [];
  factory Service.clone(Service service) {
    return Service(
        name: service.name,
        duration: service.duration,
        cost: service.cost,
        ref: service.ref,
        selected: false);
  }
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Service.init({@required this.admin}) {
    loadServices();
  }
  Service({this.name, this.duration, this.cost, this.ref, this.selected});
  void loadServices() async {
    QuerySnapshot servicesSnap =
        await _db.collection('Users/${admin.id}/Services').get();

    list = servicesSnap.docs.map((doc) => Service.fromDocument(doc)).toList();
  }

  void add(Service service) async {
    await _db
        .collection('Users/${admin.id}/Services')
        .add(service.toDocument());
  }

  Stream<List<Service>> get toList => _db
      .collection('Users/${admin.id}/Services')
      .snapshots()
      .map((querySnapshot) =>
          querySnapshot.docs.map((doc) => Service.fromDocument(doc)).toList());

  factory Service.fromDocument(DocumentSnapshot doc) {
    return Service(
      name: doc['name'],
      duration: Duration(minutes: doc['duration']),
      cost: doc['cost'],
      ref: doc.reference,
    );
  }
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
        name: map['name'],
        duration: Duration(minutes: map['duration']),
        cost: (map['cost'] is int)
            ? (map['cost'] as int).toDouble()
            : map['cost'],
        selected: map['selected']);
  }

  Map<String, Object> toDocument() {
    return {
      'name': name,
      'duration': duration.inMinutes,
      'cost': cost,
      'selected': selected
    };
  }
}
