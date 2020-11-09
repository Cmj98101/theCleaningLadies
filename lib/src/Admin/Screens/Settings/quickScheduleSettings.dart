import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';

class QuickScheduleDefaultSettings extends StatelessWidget {
  final Admin admin;
  QuickScheduleDefaultSettings({@required this.admin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: QuickScheduleSettings(),
    );
  }
}

class QuickScheduleSettings extends StatefulWidget {
  @override
  _QuickScheduleSettingsState createState() => _QuickScheduleSettingsState();
}

class _QuickScheduleSettingsState extends State<QuickScheduleSettings> {
  DateTime timePerService = DateTime(2020, 3, 10, 2, 00);
  DateTime travelTime = DateTime(2020, 3, 10, 24, 15);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30, right: 10, left: 10),
      child: Column(
        children: [
          SettingsDescriptionTile(
            titleText: 'Time Taken per service',
            buttonText:
                '${timePerService?.hour ?? 0} ${(timePerService?.hour ?? 0) > 1 ? 'hrs.' : 'hr.'} ${timePerService?.minute ?? 15} min.',
            onPressed: () async {
              TimeOfDay selectedTime = await selectTime();

              setState(() {
                timePerService = DateTime(
                    2020, 3, 10, selectedTime.hour, selectedTime.minute);
              });
            },
          ),
          SettingsDescriptionTile(
            titleText: 'Travel Time between services',
            buttonText:
                '${DateFormat('h').format(travelTime)} ${(travelTime?.hour ?? 0) > 1 ? 'hrs.' : 'hr.'} ${travelTime?.minute ?? 15} min.',
            onPressed: () async {
              TimeOfDay selectedTime = await selectTime();

              setState(() {
                travelTime = DateTime(
                    2020, 3, 10, selectedTime.hour, selectedTime.minute);
              });
            },
          )
        ],
      ),
    );
  }

  Future<TimeOfDay> selectTime() async {
    return await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.dial,
        initialTime: TimeOfDay(hour: 23, minute: 00));
  }
}

class SettingsDescriptionTile extends StatelessWidget {
  final VoidCallback onPressed;
  final String titleText;
  final String buttonText;
  SettingsDescriptionTile(
      {@required this.onPressed,
      @required this.titleText,
      @required this.buttonText});
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: SizeConfig.safeBlockHorizontal * 60,
              child: Text(
                titleText,
                softWrap: true,
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 4,
                ),
              )),
          Container(
            width: SizeConfig.safeBlockHorizontal * 35,
            child: Card(
              elevation: 4,
              child: FlatButton(
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.safeBlockHorizontal * 4,
                  ),
                ),
                onPressed: onPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
