import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';

class TimeTile {
  DateTime time;
  List<TimeTile> availableTimes;
  Color color = Colors.white;
  String get fromTimeFormatted => DateFormat('h:mm a').format(time);
  //TODO: Make admin decide lead time for appointments
  String get toTimeFormatted =>
      DateFormat('h:mm a').format(time.add(Duration(minutes: 45)));
  bool timeSlotTaken;
  Appointment appointment;
  bool undoAvailable = false;
  TimeTile(this.time, {this.appointment, this.timeSlotTaken, this.color});

  void reset() {
    timeSlotTaken = false;
    appointment = null;
    undoAvailable = false;
    color = Colors.white;
  }
}
