import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';

class RemindersSetting extends StatefulWidget {
  final Admin admin;
  RemindersSetting({@required this.admin});
  @override
  _RemindersSettingState createState() => _RemindersSettingState();
}

class _RemindersSettingState extends State<RemindersSetting> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: SvgPicture.asset(
            'assets/backgroundSVG.svg',
            // color: Color(0xFFaed2f2),
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }
}
