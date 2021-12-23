import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/appointment_bloc.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/appointment_event.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/schedule/schedule.dart';
import 'package:the_cleaning_ladies/models/service/service.dart';
import 'package:the_cleaning_ladies/models/time_tile/time_title.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/notification_model/push_notification.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/AppointmentRepo/appointmentRepo.dart';
import 'package:the_cleaning_ladies/src/admin/views/MyClients/messageInbox.dart';
import 'package:the_cleaning_ladies/src/admin/views/QuickSchedule/scheduleSummary.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/quickScheduleSettings.dart';
import 'package:the_cleaning_ladies/widgets/PresetWidget.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/src/admin/views/QuickSchedule/display_available_slots.dart';
import 'package:the_cleaning_ladies/widgets/textButtonX.dart';

class QuickScheduleScreen extends StatefulWidget {
  final Admin admin;
  QuickScheduleScreen(this.admin);
  @override
  _QuickScheduleScreenState createState() => _QuickScheduleScreenState();
}

enum QuickScheduleOptions { showSettings, showSummary, changeTime }

class _QuickScheduleScreenState extends State<QuickScheduleScreen> {
  DateTime selectedDate;
  bool dateSelected = false;
  bool startTimeSelected = false;
  DateTime timeToStart;
  PushNotifications _pushNotifications;
  AppointmentsRepository appointmentsRepository =
      FireBaseAppointmentsRepository();
  List<TimeTile> unconfirmedAppointments;
  List<TimeTile> listForSummary = [];

