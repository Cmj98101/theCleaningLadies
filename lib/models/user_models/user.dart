import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { admin, client }

class User {
  String businessName;
  String firstName;
  String lastName;
  String email;
  String password;
  String id;
  String relation;
  String contactNumber;
  String streetAddress;
  String buildingNumber;
  String city;
  String state;
  String zipCode;

  UserType userType;
  DocumentReference ref;
  // User get userRole => UserType.values.firstWhere((userType) => userType.toString())
  User({
    this.businessName,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.id,
    this.userType,
    this.ref,
    this.contactNumber,
    this.streetAddress,
    this.buildingNumber,
    this.city,
    this.state,
    this.zipCode,
  });
  User.family({
    this.firstName,
    this.lastName,
    this.relation,
  });
}
