import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/src/client/views/homeScreen.dart';
import 'package:the_cleaning_ladies/widgets/bottomNavigation/bottomMenu.dart';

class Screen {
  final String name;
  final Widget widget;
  Screen(this.name, this.widget);
}

class ClientDisplayManager extends StatefulWidget {
  final Admin admin;
  final Client client;
  final EasyDB easyDb;
  ClientDisplayManager(this.admin, this.client, this.easyDb);
  @override
  _ClientDisplayManagerState createState() => _ClientDisplayManagerState();
}

class _ClientDisplayManagerState extends State<ClientDisplayManager> {
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
        color: Colors.red,
        icon: Icons.schedule),
    MenuItem(
        index: 2,
        x: 0,
        name: 'Calendar',
        color: Colors.green,
        icon: Icons.calendar_today),
    MenuItem(
        index: 3,
        x: .5,
        name: 'Summary Center',
        color: Colors.blue,
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
    // print('12123$index');
    setState(() {
      active = index;
    });
  }

  @override
  void initState() {
    super.initState();
    print('CALLED IN HOME');
    screens = [
      Screen('View 0', Container()),
      Screen('View 1', Container()),
      Screen('Home', ClientHomeScreen()),
      Screen('Summary', Container()),
      Screen('Settings', Container()),
    ];
  }

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
