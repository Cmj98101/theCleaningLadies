import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/moreClientInfo.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/Models/SMS/message.dart';
import 'package:the_cleaning_ladies/src/Models/historyEvent.dart';

class MessageInboxScreen extends StatefulWidget {
  final Admin admin;
  final Client client;

  MessageInboxScreen(this.admin, this.client);
  @override
  _MessageInboxScreenState createState() => _MessageInboxScreenState();
}

class _MessageInboxScreenState extends State<MessageInboxScreen> {
  TextEditingController composeMessageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
      body: Container(
          child: Column(
        children: [
          Flexible(
            child: Container(
              // height: MediaQuery.of(context).size.height * .90,
              child: StreamBuilder(
                stream: widget.admin.getSMS(widget.client),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Message>> snap) {
                  switch (snap.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                      break;

                    default:
                      return snap.hasData
                          ? Container(
                              // height: 50,
                              child: ListView(
                                reverse: true,
                                children: snap.data.map((message) {
                                  return Column(
                                    crossAxisAlignment:
                                        message.from == '+16503752428'
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        // padding: EdgeInsets.all(10),
                                        margin: message.from == '+16503752428'
                                            ? EdgeInsets.only(right: 15, top: 5)
                                            : EdgeInsets.only(left: 15, top: 5),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .75,
                                        child: Card(
                                          elevation: 2,
                                          color: message.from == '+16503752428'
                                              ? Colors.blue[300]
                                              : Colors.grey[200],
                                          child: Container(
                                              padding: EdgeInsets.all(10),
                                              child: Text(message.body)),
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
              // child: StreamBuilder(
              //   stream: widget.admin.getSMS(widget.client),
              //   builder:
              //       (BuildContext context, AsyncSnapshot<List<Message>> snap) {
              //     switch (snap.connectionState) {
              //       case ConnectionState.waiting:
              //         return Center(
              //           child: CircularProgressIndicator(),
              //         );
              //         break;
              //       default:
              //         return snap.hasData
              //             ? ListView(
              //                 children: snap.data
              //                     .map((message) => Column(
              //                           crossAxisAlignment:
              //                               message.from == '+16503752428'
              //                                   ? CrossAxisAlignment.end
              //                                   : CrossAxisAlignment.start,
              //                           children: [
              //                             Container(
              //                               // padding: EdgeInsets.all(10),
              //                               margin:
              //                                   message.from == '+16503752428'
              //                                       ? EdgeInsets.only(
              //                                           right: 15, top: 5)
              //                                       : EdgeInsets.only(
              //                                           left: 15, top: 5),
              //                               width: MediaQuery.of(context)
              //                                       .size
              //                                       .width *
              //                                   .75,
              //                               child: Card(
              //                                 elevation: 2,
              //                                 color:
              //                                     message.from == '+16503752428'
              //                                         ? Colors.blue[300]
              //                                         : Colors.grey[200],
              //                                 child: Container(
              //                                     padding: EdgeInsets.all(10),
              //                                     child: Text(message.body)),
              //                               ),
              //                             ),
              //                           ],
              //                         ))
              //                     .toList())
              //             : Center(
              //                 child: CircularProgressIndicator(),
              //               );
              //         break;
              //     }
              //   },
              // ),
            ),
          ),
          Divider(
            color: Colors.black,
            thickness: .3,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 20.0, right: 10.0, left: 10.0),
            child: Row(
              children: [
                Flexible(
                    child: TextField(
                  controller: composeMessageTextController,
                  decoration:
                      InputDecoration.collapsed(hintText: 'Send message'),
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
    widget.admin.reply(message, widget.client.formatPhoneNumber, widget.client);
  }
}

// return FutureBuilder(
//     future: messageList,
//     builder: (context, AsyncSnapshot<List<SMS>> snap) {
//       switch (snap.connectionState) {
//         case ConnectionState.none:
//           Center(
//             child: Text('No Messages for this Customer'),
//           );
//           break;
//         case ConnectionState.waiting:
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//           break;
//         case ConnectionState.done:
//           if (snap.data
//               .where((sms) =>
//                   sms.to == widget.client.formatPhoneNumber)
//               .toList()
//               .isEmpty) {
//             return Center(
//                 child: Text(
//                     'No Messages found for this Customer\n(${widget.client.formatPhoneNumber})'));
//           } else {
//             return Container(
//               child: ListView(
//                 reverse: true,
//                 children: snap.data
//                     .where((sms) =>
//                         sms.to ==
//                                 widget.client
//                                     .formatPhoneNumber &&
//                             sms.from == '+16503752428' ||
//                         sms.from ==
//                                 widget.client
//                                     .formatPhoneNumber &&
//                             sms.to == '+16503752428')
//                     .map((sms) => Column(
//                           crossAxisAlignment:
//                               sms.from == '+16503752428'
//                                   ? CrossAxisAlignment.end
//                                   : CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               // padding: EdgeInsets.all(10),
//                               margin:
//                                   sms.from == '+16503752428'
//                                       ? EdgeInsets.only(
//                                           right: 15, top: 5)
//                                       : EdgeInsets.only(
//                                           left: 15, top: 5),
//                               width: MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                   .75,
//                               child: Card(
//                                 elevation: 2,
//                                 color:
//                                     sms.from == '+16503752428'
//                                         ? Colors.blue[300]
//                                         : Colors.grey[200],
//                                 child: Container(
//                                     padding:
//                                         EdgeInsets.all(10),
//                                     child: Text(sms.body)),
//                               ),
//                             ),
//                           ],
//                         ))
//                     .toList(),
//               ),
//             );
//           }
//           break;

//         default:
//           return Container(
//               child: Center(
//             child: Text('No Messages for this Customer'),
//           ));
//       }
//       return Container();
//     });
