import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_cleaning_ladies/src/Admin/EasyDB/EasyDb.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/addAppointment.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/Auth/authHandler.dart';

import 'package:the_cleaning_ladies/src/BLoC/Clients/ClientRepo/clientRepo.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_bloc.dart';
import 'package:the_cleaning_ladies/src/ErrorHandlers/errorHandlers.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';
import '../../Widgets/CalendarWidget/calendar.dart';

class AdminHomeScreen extends StatefulWidget {
  final Admin admin;
  final EasyDB easyDB;
  final VoidCallback onLoggedOff;
  AdminHomeScreen(
      {@required this.admin,
      @required this.easyDB,
      @required this.onLoggedOff});
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  ClientBloc _clientBloc =
      ClientBloc(clientRepository: FirebaseClientsRepository());
  bool viewFutureAppointments = false;
  List<Appointment> futureAppointments;

  @override
  void dispose() {
    super.dispose();
    _clientBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute<AddAppointmentScreen>(
              builder: (_) => BlocProvider.value(
                    value: _clientBloc,
                    child: AddAppointmentScreen(
                      false,
                      admin: widget.admin,
                    ),
                  )));
        },
        child: Icon(Icons.add),
      ),
      drawer: Drawer(
        elevation: 0,
        child: Container(
          margin: EdgeInsets.only(
            top: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(left: 15),
                  child: Text(
                    'Options',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: SizeConfig.safeBlockHorizontal * 6),
                  ),
                ),
              ),
              Divider(
                thickness: 1,
              ),
              CustomIconTile(
                onTap: () {
                  print('sending Reminder');

                  return showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('Send Reminder Text?'),
                            content: Text(
                                'Are you sure you would like to send a reminder text to all unconfirmed appointments?'),
                            actions: [
                              FlatButton(
                                color: Colors.red,
                                onPressed: () => Navigator.pop(context),
                                child: Text('Dont Send!',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              FlatButton(
                                color: Colors.green,
                                onPressed: () {
                                  // widget.admin.sendCleaningReminder();

                                  print('Uncomment send Reminder');
                                },
                                child: Text('Send Messsage',
                                    style: TextStyle(color: Colors.white)),
                              )
                            ],
                          ));
                },
                title: 'Send Reminders',
                icon: Icons.mobile_screen_share,
              ),
              CustomIconTile(
                onTap: () {
                  // widget.admin.createSchedule();
                },
                title: 'Create Schedule',
                icon: Icons.schedule,
              ),
              CustomIconTile(
                onTap: () => HandleAuth.logOut(context,
                    onLoggedOff: widget.onLoggedOff, isLoading: (isLoading) {
                  setState(() {
                    isLoading
                        ? UserFriendlyMessages.loading(context)
                        : Navigator.pop(context);
                  });
                }),
                title: 'Sign Out',
                icon: Icons.logout,
              ),
              // CustomIconTile(
              //   onTap: () async {
              //     futureAppointments =
              //         await widget.admin.getFutureAppointments();

              //     setState(() {
              //       viewFutureAppointments = !viewFutureAppointments;
              //     });
              //     Navigator.pop(context);
              //   },
              //   title: 'View Upcomming Appointments',
              //   icon: Icons.remove_red_eye,
              // ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        // title: Text('My Appointments',
        //     style: TextStyle(
        //       color: Colors.black,
        //       fontSize: SizeConfig.safeBlockHorizontal * 5.2,
        //     )),
        actions: [
          FlatButton(
              onPressed: () async {
                futureAppointments = await widget.admin.getFutureAppointments();

                setState(() {
                  viewFutureAppointments = !viewFutureAppointments;
                });
              },
              child: Icon(
                Icons.remove_red_eye,
                color: Colors.black,
              )),
          // FlatButton(
          //     onPressed: () {
          //       widget.admin.addHistoryToEachCustomer();
          //     },
          //     child: Icon(
          //       Icons.add,
          //       color: Colors.black,
          //     ))
        ],
        //   // FlatButton(
        //   //     onPressed: () {
        //   //       widget.easyDB.deleteAppointmentDemos();
        //   //     },
        //   //     child: Icon(
        //   //       Icons.delete,
        //   //       color: Colors.black,
        //   //     ))
        // ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: CalendarWidget(
        widget.admin,
        viewFutureAppointments: viewFutureAppointments,
        futureAppointments: futureAppointments,
      ),
    );
  }
}

class CustomIconTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  CustomIconTile({@required this.title, this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraints) {
        SizeConfig().init(context);

        print(
            'MaxWidth ${contraints.maxWidth} x MaxHeight ${contraints.maxHeight}');
        return Container(
          width: contraints.maxWidth * .95,
          // color: Colors.green,
          margin: EdgeInsets.only(left: 15, bottom: 5, right: 15),
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Icon(icon),
                Container(
                  margin:
                      EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
                  child: Text(
                    title,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 4.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
