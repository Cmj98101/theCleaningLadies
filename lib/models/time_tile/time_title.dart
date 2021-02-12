import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';

class TimeTile {
  final Admin admin;
  DateTime time;
  DateTime orignalTime;
  List<TimeTile> availableTimes;
  Color color = Colors.white;
  String get fromTimeFormatted => DateFormat('h:mm a').format(time);
  String get toTimeFormatted => DateFormat('h:mm a').format(time.add(Duration(
      hours: admin.scheduleSettings.leadTime.hour,
      minutes: admin.scheduleSettings.leadTime.min)));
  bool timeSlotTaken;
  Appointment appointment;
  bool undoAvailable = false;
  TimeTile(this.time, this.admin,
      {this.appointment,
      this.timeSlotTaken,
      this.color,
      this.undoAvailable,
      @required this.orignalTime});
  factory TimeTile.clone(TimeTile time,
      {DateTime newTime,
      DateTime orignalTime,
      Appointment appointment,
      bool timeSlotTaken,
      Color color,
      bool copyAppointment = true,
      orignalTimeSameAsNewTime = false}) {
    TimeTile timeTile = TimeTile(newTime ?? time.time, time.admin,
        appointment:
            copyAppointment ? appointment ?? time.appointment : appointment,
        timeSlotTaken: timeSlotTaken ?? time.timeSlotTaken,
        color: color ?? time.color,
        undoAvailable: time.undoAvailable ?? true,
        orignalTime: time.orignalTime);
    if (orignalTimeSameAsNewTime) {
      timeTile.orignalTime = timeTile.time;
    }
    return timeTile;
  }
  void reset() {
    timeSlotTaken = false;
    appointment = null;
    undoAvailable = false;
    color = Colors.white;
  }
}
