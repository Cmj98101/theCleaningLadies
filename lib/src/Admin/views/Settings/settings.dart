import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_cleaning_ladies/notification_model/push_notification.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/quickScheduleSettings.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/reminderSettings2.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/find_phone_number.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/my_numbers.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/my_services/my_services.dart';
import 'package:the_cleaning_ladies/widgets/list_tiles/list_tile_with_button.dart';

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

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'SETTINGS',
          ),
        ),
        body: Container(
          child: Column(
            children: [
              userImage(),
              userInfo(),
              Flexible(child: settingsList())
            ],
          ),
        ));
    //     body: Container(
    //   // color: Colors.red,
    //   height: SizeConfig.safeBlockVertical * 60,
    //   margin: EdgeInsets.only(top: 80, left: 20, right: 20),
    //   child: Card(
    //     elevation: 5,
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: [
    //         CustomIconTile(
    //           title: 'My Services',
    //           icon: Icons.design_services,
    //           onTap: () {
    //             Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                     builder: (context) => MyServices(
    //                           admin: widget.admin,
    //                         )));
    //           },
    //         ),
    //         CustomIconTile(
    //           title: 'Reminder Settings',
    //           icon: Icons.message_outlined,
    //           onTap: () {
    //             Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                     builder: (context) =>
    //                         ReminderSettings(admin: widget.admin)));
    //           },
    //         ),
    //         CustomIconTile(
    //           title: 'Quick Schedule Settings',
    //           icon: Icons.schedule_outlined,
    //           onTap: () {
    //             Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                     builder: (context) => QuickScheduleDefaultSettings(
    //                         admin: widget.admin)));
    //           },
    //         ),
    //         // CustomIconTile(
    //         //   title: 'My Numbers',
    //         //   icon: Icons.book,
    //         //   onTap: () {
    //         //     Navigator.push(
    //         //         context,
    //         //         MaterialPageRoute(
    //         //             builder: (context) =>
    //         //                 MyNumbers(admin: widget.admin)));
    //         //   },
    //         // ),
    //         CustomIconTile(
    //           title: 'My Number',
    //           icon: Icons.book,
    //           onTap: () {
    //             Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                     builder: (context) => MyNumbers(
    //                           admin: widget.admin,
    //                         )));
    //           },
    //         ),
    //         CustomIconTile(
    //           title: 'Find A Number',
    //           icon: Icons.phone,
    //           onTap: () {
    //             Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                     builder: (context) =>
    //                         FindANumber(admin: widget.admin)));
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    // ));
  }

  Widget userImage() {
    return Container(
      height: SizeConfig.safeBlockVertical * 20,
      width: SizeConfig.safeBlockHorizontal * 100,
      color: Color(0xFF3B67BF),
      child: Container(
        child: SvgPicture.asset(
          'assets/userSVG.svg',
          color: Color(0xFFaed2f2),
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }

  Widget userInfo() {
    return Container(
        height: SizeConfig.safeBlockVertical * 15,
        width: SizeConfig.safeBlockHorizontal * 100,
        color: Color(0xFFF28921),
        child: Container(
          margin: EdgeInsets.all(35),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  '${widget.admin.firstName} ${widget.admin.lastName}\n${widget.admin.city}, ${widget.admin.state}',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(10),
                      shadowColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFFFF8000))),
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 30, right: 30),
                    child: Text('Edit',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        )),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget settingsList() {
    return Container(
      padding: EdgeInsets.all(40),
      width: SizeConfig.safeBlockHorizontal * 100,
      // color: Colors.green,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          listItem(Icons.notifications, 'Reminder Settings',
              ReminderSettings(admin: widget.admin)),
          listItem(
              Icons.storage,
              'My Services',
              MyServices(
                admin: widget.admin,
              )),
          listItem(Icons.lock, 'Quick Schedule Settings',
              QuickScheduleDefaultSettings(admin: widget.admin)),
          listItem(Icons.phone, 'My Number', MyNumbers(admin: widget.admin)),
          listItem(
              Icons.search, 'Find A Number', FindANumber(admin: widget.admin))
        ],
      ),
    );
  }

  Widget listItem(IconData iconData, String title, Widget send) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => send));
      },
      child: Container(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        child: Row(
          children: [
            Container(
              child: Icon(
                iconData,
                size: 28,
                color: Color(0xFF3B67BF),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 37),
              child: Text(
                title,
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
