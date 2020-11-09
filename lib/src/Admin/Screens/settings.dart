import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/Settings/quickScheduleSettings.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/Settings/reminderSettings.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/homeScreen.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';

class Settings extends StatelessWidget {
  final Admin admin;
  Settings({@required this.admin});
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        height: SizeConfig.safeBlockVertical * 30,
        margin: EdgeInsets.only(top: 80, left: 20, right: 20),
        child: Card(
          elevation: 5,
          child: Column(
            children: [
              CustomIconTile(
                title: 'Reminder Settings',
                icon: Icons.message_outlined,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ReminderSettings(admin: admin)));
                },
              ),
              CustomIconTile(
                title: 'Quick Schedule Settings',
                icon: Icons.schedule_outlined,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              QuickScheduleDefaultSettings(admin: admin)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
