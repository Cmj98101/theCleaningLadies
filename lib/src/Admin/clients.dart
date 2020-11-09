import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/src/Admin/EasyDB/EasyDb.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';

class Clients {
  final Widget clientsList;
  final Admin admin;
  final EasyDB easyDB;
  Clients(this.admin, this.easyDB, {@required this.clientsList});
  // Function(BuildContext) show = (context) => Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => MyClients(admin: admin, easyDB: easyDB)));
  // Widget show() {
  //   return await Navigator.push(context, route);
  // }
}
