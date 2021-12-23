import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/src/Admin/views/Settings/reminderSettings.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';

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
