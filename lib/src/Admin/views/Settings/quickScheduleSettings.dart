import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/elapsedTime.dart';
import 'package:the_cleaning_ladies/models/schedule/scheduleSettings.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';

class QuickScheduleDefaultSettings extends StatefulWidget {
  final Admin admin;
  QuickScheduleDefaultSettings({@required this.admin});

  @override
  _QuickScheduleDefaultSettingsState createState() =>
      _QuickScheduleDefaultSettingsState();
}

class _QuickScheduleDefaultSettingsState
    extends State<QuickScheduleDefaultSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: QuickScheduleSettings(
        admin: widget.admin,
      ),
    );
  }
}

class QuickScheduleSettings extends StatefulWidget {
  final Admin admin;

  QuickScheduleSettings({@required this.admin});
  @override
  _QuickScheduleSettingsState createState() => _QuickScheduleSettingsState();
}

class _QuickScheduleSettingsState extends State<QuickScheduleSettings> {
  DateTime timePerService = DateTime(2020, 3, 10, 2, 00);
  DateTime travelTime = DateTime(2020, 3, 10, 24, 15);
  ScheduleSettings _scheduleSettings;

  @override
  void initState() {
    super.initState();
    _scheduleSettings = ScheduleSettings(
        leadTime: widget.admin.scheduleSettings.leadTime,
        reminderNotificationTime:
            widget.admin.scheduleSettings.reminderNotificationTime,
        timePerService: widget.admin.scheduleSettings.timePerService,
        timeBetweenService: widget.admin.scheduleSettings.timePerService,
        servicesPerGroup: 4);
  }

  @override
  Widget build(BuildContext context) {
    Admin admin = widget.admin;
    ScheduleSettings ss = admin.scheduleSettings;

    return Container(
      margin: EdgeInsets.only(top: 30, right: 10, left: 10),
      child: Column(
        children: [
          SettingsDescriptionTile(
            titleText: 'Advanced Reminder Time',
            child: LapseTimeField(
              admin: widget.admin,
              onChange: (elapseTime) {
                _scheduleSettings.reminderNotificationTime = elapseTime;
              },
              scheduleSettings: ss,
              elapsedTime: ss.reminderNotificationTime,
            ),
          ),
          SettingsDescriptionTile(
            titleText: 'Service Lead Time',
            child: LapseTimeField(
              admin: widget.admin,
              onChange: (elapseTime) {
                _scheduleSettings.leadTime = elapseTime;
              },
              scheduleSettings: ss,
              elapsedTime: ss.leadTime,
            ),
          ),
          SettingsDescriptionTile(
            titleText: 'Time Taken per service',
            child: LapseTimeField(
              admin: widget.admin,
              onChange: (elapseTime) {
                _scheduleSettings.timePerService = elapseTime;
              },
              scheduleSettings: ss,
              elapsedTime: ss.timePerService,
            ),
          ),
          SettingsDescriptionTile(
            titleText: 'Travel Time between services',
            child: LapseTimeField(
              admin: widget.admin,
              onChange: (elapseTime) {
                _scheduleSettings.timeBetweenService = elapseTime;
              },
              scheduleSettings: ss,
              elapsedTime: ss.timeBetweenService,
            ),
          ),
          SettingsDescriptionTile(
            titleText: 'Services Per Group',
            child: AnimatedInputField(
              admin: widget.admin,
              scheduleSettings: ss,
            ),
          )
        ],
      ),
    );
  }
}

