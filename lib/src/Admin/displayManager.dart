import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_cleaning_ladies/src/Admin/EasyDB/EasyDb.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/homeScreen.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/myClients.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/quickSchedule.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/settings.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/summary.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/appointment_bloc.dart';
import '../Widgets/bottomNavigation/bottomMenu.dart';

class Screen {
  final String name;
  final Widget widget;
  Screen(this.name, this.widget);
}

class AdminDisplayManager extends StatefulWidget {
  final Admin admin;
  final EasyDB easyDb;
  final VoidCallback onLoggedOff;
  AdminDisplayManager(this.admin, this.easyDb, {@required this.onLoggedOff});
  @override
  _AdminDisplayManagerState createState() => _AdminDisplayManagerState();
}

class _AdminDisplayManagerState extends State<AdminDisplayManager> {
  List<MenuItem> menuItems = [
    MenuItem(
        index: 0,
        x: -1.0,
        name: 'My Clients',
        color: Colors.orange,
        icon: Icons.contacts),
    MenuItem(
        index: 1,
        x: -.5,
        name: 'Quick Schedule',
        color: Colors.yellow,
        icon: Icons.schedule),
    MenuItem(
        index: 2,
        x: 0,
        name: 'Calendar',
        color: Colors.blue,
        icon: Icons.calendar_today),
    MenuItem(
        index: 3,
        x: .5,
        name: 'Summary Center',
        color: Colors.green,
        icon: Icons.pie_chart),
    MenuItem(
        index: 4,
        x: 1.0,
        name: 'Home',
        color: Colors.black,
        icon: Icons.settings),
  ];
  static List<Screen> screens;
  int active = 2;
  void onTabChange(dynamic index) {
    // print('$inxdex');
    setState(() {
      active = index;
    });
  }

  @override
  void initState() {
    super.initState();
    print('CALLED IN HOME');
    screens = [
      Screen(
          'View 0',
          MyClients(
            admin: widget.admin,
            easyDB: widget.easyDb,
          )),
      Screen('View 1', QuickScheduleScreen(widget.admin)),
      Screen(
          'Calendar View',
          AdminHomeScreen(
            admin: widget.admin,
            easyDB: widget.easyDb,
            onLoggedOff: widget.onLoggedOff,
          )),
      Screen(
          'Summary',
          SummaryScreen(
            admin: widget.admin,
          )),
      Screen(
          'Settings',
          Settings(
            admin: widget.admin,
          )),
    ];
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   BlocProvider.of<AppointmentBloc>(context)..close();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(
        menuItems,
        onChange: (i) => onTabChange(i),
      ),
      body: screens[active].widget,
    );
  }
}
