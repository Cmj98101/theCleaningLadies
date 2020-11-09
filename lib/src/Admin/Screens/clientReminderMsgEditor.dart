import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/Settings/reminderSettings.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';

class ClientReminderMsgEditor extends StatelessWidget {
  final Admin admin;
  final bool isClientSide;
  final Client client;
  ClientReminderMsgEditor(
      {@required this.admin, this.isClientSide = false, this.client});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EditReminderTemplate(
        admin: admin,
        isClientSide: true,
        client: client,
      ),
    );
  }
}
