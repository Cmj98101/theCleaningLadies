import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/src/Admin/views/Home/addAppointment.dart';
import 'package:the_cleaning_ladies/src/Admin/views/MyClients/messageInbox.dart';
import 'package:the_cleaning_ladies/src/Admin/views/MyClients/moreClientInfo.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/widgets/raisedButtonX.dart';

class AppointmentOnTapDetailsScreen extends StatefulWidget {
  final Appointment appointment;
  final Function(Appointment) cancelAppointment;
  final Function(Appointment) updateAppointment;
  final Admin admin;

  AppointmentOnTapDetailsScreen(this.appointment, this.admin,
      this.cancelAppointment, this.updateAppointment);
  @override
  _AppointmentOnTapDetailsScreenState createState() =>
      _AppointmentOnTapDetailsScreenState();
}

class _AppointmentOnTapDetailsScreenState
    extends State<AppointmentOnTapDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    Appointment appointment = widget.appointment;
    return Scaffold(
      appBar: AppBar(
        title: Text(appointment.eventName),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () async {
              Client client =
                  await widget.admin.getClient(appointment.clientReference);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MoreClientInfo(admin: widget.admin, client: client)));
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  appointment?.isConfirmed ?? false
                      ? Container()
                      : ElevatedButtonX(
                          childX: Text('Confirm Appointment'),
                          onPressedX: () async {
                            print('Confirming ${appointment.appointmentId}');
                            appointment.update(appointment, {
                              "isConfirmed": true,
                              "isRescheduling": false,
                              "noReply": false
                            }, {
                              "isConfirmed": true,
                            });
                            Navigator.pop(context);
                          }),
                  appointment.isRescheduling || appointment.isConfirmed
                      ? Container()
                      : ElevatedButtonX(
                          colorX: appointment.isReminderSent
                              ? Colors.yellow[700]
                              : Colors.green[300],
                          childX: Text(
                            'Send Reminder',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressedX: () async {
                            if (widget.admin.twilioNumber.isEmpty) {
                              return noTwilioNumberFound();
                            }

                            if (appointment.isReminderSent) {
                              return reminderSentAlready();
                            }
                            if (appointment.isReminderSent == false) {
                              print(
                                  'Sending Reminders to : ${appointment.appointmentId}');

                              widget.admin.phoneHandler
                                  .sendAutoReminder(appointment, (res) {
                                if (res == true) {
                                  setState(() {
                                    appointment.isReminderSent = true;
                                  });
                                  return showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'Reminder Successfully Sent for ${appointment.eventName}',
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: [
                                        ElevatedButtonX(
                                          onPressedX: () =>
                                              Navigator.pop(context),
                                          childX: Text('Ok'),
                                        )
                                      ],
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    appointment.isReminderSent = false;
                                  });
                                  return showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'Reminder Could Not Be Sent For ${appointment.eventName}',
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: [
                                        ElevatedButtonX(
                                          onPressedX: () =>
                                              Navigator.pop(context),
                                          childX: Text('Ok'),
                                        )
                                      ],
                                    ),
                                  );
                                }
                              });
                            }
                          }),
                  appointment?.isConfirmed ?? false
                      ? Container()
                      : Padding(padding: EdgeInsets.only(bottom: 30)),
                  // appointment.client.lastCleaningDateOnly
                  //         .isAtSameMomentAs(appointment.fromDateOnly)
                  //     ? Container()
                  ElevatedButtonX(
                      childX: Text('Set Last Service Date To Current Date'),
                      onPressedX: () async {
                        widget.appointment.client.setLastService(
                            appointment.from,
                            () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text(
                                        'Updated Last Service\nTo',
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Text(
                                        '${appointment.fromDateFormatted}',
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: [
                                        ElevatedButtonX(
                                          onPressedX: () =>
                                              Navigator.pop(context),
                                          childX: Text('Ok'),
                                          colorX: Colors.green,
                                        )
                                      ],
                                    )));
                      }),
                  ElevatedButtonX(
                      childX: Text('View Messages'),
                      onPressedX: () async {
                        Client client = await widget.admin
                            .getClient('Users/${appointment.client.id}');
                        print(
                            'Viewing Messages for... ${appointment.client.id}');
                        Appointment updatedAppointment = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MessageInboxScreen(widget.admin, client)));
                        if (updatedAppointment != null) {
                          widget.updateAppointment(updatedAppointment);
                        }
                        // Navigator.pop(context);
                      }),
                  ElevatedButtonX(
                      childX: Text('Reschedule Appointment'),
                      onPressedX: () async {
                        print('Rescheduling... ${appointment.appointmentId}');
                        Appointment updatedAppointment = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddAppointmentScreen(
                                      true,
                                      admin: widget.admin,
                                      appointment: appointment,
                                    )));
                        if (updatedAppointment != null) {
                          widget.updateAppointment(updatedAppointment);
                        }
                        // Navigator.pop(context);
                      }),
                  // RaisedButton(
                  // child: Text('print Appointment'),
                  // onPressed: () {
                  //   print('Printing... ${appointment}');

                  // }),
                  ElevatedButtonX(
                      childX: Text('Cancel Appointment'),
                      onPressedX: () {
                        print('Cancelling... ${appointment.appointmentId}');
                        widget.cancelAppointment(appointment);
                        Navigator.pop(context);
                      }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Widget> noTwilioNumberFound() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Buy a Phone Number',
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Cannot Send a Reminder withought a Phone Number',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButtonX(
              childX: Text('Okay'),
              colorX: Colors.red,
              onPressedX: () => Navigator.pop(context))
        ],
      ),
    );
  }

  Future<Widget> reminderSentAlready() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reminder Sent Already!',
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Reminder has already been sent and is pending a reply.',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButtonX(
              childX: Text('Okay'),
              colorX: Colors.red,
              onPressedX: () => Navigator.pop(context))
        ],
      ),
    );
  }
}