  @override
  void initState() {
    super.initState();

    _pushNotifications = PushNotifications(
        admin: widget.admin,
        context: context,
        isMounted: () => mounted,
        onNotification: (admin, client) async {
          return await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MessageInboxScreen(admin, client)));
        });
  }

  @override
  void dispose() {
    super.dispose();
    _pushNotifications.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int unconfirmedAppointmentSlots = 100;
    unconfirmedAppointments = List.filled(unconfirmedAppointmentSlots, null);
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Quick Schedule'),
        actions: SizeConfig.screenWidth < 600
            ? [
                PopupMenuButton(
                  itemBuilder: (context) => <Map>[
                    {
                      'title': 'Show Settings',
                      'action': QuickScheduleOptions.showSettings
                    },
                    {
                      'title': 'Show Summary',
                      'action': QuickScheduleOptions.showSummary
                    },
                    {
                      'title': 'change Time',
                      'action': QuickScheduleOptions.changeTime
                    }
                  ]
                      .map<PopupMenuEntry<String>>((value) => PopupMenuItem(
                            child: TextButtonX(
                              onPressedX: () {
                                switch (value['action']) {
                                  case QuickScheduleOptions.showSettings:
                                    return Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                QuickScheduleDefaultSettings(
                                                    admin: widget.admin)));
                                    break;
                                  case QuickScheduleOptions.showSummary:
                                    // Navigator.pop(context);
                                    return onshowSummary();
                                    break;
                                  case QuickScheduleOptions.changeTime:
                                    // return onshowSummary();
                                    setState(() {
                                      selectTime();
                                    });
                                    break;
                                  default:
                                }
                              },
                              childX: Container(child: Text(value['title'])),
                            ),
                          ))
                      .toList(),
                  // value: dropdownValue,
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                  // iconSize: 24,
                  // elevation: 16,
                  // style: TextStyle(color: Colors.deepPurple),
                  // underline: Container(
                  //   height: 2,
                  //   color: Colors.deepPurpleAccent,
                  // ),
                ),
              ]
            : [
                TextButtonX(
                    onPressedX: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuickScheduleDefaultSettings(
                                admin: widget.admin))),
                    childX: Icon(Icons.settings)),
                TextButtonX(
                    onPressedX: () => onshowSummary(),
                    childX: Icon(
                      Icons.view_list,
                      // size: SizeConfig.safeBlockHorizontal * 5.5,
                    )),
                TextButtonX(
                    onPressedX: () {
                      setState(() {
                        selectTime();
                      });
                    },
                    childX: Icon(
                      Icons.av_timer,
                    )),
              ],
      ),
      body: quickScheduleBody(),
    );
  }

  Widget quickScheduleBody() {
    return ListView(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 15, right: 15, top: 20),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: ITextHeading('Select Date & Time'),
              ),
              Container(
                height: SizeConfig.safeBlockVertical * 50,
                child: SfDateRangePicker(
                  enablePastDates: false,
                  onSelectionChanged: (arg) {
                    setState(() {
                      startTimeSelected = false;
                      selectedDate = arg.value;
                      dateSelected = true;
                      unconfirmedAppointments = [];
                      selectTime();
                    });
                  },
                  selectionMode: DateRangePickerSelectionMode.single,
                ),
              ),
              !dateSelected || timeToStart == null
                  ? Container()
                  : startTimeSelected
                      ? Container(
                          // color: Colors.red,
                          child: BuildAvailibilityView(
                            admin: widget.admin,
                            selectedDate: selectedDate,
                            timeToStart: timeToStart,
                            isQuickSchedule: true,
                            unconfirmedAppointments: unconfirmedAppointments,
                            onSummaryReady: (availableTimes) =>
                                listForSummary = availableTimes,
                            appointmentsToConfirm: (appointments) {
                              // setState(() {
                              // appointments
                              //     .removeWhere((timeTile) => timeTile == null);
                              // appointments.forEach((timeTile) {
                              //   if (timeTile != null) {
                              //     unconfirmedAppointments.add(timeTile);
                              //   }
                              // });
                              // // unconfirmedAppointments = appointments;
                              // });
                            },
                          ),
                        )
                      : Container(),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width * .9,
                margin: EdgeInsets.only(bottom: 50),
                child: ElevatedButton(
                  onPressed: () => confirmSchedule(),
                  child: Text('Add To Schedule'),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void selectTime() async {
    TimeOfDay time = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.input,
        initialTime: TimeOfDay(hour: 7, minute: 0));
    if (time != null) {
      print(time.format(context));
      setState(() {
        startTimeSelected = true;
        timeToStart = DateTime(2020, 3, 10, time.hour, time.minute);
      });
    } else {
      print(time);
      setState(() {
        timeToStart = null;
      });
    }
  }

  Future<void> onshowSummary() {
    if (selectedDate != null) {
      return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScheduleSummary(listForSummary, selectedDate, widget.admin),
          ));
    } else {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('No Date & Time Selected!'),
                content:
                    Text('Please Select a Date & Time to view day summary.'),
                actions: [
                  TextButtonX(
                    colorX: Colors.green,
                    onPressedX: () => Navigator.pop(context),
                    childX: Text('Okay', style: TextStyle(color: Colors.white)),
                  )
                ],
              ));
    }
  }

  void confirmSchedule() {
    if (unconfirmedAppointments.isNotEmpty) {
      setState(() {
        unconfirmedAppointments.forEach((timeTile) {
          // widget.admin.createAppointment(timeTile.appointment);
          if (timeTile?.appointment != null) {
            BlocProvider.of<AppointmentBloc>(context)
                .add(AddAppointmentEvent(timeTile.appointment, widget.admin));
          }
        });
      });
    } else {
      print('No Appointments to Schedule');
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  'No Appointments to Schedule!',
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'Please add appointments to schedule.',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Ok'),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green)),
                  )
                ],
              ));
    }
  }
}

class BuildAvailibilityView extends StatefulWidget {
  final Admin admin;
  final Client client;
  final DateTime selectedDate;
  final DateTime timeToStart;
  final Function(DateTime) rescheduleDateTime;
  final Function(List<TimeTile>) onSummaryReady;
  final Function(List<TimeTile>) appointmentsToConfirm;
  final bool isQuickSchedule;
  final bool isRescheduling;

  final List<TimeTile> unconfirmedAppointments;
  BuildAvailibilityView(
      {@required this.selectedDate,
      @required this.timeToStart,
      @required this.admin,
      this.unconfirmedAppointments,
      this.isRescheduling = false,
      this.rescheduleDateTime,
      this.onSummaryReady,
      this.client,
      this.appointmentsToConfirm,
      @required this.isQuickSchedule});

  @override
  _BuildAvailibilityViewState createState() => _BuildAvailibilityViewState();
}

