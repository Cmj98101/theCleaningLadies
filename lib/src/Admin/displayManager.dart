import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';
import 'package:the_cleaning_ladies/src/admin/views/homeScreen.dart';
import 'package:the_cleaning_ladies/src/admin/views/MyClients/myClients.dart';
import 'package:the_cleaning_ladies/src/admin/views/quickSchedule.dart';
import 'package:the_cleaning_ladies/src/admin/views/settings.dart';
import 'package:the_cleaning_ladies/src/admin/views/summary.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/widgets/bottomNavigation/bottomMenu.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(
        menuItems,
        admin: widget.admin,
        onChange: (i) => onTabChange(i),
      ),
      body: screens[active].widget,
    );
  }
}
