import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/src/Admin/views/addAppointment.dart';
import 'package:the_cleaning_ladies/src/Admin/views/messageInbox.dart';
import 'package:the_cleaning_ladies/src/Admin/views/moreClientInfo.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';

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
                      : RaisedButton(
                          child: Text('Confirm Appointment'),
                          onPressed: () async {
                            print('Confirming ${appointment.appointmentId}');
                            widget.appointment.update(appointment, {
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
                      : RaisedButton(
                          color: appointment.isReminderSent
                              ? Colors.yellow[700]
                              : Colors.green[300],
                          child: Text('Send Reminder'),
                          onPressed: () async {
                            if (widget.admin.twilioNumber.isEmpty) {
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
                                    RaisedButton(
                                        child: Text('Okay'),
                                        color: Colors.red,
                                        onPressed: () => Navigator.pop(context))
                                  ],
                                ),
                              );
                            }

                            if (appointment.isReminderSent) {
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
                                    RaisedButton(
                                        child: Text('Okay'),
                                        color: Colors.red,
                                        onPressed: () => Navigator.pop(context))
                                  ],
                                ),
                              );
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
                                        RaisedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Ok'),
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
                                        RaisedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Ok'),
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
                  RaisedButton(
                      child: Text('Set Last Service Date To Current Date'),
                      onPressed: () async {
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
                                        RaisedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Ok'),
                                          color: Colors.green,
                                        )
                                      ],
                                    )));
                      }),
                  RaisedButton(
                      child: Text('View Messages'),
                      onPressed: () async {
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
                  RaisedButton(
                      child: Text('Reschedule Appointment'),
                      onPressed: () async {
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
                  RaisedButton(
                      child: Text('Cancel Appointment'),
                      onPressed: () {
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
}
