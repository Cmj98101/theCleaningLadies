import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/notifications/notifications.dart';
import 'package:the_cleaning_ladies/src/Admin/views/Settings/quickScheduleSettings.dart';
import 'package:the_cleaning_ladies/src/Admin/views/Settings/reminderSettings.dart';
import 'package:the_cleaning_ladies/src/Admin/views/homeScreen.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/find_phone_number.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/my_numbers.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/my_services/my_services.dart';

class Settings extends StatefulWidget {
  final Admin admin;

  Settings({@required this.admin});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  PushNotifications _pushNotifications;

  @override
  void initState() {
    super.initState();
    _pushNotifications = PushNotifications(
        admin: widget.admin, context: context, isMounted: () => mounted);
  }

  @override
  void dispose() {
    super.dispose();
    _pushNotifications.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return LayoutBuilder(builder: (context, contraints) {
      print(contraints.maxHeight);
      return Scaffold(
          body: Container(
        // color: Colors.red,
        height: SizeConfig.safeBlockVertical * 60,
        margin: EdgeInsets.only(top: 80, left: 20, right: 20),
        child: Card(
          elevation: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomIconTile(
                title: 'My Services',
                icon: Icons.design_services,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyServices(
                                admin: widget.admin,
                              )));
                },
              ),
              CustomIconTile(
                title: 'Reminder Settings',
                icon: Icons.message_outlined,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ReminderSettings(admin: widget.admin)));
                },
              ),
              CustomIconTile(
                title: 'Quick Schedule Settings',
                icon: Icons.schedule_outlined,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuickScheduleDefaultSettings(
                              admin: widget.admin)));
                },
              ),
              // CustomIconTile(
              //   title: 'My Numbers',
              //   icon: Icons.book,
              //   onTap: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) =>
              //                 MyNumbers(admin: widget.admin)));
              //   },
              // ),
              CustomIconTile(
                title: 'My Number',
                icon: Icons.book,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyNumbers(
                                admin: widget.admin,
                              )));
                },
              ),
              CustomIconTile(
                title: 'Find A Number',
                icon: Icons.phone,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FindANumber(admin: widget.admin)));
                },
              ),
            ],
          ),
        ),
      ));
    });
  }
}
