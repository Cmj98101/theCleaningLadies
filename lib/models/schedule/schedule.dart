import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/schedule/scheduleSettings.dart';
import 'package:the_cleaning_ladies/models/time_tile/time_title.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';

class Schedule {
  Admin admin;
  ScheduleSettings scheduleSettings;
  Schedule.init({@required this.admin, @required this.scheduleSettings});

  List<TimeTile> generateAvailabilities(DateTime selectedDate,
      DateTime timeToStart, List<Appointment> reservedTimes) {
    assert(selectedDate != null);
    assert(timeToStart != null);
    assert(reservedTimes != null);

    List<TimeTile> _availableTimes = [];
    for (var i = 0; i < scheduleSettings.servicesPerGroup; i++) {
      i == 0
          ? _availableTimes.add(TimeTile(
              selectedDate
                  .add(Duration(
                      hours: timeToStart.hour, minutes: timeToStart.minute))
                  .add(Duration(
                    minutes: ((scheduleSettings.timePerService.totalInMin * i)),
                  )),
              admin,
              orignalTime: selectedDate
                  .add(Duration(
                      hours: timeToStart.hour, minutes: timeToStart.minute))
                  .add(Duration(
                    minutes: (scheduleSettings.timePerService.totalInMin +
                            scheduleSettings.timeBetweenService.totalInMin) *
                        i,
                  )),
              timeSlotTaken: false,
              undoAvailable: false))
          : _availableTimes.add(TimeTile(
              selectedDate
                  .add(Duration(
                      hours: timeToStart.hour, minutes: timeToStart.minute))
                  .add(Duration(
                    minutes: (scheduleSettings.timePerService.totalInMin +
                            scheduleSettings.timeBetweenService.totalInMin) *
                        i,
                  )),
              admin,
              orignalTime: selectedDate
                  .add(Duration(
                      hours: timeToStart.hour, minutes: timeToStart.minute))
                  .add(Duration(
                    minutes: (scheduleSettings.timePerService.totalInMin +
                            scheduleSettings.timeBetweenService.totalInMin) *
                        i,
                  )),
              timeSlotTaken: false,
              undoAvailable: false));
    }
    _availableTimes = removeReservedTimes(_availableTimes, reservedTimes);
    return _availableTimes;
  }

  List<TimeTile> removeReservedTimes(
      List<TimeTile> availableTimes, List<Appointment> reservedTimes) {
    availableTimes.forEach((timeTile) {
      for (int i = 0; i < reservedTimes.length; i++) {
        if (timeTile.time == reservedTimes[i].from) {
          timeTile.timeSlotTaken = true;
          timeTile.appointment = reservedTimes[i];
          timeTile.color = Colors.green;
          reservedTimes.removeAt(i);
          break;
        } else {
          timeTile.timeSlotTaken = false;
        }
      }
    });
    return availableTimes;
  }
}