class _BuildAvailibilityViewState extends State<BuildAvailibilityView> {
  AppointmentsRepository appointmentsRepository =
      FireBaseAppointmentsRepository();
  List<TimeTile> availableTimes;
  bool slotAdded = false;
  @override
  Widget build(BuildContext context) {
    Admin admin = widget.admin;
    Schedule schedule = admin.schedule;
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: ITextHeading(
              '@',
              fontSize: SizeConfig.safeBlockHorizontal * 6.5,
            ),
            alignment: Alignment.topLeft,
          ),
          Container(
              child: FutureBuilder(
            future: appointmentsRepository.getAppointments(widget.admin),
            builder: (context, AsyncSnapshot<List<Appointment>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                  break;
                case ConnectionState.done:
                  List<Appointment> reservedTimes = snapshot.data;
                  assert(reservedTimes != null);
                  reservedTimes
                      .removeWhere((appointment) => checkDateSame(appointment));
                  availableTimes = List.filled(
                      schedule.scheduleSettings.servicesPerGroup, null);
                  availableTimes = schedule.generateAvailabilities(
                      widget.selectedDate, widget.timeToStart, reservedTimes);

                  if (reservedTimes.length != 0) {
                    print('reserved Times != 0');
                    for (var reserved in reservedTimes) {
                      availableTimes.add(TimeTile(reserved.from, widget.admin,
                          appointment: reserved,
                          timeSlotTaken: true,
                          color: Colors.green,
                          orignalTime: reserved.from));
                    }
                  }
                  int reservedAppointments = 0;
                  int openSlots = 0;
                  for (var time in availableTimes) {
                    if (time.timeSlotTaken == true) {
                      reservedAppointments += 1;
                    }
                  }

                  if (widget.admin.scheduleSettings.servicesPerGroup <
                      availableTimes.length) {
                    int availableTimesNeeded =
                        widget.admin.scheduleSettings.servicesPerGroup -
                            reservedAppointments;

                    removeAllExtraSlots(availableTimes, reservedAppointments);

                    availableTimes.sort(
                        (date1, date2) => date1.time.compareTo(date2.time));
                    Map<String, dynamic> first =
                        firstAppointmentOfTheDay(availableTimes);
                    if (first['firstIndex'] != 0) {
                      availableTimes.removeRange(1, first['firstIndex']);
                    }

                    for (var time in availableTimes) {
                      if (time.timeSlotTaken == false) {
                        openSlots += 1;
                      }
                    }
                    availableTimesNeeded =
                        widget.admin.scheduleSettings.servicesPerGroup -
                            (reservedAppointments + openSlots);
                    for (var i = 0; i < availableTimesNeeded; i++) {
                      int addedSlots =
                          checkForAvailableSlotsInBetween(availableTimes);
                      if (addedSlots >= availableTimesNeeded) {
                        break;
                      } else if (addedSlots < availableTimesNeeded) {
                        i += addedSlots;
                        availableTimes.sort(
                            (date1, date2) => date1.time.compareTo(date2.time));
                      }

                      int lastOfTakenSlots = availableTimes.length - 1;
                      TimeTile lastTakenSlot = availableTimes[lastOfTakenSlots];
                      Appointment lastTakenSlotAppointment =
                          lastTakenSlot.appointment;
                      int addedMinutes = 0;

                      if (i == 0) {
                        // TimeTile newSlot = availableTimes[i];
                        if (lastTakenSlotAppointment != null) {
                          lastTakenSlot.appointment.services.forEach((service) {
                            if (service.selected) {
                              addedMinutes += service.duration.inMinutes;
                            }
                          });
                        }

                        if (addedMinutes == 0) {
                          if (widget.isRescheduling) {
                            lastTakenSlot =
                                availableTimes[lastOfTakenSlots - 1];
                          }
                          availableTimes.add(TimeTile.clone(lastTakenSlot,
                              newTime: lastTakenSlot.time.add(Duration(
                                  hours: widget.admin.scheduleSettings
                                          .timePerService.hour +
                                      widget.admin.scheduleSettings
                                          .timeBetweenService.hour,
                                  minutes: widget.admin.scheduleSettings
                                          .timePerService.min +
                                      widget.admin.scheduleSettings
                                          .timeBetweenService.min)),
                              copyAppointment: false,
                              color: Colors.white,
                              timeSlotTaken: false,
                              appointment: null));
                          continue;
                        }

                        availableTimes.add(TimeTile.clone(
                          lastTakenSlot,
                          newTime: lastTakenSlot.time.add(Duration(
                              hours: widget.admin.scheduleSettings
                                  .timeBetweenService.hour,
                              minutes: addedMinutes +
                                  widget.admin.scheduleSettings
                                      .timeBetweenService.min)),
                          orignalTimeSameAsNewTime: true,
                          copyAppointment: false,
                          timeSlotTaken: false,
                          color: Colors.white,
                          appointment: null,
                        ));
                      } else {
                        availableTimes.add(TimeTile.clone(
                          lastTakenSlot,
                          newTime: lastTakenSlot.time.add(Duration(
                              hours: widget
                                  .admin.scheduleSettings.timePerService.hour,
                              minutes: widget
                                  .admin.scheduleSettings.timePerService.min)),
                          orignalTimeSameAsNewTime: true,
                          copyAppointment: false,
                          color: Colors.white,
                          timeSlotTaken: false,
                          appointment: null,
                        ));
                      }
                    }
                  } else {
                    for (var i = 0; i < availableTimes.length; i++) {
                      TimeTile currentSlot = availableTimes[i];
                      Appointment currentSlotAppointment =
                          currentSlot?.appointment;
                      bool appointmentIsConfirmed =
                          currentSlot.appointment?.isConfirmed ?? false;
                      TimeTile nextSlot;
                      Appointment nextSlotAppointment;
                      bool nextSlotIsConfirmed;
                      assert(currentSlot != null);
                      assert(currentSlot.timeSlotTaken != null);

                      if (currentSlot.timeSlotTaken) {
                        int addedMinutes = 0;
                        if (currentSlotAppointment != null) {
                          currentSlot.appointment.services.forEach((service) {
                            if (service.selected) {
                              addedMinutes += service.duration.inMinutes;
                            }
                          });
                        }

                        if (addedMinutes == 0) {
                          continue;
                        }

                        if (!isLastItemInList(availableTimes, i)) {
                          // TODO: Not calculating travel time maybe implement in the future

                          nextSlot = availableTimes[i + 1];
                          nextSlotAppointment = nextSlot?.appointment;
                          nextSlotIsConfirmed =
                              nextSlotAppointment?.isConfirmed ?? false;

                          availableTimes[i + 1] = TimeTile.clone(
                            availableTimes[i + 1],
                            newTime: currentSlot.time
                                .add(Duration(minutes: addedMinutes)),
                          );

                          continue;
                        } else {
                          if (availableTimes[i].appointment != null) {
                            continue;
                          }
                          TimeTile lastTakenSlot = availableTimes[i - 1];

                          availableTimes[i] = TimeTile.clone(availableTimes[i],
                              newTime: lastTakenSlot.time.add(Duration(
                                  hours: widget.admin.scheduleSettings
                                      .timePerService.hour,
                                  minutes: widget.admin.scheduleSettings
                                      .timePerService.min)));
                          continue;
                        }
                      }
                    }
                  }

                  if (widget.isQuickSchedule) {
                    widget.onSummaryReady(availableTimes);
                  }

                  return DisplayAvailableTimesWidget(
                    widget.selectedDate,
                    availableTimes,
                    widget.isQuickSchedule,
                    client: widget.isQuickSchedule ? null : widget.client,
                    rescheduleDateTime: (DateTime from) {
                      widget.rescheduleDateTime(from);
                    },
                    isRescheduling: widget.isRescheduling,
                    unconfirmedAppointments: widget.unconfirmedAppointments,
                    // appointmentsToConfirm: (appointments) =>
                    //     widget.appointmentsToConfirm(appointments),
                    admin: widget.admin,
                  );
                  break;
                case ConnectionState.active:
                  break;
                case ConnectionState.none:
                  break;
                default:
                  return Container();
              }
              return Container();
            },
          )),
        ]);
  }

  bool isLastItemInList(List list, int index) {
    if (list.length - 1 < index + 1) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> firstAppointmentOfTheDay(
    List<TimeTile> availableTimes,
  ) {
    DateTime firstAppointment;
    int firstAppointmentIndex = 0;
    availableTimes.sort((date1, date2) => date1.time.compareTo(date2.time));
    for (int i = 0; i < availableTimes.length; i++) {
      if (availableTimes[i].timeSlotTaken) {
        print(availableTimes[i].fromTimeFormatted);
        firstAppointment = availableTimes[i].time;
        firstAppointmentIndex = i;
        break;
      }
    }
    return {'first': firstAppointment, 'firstIndex': firstAppointmentIndex};
  }

  void removeAllExtraSlots(
      List<TimeTile> availableTimes, int availableTimesNeeded) {
    List<TimeTile> timesBeforeFirstTimeSlot = [];
    DateTime firstAppointment =
        firstAppointmentOfTheDay(availableTimes)['first'];
    availableTimes.forEach((timeTile) {
      if (timeTile.time.isBefore(firstAppointment)) {
        timesBeforeFirstTimeSlot.add(TimeTile.clone(timeTile));
      }
    });

    availableTimes
        .sort((timeTile1, timeTile2) => timeTile1.timeSlotTaken ? 0 : 1);

    availableTimes.removeRange(availableTimesNeeded, availableTimes.length);
    timesBeforeFirstTimeSlot.forEach((timeTile) {
      availableTimes.add(timeTile);
    });
  }

  List<TimeTile> getAvailableSlots(
      List<TimeTile> availableTimes, int start, int listSize) {
    List<TimeTile> extraSlots = List.filled(listSize, null);
    extraSlots =
        availableTimes.getRange(start, availableTimes.length - 1).toList();
    availableTimes.removeRange(start, availableTimes.length - 1);
    availableTimes.sort((date1, date2) => date1.time.compareTo(date2.time));
    return extraSlots;
  }

  bool checkDateSame(Appointment appointment) {
    DateTime from = appointment.from;
    DateTime appointmentDate = DateTime(from.year, from.month, from.day);
    if (appointmentDate != widget.selectedDate) {
      return true;
    }
    return false;
  }

  int shortestService(TimeTile time) {
    int inMinutes = 0;
    List<Service> services = time.appointment.services;
    for (var i = 0; i < services.length; i++) {
      if (i == 0) {
        inMinutes = services[i].duration.inMinutes;
      }
      if (services[i].duration.inMinutes < inMinutes) {
        inMinutes = services[i].duration.inMinutes;
      }
    }
    print('Shortest Duration inMinutes: $inMinutes ');
    return inMinutes;
  }

  int checkForAvailableSlotsInBetween(List<TimeTile> timeSlots) {
    int servicesSelected = 0;
    int addedSlots = 0;
    int addedMinutes = 0;
    for (var i = 0; i < timeSlots.length; i++) {
      if (timeSlots[i].appointment != null) {
        timeSlots[i].appointment.services.forEach((service) {
          if (service.selected) {
            servicesSelected++;
            addedMinutes += service.duration.inMinutes;
          }
        });

        if (isLastItemInList(timeSlots, i)) break;
        DateTime currentSlotTime = timeSlots[i].time;
        DateTime nextSlotTime = timeSlots[i + 1].time;
        if (withAddedTimeIsAtSameMomentAs(
                currentSlotTime, nextSlotTime, addedMinutes) ||
            withDefaultTimeIsAtSameMomentAs(
              currentSlotTime,
              nextSlotTime,
            )) {
          continue;
        } else if (nextSlotTime
            .isAfter(currentSlotTime.add(Duration(minutes: addedMinutes)))) {
          Duration difference = nextSlotTime
              .difference(currentSlotTime.add(Duration(minutes: addedMinutes)));
          int shortestServiceDuration = shortestService(timeSlots[i]);
          if (difference.inMinutes >=
              shortestServiceDuration +
                  widget.admin.scheduleSettings.timeBetweenService.totalInMin) {
            timeSlots.add(TimeTile.clone(
              timeSlots[i],
              newTime: timeSlots[i].time.add(Duration(
                  hours: widget.admin.scheduleSettings.timeBetweenService.hour,
                  minutes: addedMinutes +
                      widget.admin.scheduleSettings.timeBetweenService.min)),
              orignalTimeSameAsNewTime: true,
              copyAppointment: false,
              timeSlotTaken: false,
              color: Colors.white,
              appointment: null,
            ));
            addedSlots++;
          } else {}
        }
      }
    }
    return addedSlots;
  }

  bool withAddedTimeIsAtSameMomentAs(
      DateTime currentSlotTime, DateTime nextSlotTime, int addedMinutes) {
    return nextSlotTime
        .isAtSameMomentAs(currentSlotTime.add(Duration(minutes: addedMinutes)));
  }

  bool withDefaultTimeIsAtSameMomentAs(
      DateTime currentSlotTime, DateTime nextSlotTime) {
    return nextSlotTime.isAtSameMomentAs(currentSlotTime.add(Duration(
        hours: widget.admin.scheduleSettings.timePerService.hour +
            widget.admin.scheduleSettings.timeBetweenService.hour,
        minutes: widget.admin.scheduleSettings.timePerService.min +
            widget.admin.scheduleSettings.timeBetweenService.min)));
  }
}