class AnimatedInputField extends StatefulWidget {
  final Admin admin;
  final ScheduleSettings scheduleSettings;
  AnimatedInputField({@required this.admin, @required this.scheduleSettings});
  @override
  _AnimatedInputFieldState createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> {
  TextEditingController _inputField = TextEditingController();
  int servicesPerGroup = 0;
  bool valueDifferent = false;
  void initState() {
    super.initState();
    _inputField.text = widget.scheduleSettings.servicesPerGroup.toString();
  }

  @override
  Widget build(BuildContext context) {
    Admin admin = widget.admin;
    ScheduleSettings scheduleSettings = admin.schedule.scheduleSettings;
    SizeConfig().init(context);
    return SizeConfig.screenWidth < 600
        ? Card(
            elevation: 5,
            child: AnimatedContainer(
                // color: Colors.red,
                duration: Duration(milliseconds: 1500),
                curve: Curves.elasticInOut,
                width: valueDifferent
                    ? SizeConfig.safeBlockHorizontal * 26
                    : SizeConfig.safeBlockHorizontal * 15,
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        child: TextField(
                          controller: _inputField,
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            onChange(val);
                          },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(counterText: ''),
                          maxLength: 2,
                        ),
                      ),
                    ),
                    valueDifferent
                        ? Flexible(
                            flex: 0,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              color: valueDifferent ? Colors.green : Colors.red,
                              child: Container(
                                width: SizeConfig.safeBlockHorizontal * 20,
                                child: IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: valueDifferent
                                      ? () {
                                          widget.scheduleSettings
                                                  .servicesPerGroup =
                                              servicesPerGroup;
                                          scheduleSettings.update(admin.id);
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          )
                        : Container()
                  ],
                )),
          )
        : Card(
            elevation: 5,
            child: AnimatedContainer(
                // color: Colors.red,
                duration: Duration(milliseconds: 1500),
                curve: Curves.elasticInOut,
                width: valueDifferent
                    ? SizeConfig.safeBlockHorizontal * 17
                    : SizeConfig.safeBlockHorizontal * 10,
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        child: TextField(
                          controller: _inputField,
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            onChange(val);
                          },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(counterText: ''),
                          maxLength: 2,
                        ),
                      ),
                    ),
                    valueDifferent
                        ? Flexible(
                            flex: 0,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              color: valueDifferent ? Colors.green : Colors.red,
                              child: Container(
                                // width: SizeConfig.safeBlockHorizontal * 5,
                                child: IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: valueDifferent
                                      ? () {
                                          widget.scheduleSettings
                                                  .servicesPerGroup =
                                              servicesPerGroup;
                                          scheduleSettings.update(admin.id);
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          )
                        : Container()
                  ],
                )),
          );
  }

  void onChange(
    String val,
  ) {
    if (val.isEmpty) {
      setState(() {
        valueDifferent = false;
      });

      return;
    }
    checkValue(val);
  }

  void checkValue(String val) {
    if (int.parse(val) != widget.scheduleSettings.servicesPerGroup) {
      servicesPerGroup = int.parse(val);
      setState(() {
        valueDifferent = true;
      });
    } else {
      setState(() {
        valueDifferent = false;
      });
    }
  }
}

class SettingsDescriptionTile extends StatelessWidget {
  final String titleText;
  final Widget child;
  SettingsDescriptionTile({@required this.titleText, @required this.child});
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
                width: SizeConfig.safeBlockHorizontal * 50,
                child: Text(
                  titleText,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 4,
                  ),
                )),
          ),
          child,
        ],
      ),
    );
  }
}

class LapseTimeField extends StatefulWidget {
  final Admin admin;
  final ElapsedTime elapsedTime;
  final Function(ElapsedTime) onChange;
  final ScheduleSettings scheduleSettings;
  LapseTimeField(
      {@required this.admin,
      @required this.elapsedTime,
      @required this.onChange,
      @required this.scheduleSettings});
  @override
  _LapseTimeFieldState createState() => _LapseTimeFieldState();
}

class _LapseTimeFieldState extends State<LapseTimeField> {
  TextEditingController _hrField = TextEditingController();
  TextEditingController _minField = TextEditingController();
  bool valueDifferent = false;
  ElapsedTime elapsedTime;
  @override
  void initState() {
    super.initState();
    _hrField.text = widget.elapsedTime.hour.toString();
    _minField.text = widget.elapsedTime.min.toString();
  }

