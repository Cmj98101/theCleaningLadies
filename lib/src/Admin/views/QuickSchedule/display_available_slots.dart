import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/service/service.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/models/time_tile/time_title.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/src/admin/views/QuickSchedule/expansionServiceTile.dart';
import 'package:the_cleaning_ladies/src/admin/views/QuickSchedule/selectClientForAppointment.dart';
import 'package:the_cleaning_ladies/widgets/raisedButtonX.dart';

class DisplayAvailableTimesWidget extends StatefulWidget {
  final DateTime selectedDate;
  final List<TimeTile> availableTimes;
  final Function(DateTime) rescheduleDateTime;
  final bool quickSchedule;
  final Function(List<TimeTile>) appointmentsToConfirm;
  final Admin admin;
  final Client client;
  final List<TimeTile> unconfirmedAppointments;
  final bool isRescheduling;

  DisplayAvailableTimesWidget(
      this.selectedDate, this.availableTimes, this.quickSchedule,
      {@required this.rescheduleDateTime,
      @required this.unconfirmedAppointments,
      this.appointmentsToConfirm,
      this.client,
      this.isRescheduling,
      @required this.admin});

  @override
  _DisplayAvailableTimesWidgetState createState() =>
      _DisplayAvailableTimesWidgetState();
}

class _DisplayAvailableTimesWidgetState
    extends State<DisplayAvailableTimesWidget> {
  bool addTravelTime = true;
  bool reSort = true;
  bool changeAllFolowingAppointments = false;
  Client client;
  List<TimeTile> appointmentsToConfirm;
  @override
  Widget build(BuildContext context) {
    appointmentsToConfirm =
        List.filled(widget.admin.scheduleSettings.servicesPerGroup, null);

    SizeConfig().init(context);
    return SizeConfig.screenWidth < 600 ? phoneDisplay() : tabletDisplay();
  }

  dynamic selectTime() async {
    TimeOfDay time = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.input,
        initialTime: TimeOfDay(hour: 7, minute: 0));
    return time != null
        ? DateTime(widget.selectedDate.year, widget.selectedDate.month,
            widget.selectedDate.day, time.hour, time.minute)
        : null;
  }

  Widget phoneDisplay() {
    List<TimeTile> availableTimes = widget.availableTimes;
    //Sort Appointments by time
    if (reSort) {
      availableTimes.sort((date1, date2) => date1.time.compareTo(date2.time));
    }
    return Column(
      children: [
        Container(
          width: SizeConfig.safeBlockHorizontal * 74,
          // height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  width: SizeConfig.safeBlockHorizontal * 34,
                  child: ElevatedButtonX(
                    onPressedX: () => addSlot(availableTimes),
                    childX: Text(
                      'Add Slot',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  width: SizeConfig.safeBlockHorizontal * 34,
                  child: ElevatedButtonX(
                    onPressedX: () async => addCustomTimeSlot(availableTimes),
                    childX: Container(
                      child: Text(
                        'Add Custom Slot',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < availableTimes.length; i++)
          availableTimes[i]?.timeSlotTaken ?? false
              ? Container(
                  margin: EdgeInsets.only(top: 10, right: 15, left: 15),
                  alignment: Alignment.center,
                  child: Card(
                      // color: time.color,
                      elevation: 3,
                      child: InkWell(
                        onTap: availableTimes[i].timeSlotTaken
                            ? null
                            : () => selectSlot(availableTimes, i),
                        onLongPress: availableTimes[i].undoAvailable ?? false
                            ? () => resetSlot(availableTimes, i)
                            : null,
                        child: Container(
                          width: SizeConfig.safeBlockHorizontal * 74,
                          // height: SizeConfig.safeBlockVertical * 10,
                          child: ExpansionServiceTile(
                            admin: widget.admin,
                            time: availableTimes[i],
                            availableTimes: widget.availableTimes,
                            recalculateNextAppointment: (inMinutes, isAdding) =>
                                recalculateNextAppointment(
                                    availableTimes, i, isAdding, inMinutes),
                            resetTimeToOriginal: () =>
                                resetSlotToOriginal(availableTimes, i),
                          ),
                        ),
                      )))
              : Container(
                  width: SizeConfig.safeBlockHorizontal * 75,
                  height: SizeConfig.safeBlockVertical * 10,
                  margin: EdgeInsets.only(top: 10, right: 15, left: 15),
                  alignment: Alignment.center,
                  child: Card(
                      color: availableTimes[i].color,
                      elevation: 3,
                      child: InkWell(
                        onTap: availableTimes[i]?.timeSlotTaken ?? false
                            ? null
                            : widget.quickSchedule
                                ? () async =>
                                    await selectAClient(availableTimes, i)
                                : () => selectSlot(availableTimes, i),
                        child: Container(
                          alignment: Alignment.center,
                          // margin: EdgeInsets.all(20),
                          width: SizeConfig.safeBlockHorizontal * 75,
                          height: SizeConfig.safeBlockVertical * 10,
                          child: Text(
                              '${availableTimes[i].fromTimeFormatted} - ${availableTimes[i].toTimeFormatted}',
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center),
                        ),
                      )))
      ],
    );
  }

  Widget tabletDisplay() {
    List<TimeTile> availableTimes = widget.availableTimes;
    //Sort Appointments by time
    if (reSort) {
      availableTimes.sort((date1, date2) => date1.time.compareTo(date2.time));
    }
    return Column(
      children: [
        Container(
          width: SizeConfig.safeBlockHorizontal * 74,
          // height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  width: SizeConfig.safeBlockHorizontal * 34,
                  child: ElevatedButtonX(
                    onPressedX: () => addSlot(availableTimes),
                    childX: Text(
                      'Add Slot',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  width: SizeConfig.safeBlockHorizontal * 34,
                  child: ElevatedButtonX(
                    onPressedX: () async => addCustomTimeSlot(availableTimes),
                    childX: Container(
                      child: Text(
                        'Add Custom Slot',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < availableTimes.length; i++)
          availableTimes[i]?.timeSlotTaken ?? false
              ? Container(
                  margin: EdgeInsets.only(top: 10, right: 15, left: 15),
                  alignment: Alignment.center,
                  child: Card(
                      // color: time.color,
                      elevation: 3,
                      child: InkWell(
                        onTap: availableTimes[i].timeSlotTaken
                            ? null
                            : () => selectSlot(availableTimes, i),
                        onLongPress: availableTimes[i].undoAvailable ?? false
                            ? () => resetSlot(availableTimes, i)
                            : null,
                        child: Container(
                          width: SizeConfig.safeBlockHorizontal * 74,
                          // height: SizeConfig.safeBlockVertical * 10,
                          child: ExpansionServiceTile(
                            admin: widget.admin,
                            time: availableTimes[i],
                            availableTimes: widget.availableTimes,
                            recalculateNextAppointment: (inMinutes, isAdding) =>
                                recalculateNextAppointment(
                                    availableTimes, i, isAdding, inMinutes),
                            resetTimeToOriginal: () =>
                                resetSlotToOriginal(availableTimes, i),
                          ),
                        ),
                      )))
              : Container(
                  width: SizeConfig.safeBlockHorizontal * 75,
                  height: SizeConfig.safeBlockVertical * 10,
                  margin: EdgeInsets.only(top: 10, right: 15, left: 15),
                  alignment: Alignment.center,
                  child: Card(
                      color: availableTimes[i].color,
                      elevation: 3,
                      child: InkWell(
                        onTap: availableTimes[i]?.timeSlotTaken ?? false
                            ? null
                            : widget.quickSchedule
                                ? () async =>
                                    await selectAClient(availableTimes, i)
                                : () => selectSlot(availableTimes, i),
                        child: Container(
                          alignment: Alignment.center,
                          // margin: EdgeInsets.all(20),
                          width: SizeConfig.safeBlockHorizontal * 75,
                          height: SizeConfig.safeBlockVertical * 10,
                          child: Text(
                              '${availableTimes[i].fromTimeFormatted} - ${availableTimes[i].toTimeFormatted}',
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center),
                        ),
                      )))
      ],
    );
  }

  void selectSlot(List<TimeTile> availableTimes, int i) {
    if (widget.isRescheduling) {
      for (var tile in widget.availableTimes) {
        tile.color = Colors.white;
      }
      setState(() {
        availableTimes[i].color = Colors.green;
        widget.rescheduleDateTime(availableTimes[i].time);
      });
      return;
    }
    for (var tile in widget.availableTimes) {
      tile.color = Colors.white;

      if (tile.appointment == null ||
          tile.appointment.appointmentId == null ||
          tile.appointment.appointmentId.isEmpty) {
        tile.reset();
      }
    }
    setState(() {
      if (widget.quickSchedule == false) {
        if (widget.client != null) {
          availableTimes[i].appointment = Appointment(
              widget.client?.firstAndLastFormatted,
              availableTimes[i].time,
              availableTimes[i].time.add(Duration(minutes: 45)),
              Colors.green,
              false,
              widget.client,
              isConfirmed: false,
              isRescheduling: false,
              noReply: false,
              serviceCost: widget.client.costPerCleaning,
              keyRequired: widget.client.keyRequired,
              note: widget.client.note,
              admin: widget.admin);
          setState(() {
            availableTimes[i]
              // ..orignalTime = availableTimes[i].time
              ..timeSlotTaken = true
              ..undoAvailable = true
              ..color = Colors.yellow;
            widget.unconfirmedAppointments[i] = availableTimes[i];
          });
        }
      }
      availableTimes[i].color = Colors.green;
      widget.rescheduleDateTime(availableTimes[i].time);
    });
  }

  Future selectAClient(List<TimeTile> availableTimes, int i) async {
    client = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectClientForAppointment(
                  admin: widget.admin,
                )));
    print(client?.firstName ?? 'Null First Name');
    if (client != null) {
      availableTimes[i].appointment = Appointment(
          client?.firstAndLastFormatted,
          availableTimes[i].time,
          availableTimes[i].time.add(Duration(minutes: 45)),
          Colors.green,
          false,
          client,
          isConfirmed: false,
          isRescheduling: false,
          noReply: false,
          serviceCost: client.costPerCleaning,
          keyRequired: client.keyRequired,
          note: client.note,
          admin: widget.admin);
      setState(() {
        availableTimes[i]
          // ..orignalTime = availableTimes[i].time
          ..timeSlotTaken = true
          ..undoAvailable = true
          ..color = Colors.yellow;

        widget.unconfirmedAppointments[i] = availableTimes[i];
        // .add(availableTimes[i]);

        // widget.appointmentsToConfirm(appointmentsToConfirm);
      });
    }
  }

  void resetSlot(List<TimeTile> availableTimes, int i) {
    print('doubleTAPPED');
    setState(() {
      availableTimes[i].reset();
      widget.unconfirmedAppointments[i].reset();
      // widget.appointmentsToConfirm(appointmentsToConfirm);
    });
  }

  void recalculateNextAppointment(
      List<TimeTile> availableTimes, int i, bool isAdding, int inMinutes) {
    reSort = false;

    //Calculates the next time slot by adding service duration to the next time slot
    setState(() {
      // Check for null value and then check if slot is taken or not
      if (availableTimes[i].timeSlotTaken != null &&
          availableTimes[i].timeSlotTaken) {
        if (isLastItemInList(availableTimes, i)) return;

        TimeTile nextSlot = availableTimes[i + 1];
        Appointment nextSlotAppointment = nextSlot?.appointment;
        bool nextSlotIsConfirmed = nextSlotAppointment?.isConfirmed ?? false;
        if (nextSlotAppointment != null &&
            availableTimes[i + 1].timeSlotTaken) {
          nextSlotTaken(availableTimes, isAdding, inMinutes, i);
        } else {
          calculateNewTime(availableTimes, isAdding, inMinutes, i);
        }
        widget.unconfirmedAppointments[i] = availableTimes[i];
        // widget.appointmentsToConfirm(appointmentsToConfirm);
      }
    });
    // reSort = true;
  }

  Future<void> addCustomTimeSlot(List<TimeTile> availableTimes) async {
    DateTime dateTime = await selectTime();
    if (dateTime != null) {
      TimeTile lastTakenSlot = availableTimes[availableTimes.length - 1];
      setState(() {
        availableTimes.add(TimeTile.clone(
          lastTakenSlot,
          newTime: dateTime,
          timeSlotTaken: false,
          appointment: null,
          copyAppointment: false,
          color: Colors.white,
        ));
      });
      print('added');
    }
  }

  void addSlot(List<TimeTile> availableTimeSlots) {
    TimeTile lastTakenSlot = availableTimeSlots[availableTimeSlots.length - 1];
    setState(() {
      availableTimeSlots.add(TimeTile.clone(
        lastTakenSlot,
        newTime: lastTakenSlot.time.add(Duration(
            hours: widget.admin.scheduleSettings.timePerService.hour,
            minutes: widget.admin.scheduleSettings.timePerService.min)),
        timeSlotTaken: false,
        appointment: null,
        copyAppointment: false,
        color: Colors.white,
      ));
    });
    print('added');
  }

  void calculateNewTime(
      List<TimeTile> availableTimes, bool isAdding, int inMinutes, int i) {
    DateTime newTime;

    int leadTimeMin = widget.admin.scheduleSettings.leadTime.min;

    if (isAdding) {
      if (availableTimes.length - 1 < i + 1) {
        return;
      } else {
        newTime = availableTimes[i].time.add(Duration(minutes: inMinutes));
        availableTimes[i + 1] = TimeTile.clone(availableTimes[i + 1],
            newTime: newTime,
            appointment: availableTimes[i + 1].timeSlotTaken != null &&
                    availableTimes[i + 1].timeSlotTaken
                ? Appointment.clone(availableTimes[i + 1].appointment,
                    from: newTime,
                    to: newTime.add(Duration(minutes: leadTimeMin)))
                : null);
      }
    } else {
      if (availableTimes.length - 1 < i + 1) {
        return;
      } else {
        List<Service> services = availableTimes[i].appointment.services;

        if (noServicesSelected(services))
          return resetSlotToOriginal(availableTimes, i);
        newTime =
            availableTimes[i + 1].time.subtract(Duration(minutes: inMinutes));
        availableTimes[i + 1] = TimeTile.clone(availableTimes[i + 1],
            newTime: newTime,
            appointment: availableTimes[i + 1].timeSlotTaken != null &&
                    availableTimes[i + 1].timeSlotTaken
                ? Appointment.clone(availableTimes[i + 1].appointment,
                    from: newTime,
                    to: newTime.add(Duration(minutes: leadTimeMin)))
                : null);
      }
    }
  }

  bool noServicesSelected(List<Service> services) {
    int selectedServices = 0;
    services.forEach((service) {
      if (service.selected) {
        selectedServices++;
      }
    });

    return selectedServices > 0 ? false : true;
  }

  void resetSlotToOriginal(List<TimeTile> availableTimes, int i) {
    setState(() {
      if (availableTimes.length - 1 < i + 1) {
        return;
      }
      availableTimes[i + 1] = TimeTile.clone(availableTimes[i + 1],
          newTime: availableTimes[i + 1].orignalTime);
    });
  }

  void nextSlotTaken(List<TimeTile> availableTimes, bool isAdding,
      int inMinutes, int i) async {
    print(
        'Next Time slot will not be changed as it is already set and created');
    DateTime selectedSlotTime = availableTimes[i].time;
    DateTime selectedSlotNewTime;
    if (isAdding) {
      selectedSlotNewTime = selectedSlotTime.add(Duration(minutes: inMinutes));
    } else {
      selectedSlotNewTime =
          selectedSlotTime.subtract(Duration(minutes: inMinutes));
    }
    TimeTile slot =
        TimeTile.clone(availableTimes[i], newTime: selectedSlotNewTime);
    if (selectedSlotNewTime.isAfter(availableTimes[i + 1].time) ||
        selectedSlotNewTime.isAtSameMomentAs(availableTimes[i + 1].time)) {
      bool continueConflict = await isAfterWarning();
      if (continueConflict) {
      } else {}
    }
  }

  bool isLastItemInList(List list, int index) {
    if (list.length - 1 < index + 1) {
      return true;
    }
    return false;
  }

  Future<bool> isAfterWarning() async {
    bool continueConflict = false;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Warning!'),
              content: Container(
                // color: Colors.red,
                child: Text(
                    'You are trying to schedule an appointment that will finish at the same time or after an already scheduled appointment (There will be conflicts).'),
              ),
              actions: [
                ElevatedButtonX(
                  childX: Text('Understood!'),
                  onPressedX: () {
                    Navigator.pop(context);
                    continueConflict = true;
                  },
                  colorX: Colors.green,
                ),
              ],
            ));

    return continueConflict;
  }
}
