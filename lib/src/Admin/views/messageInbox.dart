import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/SMS/message.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/notification_model/push_notification.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/find_phone_number.dart';

class MessageInboxScreen extends StatefulWidget {
  final Admin admin;
  final Client client;

  MessageInboxScreen(this.admin, this.client);
  @override
  _MessageInboxScreenState createState() => _MessageInboxScreenState();
}

class _MessageInboxScreenState extends State<MessageInboxScreen> {
  TextEditingController composeMessageTextController = TextEditingController();
  PushNotifications _pushNotifications;

  @override
  void initState() {
    super.initState();
    widget.admin.updateAdminNotificationCount(
        checkNotifications: false,
        client: widget.client,
        onDone: () {
          _pushNotifications.removeBadge();
          _pushNotifications.addBadge(widget.admin.notificationCount);
        });

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
        title: Text('Inbox'),
        // actions: [
        //   FlatButton(
        //       onPressed: () {
        //         widget.admin.updateContactNumber();
        //       },
        //       child: Icon(Icons.add))
        // ],
      ),
      body: widget.admin.twilioNumber.isEmpty
          ? Center(
              child: Container(
                child: Container(
                  child: RaisedButton(
                    color: Colors.green[400],
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FindANumber(admin: widget.admin)));
                    },
                    child: Text('Look for a Number Now!'),
                  ),
                ),
              ),
            )
          : Container(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              child: Column(
                children: [
                  Flexible(
                    child: Container(
                      width: SizeConfig.screenWidth,
                      height: SizeConfig.safeBlockVertical * 90,
                      child: StreamBuilder(
                        stream: widget.admin.phoneHandler.getSMS(widget.client),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Message>> snap) {
                          switch (snap.connectionState) {
                            case ConnectionState.waiting:
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                              break;

                            default:
                              return snap.hasData
                                  ? Container(
                                      // width: SizeConfig.screenWidth,
                                      // height: SizeConfig.safeBlockVertical * 90,
                                      // height: 50,

                                      // color: Colors.red,
                                      child: ListView(
                                        reverse: true,
                                        children: snap.data.map((message) {
                                          return Column(
                                            crossAxisAlignment: message.from ==
                                                    widget.admin.twilioNumber
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: [
                                              message.media.isEmpty
                                                  ? Container(
                                                      width: SizeConfig
                                                              .safeBlockHorizontal *
                                                          60,
                                                      // height:
                                                      //     SizeConfig.safeBlockVertical *
                                                      //         90,
                                                      // padding: EdgeInsets.all(10),
                                                      margin: message.from ==
                                                              widget.admin
                                                                  .twilioNumber
                                                          ? EdgeInsets.only(
                                                              right: 15, top: 5)
                                                          : EdgeInsets.only(
                                                              left: 15, top: 5),
                                                      // width: MediaQuery.of(context)
                                                      //         .size
                                                      //         .width *
                                                      //     .85,
                                                      child: Card(
                                                        elevation: 2,
                                                        color: message.from ==
                                                                widget.admin
                                                                    .twilioNumber
                                                            ? Colors.blue[300]
                                                            : Colors.grey[200],
                                                        child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                                message.body)),
                                                      ),
                                                    )
                                                  : Container(
                                                      width: SizeConfig
                                                              .safeBlockHorizontal *
                                                          80,

                                                      // padding: EdgeInsets.all(10),
                                                      margin: message.from ==
                                                              widget.admin
                                                                  .twilioNumber
                                                          ? EdgeInsets.only(
                                                              right: 15, top: 5)
                                                          : EdgeInsets.only(
                                                              left: 15, top: 5),

                                                      child: Card(
                                                        elevation: 2,
                                                        color: message.from ==
                                                                widget.admin
                                                                    .twilioNumber
                                                            ? Colors.blue[300]
                                                            : Colors.grey[200],
                                                        child: Column(
                                                          // direction: Axis.vertical,
                                                          // mainAxisSize:
                                                          //     MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child: Image
                                                                    .network(message
                                                                        .media)),
                                                            Container(
                                                                // width: SizeConfig
                                                                //         .safeBlockHorizontal *
                                                                //     80,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child: Text(
                                                                    message
                                                                        .body)),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(),
                                    );
                              break;
                          }
                        },
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: .3,
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(bottom: 50.0, right: 30.0, left: 30.0),
                    child: Row(
                      children: [
                        Flexible(
                            child: TextField(
                          maxLines: 6,
                          controller: composeMessageTextController,
                          decoration: InputDecoration.collapsed(
                              hintText: 'Send message'),
                        )),
                        FlatButton(
                          child: Icon(Icons.send),
                          onPressed: () =>
                              handleSubmit(composeMessageTextController.text),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
    );
  }

  void handleSubmit(String message) {
    composeMessageTextController.text = "";
    print(message);
    widget.admin.phoneHandler.reply(
      message,
      widget.client.formatPhoneNumber,
      widget.client,
    );
  }
}
