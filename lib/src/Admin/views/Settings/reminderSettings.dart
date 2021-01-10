import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';

enum AttributeType { client, appointment }

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
  bool isTemplateDone = false;
  bool isUpdated = false;
  TextEditingController _reminderMsgTemplateController =
      TextEditingController();
  List<String> matches = [];
  List<dynamic> templateFillInValues = [];
  bool isAttributeSelected = false;
  String selectedAttribute = '';
  int matchIndex = 0;

  double titleSize = 5.5;

  double contentSize = 3.5;
  double btnSize = 4.5;

  @override
  void initState() {
    super.initState();
    Client client = widget.client;
    Admin admin = widget.admin;
    bool isClientSide = widget.isClientSide;

    _reminderMsgTemplateController.text = isClientSide
        ? client.templateReminderMsg.isEmpty
            ? admin.templateReminderMsg
            : client.templateReminderMsg
        : admin.templateReminderMsg;
    templateFillInValues = isClientSide
        ? client.templateReminderMsg.isEmpty
            ? []
            : client.templateFillInValues
        : admin.templateFillInValues;

    matches = isClientSide
        ? client.templateReminderMsg.isEmpty
            ? []
            : admin.findMatches(_reminderMsgTemplateController.text)
        : admin.findMatches(_reminderMsgTemplateController.text);

    isTemplateDone = isClientSide
        ? widget.client.templateReminderMsg.isEmpty
            ? false
            : true
        : widget.admin.templateReminderMsg.isEmpty
            ? false
            : true;

    if (templateFillInValues.isEmpty) {
      setState(() {
        isTemplateDone = true;
      });
    }
  }

  void addAttribute(int index) {
    templateFillInValues[index] = '';
  }

  bool listValuesNotEmpty() {
    int total = 0;
    if (templateFillInValues.isNotEmpty) {
      templateFillInValues.forEach((val) {
        if (val.isEmpty) {
          total++;
        }
      });
    }
    return total == 0;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Client client = Client.demo();
    Appointment appointment = Appointment.demo();
    Map<String, Object> clientAttributes = client.toDocument();
    Map<String, Object> appointmentAttributes = appointment.toDocument();
    List<String> clientKeys = [];
    List<String> appointmentKeys = [];

    clientAttributes.forEach((key, value) => clientKeys.add(key));
    appointmentAttributes.forEach((key, value) => appointmentKeys.add(key));
    appointmentKeys.add('fullDateTime');

    return LayoutBuilder(builder: (context, constriant) {
      return Container(
        // color: Colors.red,
        margin: EdgeInsets.only(top: 10, left: 20, right: 20),
        child: ListView(
          children: [
            titleWidget(),
            templateEditorWidget(),
            confirmTemplateButton(),
            showMatchesWidget(
                appointmentKeys: appointmentKeys, clientKeys: clientKeys),
            widget.isClientSide
                ? !isTemplateDone || isUpdated
                    ? Container()
                    : templateFillInValues.isEmpty
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
                                              _reminderMsgTemplateController
                                                  .text
                                          : widget.admin.templateReminderMsg =
                                              _reminderMsgTemplateController
                                                  .text;
                                      widget.admin.updateClient(widget.client, {
                                        'templateReminderMsg':
                                            templateReminderMsg,
                                        'templateFillInValues':
                                            templateFillInValues
                                      });
                                      setState(() {
                                        isUpdated = true;
                                      });
                                    }),
                              )
                            : Container()
                : Container(),
            showUpdateButton(),
          ],
        ),
      );
    });
  }

  Widget titleWidget() {
    return Container(
      // color: Colors.red,
      margin: EdgeInsets.only(bottom: 20),
      alignment: Alignment.center,
      child: Text('Reminder Message Template',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.safeBlockHorizontal * titleSize)),
    );
  }

  Widget templateEditorWidget() {
    return Container(
        child: Card(
      color: Colors.grey[300],
      elevation: 6,
      child: TextField(
        decoration: InputDecoration(contentPadding: EdgeInsets.all(30)),
        onChanged: (val) {
          setState(() {
            isTemplateDone = false;
          });
        },
        controller: _reminderMsgTemplateController,
        style:
            TextStyle(fontSize: SizeConfig.safeBlockHorizontal * contentSize),
        maxLines: 10,
      ),
    ));
  }

  Widget confirmTemplateButton() {
    // if (widget.isClientSide) {
    //   if (widget.client.templateReminderMsg.isNotEmpty) {
    //     return Container();
    //   }
    //   return showConfirmTemplateButton();
    // } else {
    //   return showConfirmTemplateButton();
    // }
    return widget.isClientSide
        ? widget.client.templateReminderMsg.isNotEmpty
            ? Container()
            : showConfirmTemplateButton()
        : showConfirmTemplateButton();
  }

  void confirmTemplate() {
    setState(() {
      isAttributeSelected = false;
      isTemplateDone = true;
      isUpdated = false;
      matches = widget.admin.findMatches(_reminderMsgTemplateController.text);
      templateFillInValues = List<String>.filled(
        matches.length,
        '',
      );
      // matches.forEach((element) { })
    });
  }

  Widget showConfirmTemplateButton() {
    if (!isTemplateDone) {
      return Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: SizeConfig.safeBlockHorizontal * 60,
            child: RaisedButton(
                color: Colors.green[400],
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Confirm Template',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * btnSize,
                    ),
                  ),
                ),
                onPressed: () {
                  confirmTemplate();
                }),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget showMatchesFoundTitle() {
    return Container(
      child: Text('Matches Found',
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.safeBlockHorizontal * titleSize)),
    );
  }

  Widget matchesFoundTitle() {
    return widget.isClientSide
        ? !isTemplateDone
            ? Container()
            : templateFillInValues.isEmpty
                ? Container()
                : showMatchesFoundTitle()
        : showMatchesFoundTitle();
  }

  Widget showMatchesWidget(
      {@required List<String> clientKeys,
      @required List<String> appointmentKeys}) {
    return Container(
      // color: Colors.green,
      margin: EdgeInsets.only(top: 15),
      // height: SizeConfig.safeBlockVertical * 35,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          matchesFoundTitle(),
          widget.isClientSide
              ? !isTemplateDone
                  ? Container()
                  : templateFillInValues.isEmpty
                      ? Container()
                      : Container(
                          margin: EdgeInsets.only(top: 10),
                          child: showMatchesFound(
                              appointmentKeys: appointmentKeys,
                              clientKeys: clientKeys),
                        )
              : Container(
                  margin: EdgeInsets.only(top: 10),
                  child: showMatchesFound(
                      appointmentKeys: appointmentKeys, clientKeys: clientKeys),
                ),
        ],
      ),
    );
  }

  Widget showMatchesFound(
      {@required List<String> clientKeys,
      @required List<String> appointmentKeys}) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      for (var i = 0; i < matches.length; i++)
        Container(
          height: SizeConfig.safeBlockVertical * 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  // width: 70,
                  child: Text(matches[i],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              SizeConfig.safeBlockHorizontal * contentSize))),
              Container(
                  child: Text('=',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              SizeConfig.safeBlockHorizontal * contentSize))),
              Container(
                  // width: 100,
                  child: RaisedButton(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                      templateFillInValues[i] == ''
                          ? 'Select an Attribute'
                          : templateFillInValues[i],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig.safeBlockHorizontal * btnSize)),
                ),
                onPressed: () {
                  setState(() {
                    isAttributeSelected = true;
                    matchIndex = i;
                  });
                },
              )),
            ],
          ),
        ),
      showAttributes(AttributeType.client, clientKeys),
      showAttributes(AttributeType.appointment, appointmentKeys)
    ]);
  }

  Widget showAttributeTitle(String title) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.safeBlockHorizontal * 4.5)),
    );
  }

  Widget showAttributes(AttributeType attributeType, List<String> keys) {
    switch (attributeType) {
      case AttributeType.client:
        return Column(
          children: [
            isAttributeSelected
                ? showAttributeTitle('Client Attributes')
                : Container(),
            isAttributeSelected
                ? Container(
                    padding: EdgeInsets.all(5),
                    height: 60,
                    // width: 200,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: showAttributesList(keys)),
                  )
                : Container()
          ],
        );
        break;
      case AttributeType.appointment:
        return Column(
          children: [
            isAttributeSelected
                ? showAttributeTitle('Appointment Attributes')
                : Container(),
            isAttributeSelected
                ? Container(
                    padding: EdgeInsets.all(5),
                    height: 60,
                    // width: 200,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: showAttributesList(keys)),
                  )
                : Container()
          ],
        );
        break;
      default:
        return Container(
          child: Text('Error: No AttributeType Specified'),
        );
    }
  }

  List<Widget> showAttributesList(List<String> keys) {
    return keys
        .map((key) => Container(
              width: SizeConfig.safeBlockHorizontal * 65,
              margin: EdgeInsets.all(3),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60.0)),
                onPressed: () {
                  setState(() {
                    isAttributeSelected = false;
                    templateFillInValues[matchIndex] = key;
                    isUpdated = listValuesNotEmpty() ? false : true;
                  });
                },
                child: Text(key,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.safeBlockHorizontal * 3)),
              ),
            ))
        .toList();
  }

  Widget showUpdateButton() {
    return widget.isClientSide
        ? useDefaultTemplateButton()
        : updateDefaultTemplateButton();
  }

  Widget useDefaultTemplateButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 40, top: 20),
      child: RaisedButton(
          color: Colors.indigo,
          child: Text(
            'Use Default Template',
            style:
                TextStyle(fontSize: SizeConfig.safeBlockHorizontal * btnSize),
          ),
          onPressed: () {
            setState(() {
              isUpdated = true;
              isTemplateDone = false;
              _reminderMsgTemplateController.text =
                  widget.admin.templateReminderMsg;
              widget.client.templateReminderMsg = '';
              widget.client.templateFillInValues = [];
            });
            // String templateReminderMsg =
            //     _reminderMsgTemplateController.text;
            templateFillInValues =
                widget.isClientSide ? [] : widget.admin.templateFillInValues;
            widget.admin.updateClient(widget.client, {
              'templateReminderMsg': '',
              'templateFillInValues': [],
            });
          }),
    );
  }

  Widget updateDefaultTemplateButton() {
    return Container(
      height: SizeConfig.safeBlockVertical * 7,
      margin: EdgeInsets.only(bottom: 40, top: 20),
      child: RaisedButton(
          color: Colors.green[400],
          child: Text(
            'Update Default Template',
            style:
                TextStyle(fontSize: SizeConfig.safeBlockHorizontal * btnSize),
          ),
          onPressed: () {
            setState(() {
              widget.admin.templateReminderMsg =
                  _reminderMsgTemplateController.text;
              widget.admin.templateFillInValues = templateFillInValues;
            });
            String templateReminderMsg = _reminderMsgTemplateController.text;
            widget.admin.update({
              'templateReminderMsg': templateReminderMsg,
              'templateFillInValues': templateFillInValues
            });
          }),
    );
  }
}
