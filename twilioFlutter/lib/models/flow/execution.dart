import 'package:flutter/material.dart';

enum ExecutionStatus { active, ended }

class Execution {
  String sid;
  String flowSID;
  ExecutionStatus status;
  Execution(
      {@required this.sid, @required this.flowSID, @required this.status});
}
