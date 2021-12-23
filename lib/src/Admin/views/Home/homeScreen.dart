import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';
import 'package:the_cleaning_ladies/notification_model/push_notification.dart';
import 'package:the_cleaning_ladies/src/admin/views/Home/addAppointment.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/src/Auth/authHandler.dart';

import 'package:the_cleaning_ladies/BLoC/Clients/ClientRepo/clientRepo.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client_bloc.dart';
import 'package:the_cleaning_ladies/models/error_handlers/errorHandlers.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/src/admin/views/MyClients/messageInbox.dart';
import 'package:the_cleaning_ladies/widgets/CalendarWidget/calendar.dart';
import 'package:the_cleaning_ladies/widgets/list_tiles/list_tile_with_button.dart';

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
  PushNotifications _pushNotifications;
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Admin displayManager  Navigator");
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
    _clientBloc.close();
    _pushNotifications.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: navigatorKey,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF3B67BF),
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
                  margin: EdgeInsets.only(left: 31, top: 35, bottom: 10),
                  child: Text(
                    'Options',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color(0xFF3B67BF),
                        fontWeight: FontWeight.w600,
                        fontSize: SizeConfig.safeBlockHorizontal * 6),
                  ),
                ),
              ),
              Divider(
                thickness: 1,
              ),
              // CustomIconTile(
              //     onTap: () {
              //       widget.admin.phoneHandler.sendBroadcastMessageWithMedia(
              //           mediaUrl:
              //               'https://www.farmersalmanac.com/wp-content/uploads/2020/07/iStock_75590599_LARGE-scaled.jpg');
              //     },
              //     title: 'Broadcast SMS',
              //     icon: Icons.mobile_screen_share),
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
            ],
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
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
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: CalendarWidget(
        widget.admin,
        viewFutureAppointments: viewFutureAppointments,
        futureAppointments: futureAppointments,
        addNotifications: () {},
      ),
    );
  }
}
