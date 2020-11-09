import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/Widgets/CalendarWidget/calendar.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';

class ReminderSettings extends StatelessWidget {
  final Admin admin;
  ReminderSettings({@required this.admin});
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(),
        body: EditReminderTemplate(
          admin: admin,
          client: Client.demo(),
        ));
  }
}

class EditReminderTemplate extends StatefulWidget {
  final Admin admin;
  final bool isClientSide;
  final Client client;
  EditReminderTemplate(
      {@required this.admin, this.isClientSide = false, this.client});
  @override
  _EditReminderTemplateState createState() => _EditReminderTemplateState();
}

class _EditReminderTemplateState extends State<EditReminderTemplate> {
  bool templateDone = false;
  bool updated = false;
  TextEditingController _reminderMsgTemplateController =
      TextEditingController();
  List<String> matches = [];
  List<dynamic> fillInValues = [];
  bool selectAttribute = false;
  String selectedAttribute = '';
  int matchIndex = 0;

  @override
  void initState() {
    super.initState();

    _reminderMsgTemplateController.text = widget.isClientSide
        ? widget.client.templateReminderMsg.isEmpty
            ? widget.admin.templateReminderMsg
            : widget.client.templateReminderMsg
        : widget.admin.templateReminderMsg;
    fillInValues = widget.isClientSide
        ? widget.client.templateReminderMsg.isNotEmpty
            ? widget.client.templateFillInValues
            : []
        : widget.admin.templateFillInValues;
    matches = widget.isClientSide
        ? widget.client.templateReminderMsg.isNotEmpty
            ? widget.admin.findMatches(_reminderMsgTemplateController.text)
            : []
        : widget.admin.findMatches(_reminderMsgTemplateController.text);

    templateDone = widget.isClientSide
        ? widget.client.templateReminderMsg.isNotEmpty
            ? true
            : false
        : widget.admin.templateReminderMsg.isNotEmpty
            ? true
            : false;
  }

  void addAttribute(int index) {
    fillInValues[index] = '';
  }

  bool listValuesNotEmpty() {
    int total = 0;
    fillInValues.forEach((val) {
      if (val.isEmpty) {
        total++;
      }
    });
    // print(total == 0);
    return total == 0;
  }