  @override
  Widget build(BuildContext context) {
    Admin admin = widget.admin;
    ScheduleSettings scheduleSettings = admin.schedule.scheduleSettings;
    SizeConfig().init(context);
    return SizeConfig.screenWidth < 600
        ? Card(
            elevation: 5,
            child: AnimatedContainer(
                duration: Duration(milliseconds: 1500),
                curve: Curves.elasticInOut,
                width: valueDifferent
                    ? SizeConfig.safeBlockHorizontal * 50
                    : SizeConfig.safeBlockHorizontal * 35,
                margin: EdgeInsets.all(10),
                // color: Colors.grey,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      // flex: 0,
                      fit: FlexFit.tight,
                      child: Container(
                        child: Row(
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                child: TextField(
                                  controller: _hrField,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    onChange(val);
                                  },
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(counterText: ''),
                                  maxLength: 2,
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 0,
                              child: Container(
                                child: Text(
                                  'hrs.',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _minField,
                                  onChanged: (val) {
                                    onChange(val, isHourField: false);
                                  },
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(counterText: ''),
                                  maxLength: 2,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 0,
                              fit: FlexFit.tight,
                              child: Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Text(
                                  'min.',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    valueDifferent
                        ? Flexible(
                            flex: 0,
                            fit: FlexFit.loose,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              color: valueDifferent ? Colors.green : Colors.red,
                              child: IconButton(
                                icon: Icon(Icons.check),
                                onPressed: valueDifferent
                                    ? () {
                                        widget.elapsedTime.hour =
                                            elapsedTime.hour;
                                        widget.elapsedTime.min =
                                            elapsedTime.min;

                                        scheduleSettings.update(admin.id);
                                      }
                                    : null,
                              ),
                            ),
                          )
                        : Container()
                  ],
                )))
        : Card(
            elevation: 5,
            child: AnimatedContainer(
                duration: Duration(milliseconds: 1500),
                curve: Curves.elasticInOut,
                width: valueDifferent
                    ? SizeConfig.safeBlockHorizontal * 20
                    : SizeConfig.safeBlockHorizontal * 16,
                margin: EdgeInsets.all(10),
                // color: Colors.grey,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Container(
                        child: Row(
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                child: TextField(
                                  controller: _hrField,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    onChange(val);
                                  },
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(counterText: ''),
                                  maxLength: 2,
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 0,
                              child: Container(
                                child: Text(
                                  'hrs.',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _minField,
                                  onChanged: (val) {
                                    onChange(val, isHourField: false);
                                  },
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(counterText: ''),
                                  maxLength: 2,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 0,
                              fit: FlexFit.tight,
                              child: Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Text(
                                  'min.',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    valueDifferent
                        ? Flexible(
                            flex: 0,
                            fit: FlexFit.loose,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              color: valueDifferent ? Colors.green : Colors.red,
                              child: IconButton(
                                icon: Icon(Icons.check),
                                onPressed: valueDifferent
                                    ? () {
                                        widget.elapsedTime.hour =
                                            elapsedTime.hour;
                                        widget.elapsedTime.min =
                                            elapsedTime.min;

                                        scheduleSettings.update(admin.id);
                                      }
                                    : null,
                              ),
                            ),
                          )
                        : Container()
                  ],
                )));
  }

  void onChange(String val, {bool isHourField = true}) {
    if (val.isEmpty) {
      setState(() {
        valueDifferent = false;
      });

      return;
    }
    checkValue(val, isHourField: isHourField);
  }

  void checkValue(String val, {bool isHourField = true}) {
    int _maxTimeElapsed = isHourField ? 10 * 60 : 60;
    int hours = int.parse(_hrField.text);
    int mins = int.parse(_minField.text);

    int totalInMin = (hours * 60) + mins;
    if (totalInMin != widget.elapsedTime.totalInMin) {
      if (isHourField) {
        if (hours * 60 > _maxTimeElapsed) {
          print('Number is bigger than $_maxTimeElapsed hours');

          return;
        }
      } else {
        if (mins > _maxTimeElapsed) {
          print('Number is bigger than $_maxTimeElapsed mins');
          return;
        }
      }

      elapsedTime = ElapsedTime(hour: hours, min: mins);
      setState(() {
        valueDifferent = true;
      });
      widget.onChange(elapsedTime);
    } else {
      setState(() {
        valueDifferent = false;
      });
    }
  }
}