  @override
  Widget build(BuildContext context) {
    Client client = Client.demo();
    Appointment appointment = Appointment.demo();
    Map<String, Object> clientAttributes = client.toDocument();
    Map<String, Object> appointmentAttributes = appointment.toDocument();
    List<String> clientKeys = [];
    List<String> appointmentKeys = [];

    clientAttributes.forEach((key, value) => clientKeys.add(key));
    appointmentAttributes.forEach((key, value) => appointmentKeys.add(key));
    appointmentKeys.add('getMsgReadyFullDateTime');

    return Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: ListView(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text('Reminder Message Template',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.safeBlockHorizontal * 5.5)),
          ),
          Container(
              child: TextField(
            onChanged: (val) {
              setState(() {
                templateDone = false;
              });
            },
            controller: _reminderMsgTemplateController,
            style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
            maxLines: 10,
          )),
          widget.isClientSide
              ? widget.client.templateReminderMsg.isNotEmpty
                  ? Container()
                  : !templateDone
                      ? Container(
                          child: RaisedButton(
                              child: Text('Confirm Template'),
                              onPressed: () {
                                setState(() {
                                  selectAttribute = false;
                                  templateDone = true;
                                  updated = false;
                                  matches = widget.admin.findMatches(
                                      _reminderMsgTemplateController.text);
                                  fillInValues = List<String>.filled(
                                    matches.length,
                                    '',
                                  );
                                  // matches.forEach((element) { })
                                });
                              }),
                        )
                      : Container()
              : !templateDone
                  ? Container(
                      child: RaisedButton(
                          child: Text('Confirm Template'),
                          onPressed: () {
                            setState(() {
                              selectAttribute = false;
                              templateDone = true;
                              updated = false;
                              matches = widget.admin.findMatches(
                                  _reminderMsgTemplateController.text);
                              fillInValues = List<String>.filled(
                                matches.length,
                                '',
                              );
                              // matches.forEach((element) { })
                            });
                          }),
                    )
                  : Container(),
          widget.isClientSide
              ? !templateDone
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text('Matches Found',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.safeBlockHorizontal * 5.5)),
                    )
              : Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text('Matches Found',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig.safeBlockHorizontal * 5.5)),
                ),
          widget.isClientSide
              ? !templateDone
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          for (var i = 0; i < matches.length; i++)
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(child: Text(matches[i])),
                                  Container(child: Text('=')),
                                  Container(
                                      child: RaisedButton(
                                    child: Text(fillInValues[i],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                SizeConfig.safeBlockHorizontal *
                                                    4)),
                                    onPressed: () {
                                      setState(() {
                                        selectAttribute = true;
                                        matchIndex = i;
                                      });
                                    },
                                  )),
                                ],
                              ),
                            ),
                          selectAttribute
                              ? Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Text('Client Attributes',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              SizeConfig.safeBlockHorizontal *
                                                  4.5)),
                                )
                              : Container(),
                          selectAttribute
                              ? Container(
                                  padding: EdgeInsets.all(5),
                                  height: 60,
                                  // width: 200,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      for (var i = 0;
                                          i < clientKeys.length;
                                          i++)
                                        Container(
                                          width:
                                              SizeConfig.safeBlockHorizontal *
                                                  65,
                                          margin: EdgeInsets.all(3),
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        60.0)),
                                            onPressed: () {
                                              setState(() {
                                                selectAttribute = false;
                                                fillInValues[matchIndex] =
                                                    clientKeys[i];

                                                updated = listValuesNotEmpty()
                                                    ? false
                                                    : true;
                                              });
                                            },
                                            child: Text(clientKeys[i],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: SizeConfig
                                                            .safeBlockHorizontal *
                                                        3)),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              : Container(),
                          selectAttribute
                              ? Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text('Appointment Attributes',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              SizeConfig.safeBlockHorizontal *
                                                  4.5)),
                                )
                              : Container(),
                          selectAttribute
                              ? Container(
                                  padding: EdgeInsets.all(5),
                                  height: 60,
                                  // width: 200,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      for (var i = 0;
                                          i < appointmentKeys.length;
                                          i++)
                                        Container(
                                          width:
                                              SizeConfig.safeBlockHorizontal *
                                                  65,
                                          margin: EdgeInsets.all(3),
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        60.0)),
                                            onPressed: () {
                                              setState(() {
                                                selectAttribute = false;
                                                fillInValues[matchIndex] =
                                                    appointmentKeys[i];
                                                updated = listValuesNotEmpty()
                                                    ? false
                                                    : true;
                                              });
                                            },
                                            child: Text(appointmentKeys[i],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: SizeConfig
                                                            .safeBlockHorizontal *
                                                        3)),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    )
              : Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      for (var i = 0; i < matches.length; i++)
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(child: Text(matches[i])),
                              Container(child: Text('=')),
                              Container(
                                  child: RaisedButton(
                                child: Text(fillInValues[i],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            SizeConfig.safeBlockHorizontal *
                                                4)),
                                onPressed: () {
                                  setState(() {
                                    selectAttribute = true;
                                    matchIndex = i;
                                  });
                                },
                              )),
                            ],
                          ),
                        ),
                      selectAttribute
                          ? Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Text('Client Attributes',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: SizeConfig.safeBlockHorizontal *
                                          4.5)),
                            )
                          : Container(),
                      selectAttribute
                          ? Container(
                              padding: EdgeInsets.all(5),
                              height: 60,
                              // width: 200,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (var i = 0; i < clientKeys.length; i++)
                                    Container(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 65,
                                      margin: EdgeInsets.all(3),
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(60.0)),
                                        onPressed: () {
                                          setState(() {
                                            selectAttribute = false;
                                            fillInValues[matchIndex] =
                                                clientKeys[i];

                                            updated = listValuesNotEmpty()
                                                ? false
                                                : true;
                                          });
                                        },
                                        child: Text(clientKeys[i],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: SizeConfig
                                                        .safeBlockHorizontal *
                                                    3)),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : Container(),
                      selectAttribute
                          ? Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text('Appointment Attributes',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: SizeConfig.safeBlockHorizontal *
                                          4.5)),
                            )
                          : Container(),
                      selectAttribute
                          ? Container(
                              padding: EdgeInsets.all(5),
                              height: 60,
                              // width: 200,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (var i = 0;
                                      i < appointmentKeys.length;
                                      i++)
                                    Container(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 65,
                                      margin: EdgeInsets.all(3),
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(60.0)),
                                        onPressed: () {
                                          setState(() {
                                            selectAttribute = false;
                                            fillInValues[matchIndex] =
                                                appointmentKeys[i];
                                            updated = listValuesNotEmpty()
                                                ? false
                                                : true;
                                          });
                                        },
                                        child: Text(appointmentKeys[i],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: SizeConfig
                                                        .safeBlockHorizontal *
                                                    3)),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
          widget.isClientSide
              ? !templateDone || updated
                  ? Container()
                  : fillInValues.isEmpty
                      ? Container()
                      : listValuesNotEmpty()
                          ? Container(
                              margin: EdgeInsets.only(top: 20),
                              child: RaisedButton(
                                  child: Text('Update'),
                                  onPressed: () {
                                    String templateReminderMsg = widget
                                            .isClientSide
                                        ? widget.client.templateReminderMsg =
                                            _reminderMsgTemplateController.text
                                        : widget.admin.templateReminderMsg =
                                            _reminderMsgTemplateController.text;
                                    widget.admin.updateClient(widget.client, {
                                      'templateReminderMsg':
                                          templateReminderMsg,
                                      'templateFillInValues': fillInValues
                                    });
                                    setState(() {
                                      updated = true;
                                    });
                                  }),
                            )
                          : Container()
              : Container(),
          widget.isClientSide
              ? Container(
                  margin: EdgeInsets.only(bottom: 40, top: 20),
                  child: RaisedButton(
                      child: Text('Use Default Template'),
                      onPressed: () {
                        setState(() {
                          updated = true;
                          templateDone = false;
                          _reminderMsgTemplateController.text =
                              widget.admin.templateReminderMsg;
                          widget.client.templateReminderMsg = '';
                          widget.client.templateFillInValues = [];
                        });
                        // String templateReminderMsg =
                        //     _reminderMsgTemplateController.text;
                        fillInValues = widget.isClientSide
                            ? []
                            : widget.admin.templateFillInValues;
                        widget.admin.updateClient(widget.client, {
                          'templateReminderMsg': '',
                          'templateFillInValues': []
                        });
                      }),
                )
              : Container(
                  margin: EdgeInsets.only(bottom: 40, top: 20),
                  child: RaisedButton(
                      child: Text('Update Default Template'),
                      onPressed: () {
                        setState(() {
                          widget.admin.templateReminderMsg =
                              _reminderMsgTemplateController.text;
                          widget.admin.templateFillInValues = fillInValues;
                        });
                        String templateReminderMsg =
                            _reminderMsgTemplateController.text;
                        widget.admin.update({
                          'templateReminderMsg': templateReminderMsg,
                          'templateFillInValues': fillInValues
                        });
                      }),
                )
        ],
      ),
    );
  }
}
