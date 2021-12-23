import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client_event.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/src/Admin/views/MyClients/messageInbox.dart';
import 'package:the_cleaning_ladies/src/Admin/views/MyClients/moreClientInfo.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client_bloc.dart';
import 'package:the_cleaning_ladies/widgets/Alerts/custom_button_with_alert.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/widgets/raisedButtonX.dart';
import 'package:the_cleaning_ladies/widgets/textButtonX.dart';

class ClientTile extends StatelessWidget {
  final Client client;
  final Admin admin;
  ClientTile({@required this.admin, @required this.client});
  @override
  Widget build(BuildContext context) {
    var lastCleanedFormatted = 'N/A';
    var lastService = client?.lastService ?? 'N/A';
    if (lastService != 'N/A') {
      lastCleanedFormatted = DateFormat('MM/dd/yy').format(lastService);
    }
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MoreClientInfo(
                    client: client,
                    admin: admin,
                  ))),
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        // height: SizeConfig.safeBlockVertical * 22,
        child: Card(
          elevation: 6,
          // color: client.active
          //     ? Colors.green[300]
          //     : Colors.yellow[300],

          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    bottom: 0,
                    child: Container(
                      width: 15,
                      color: client.active
                          ? Colors.green[300]
                          : Colors.yellow[300],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 15, right: 15, bottom: 15, left: 25),
                    child: Flex(
                        direction: Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              child: Text(
                            client.firstAndLastFormatted,
                            style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal * 5,
                                fontWeight: FontWeight.w600),
                          )),
                          Container(
                              margin: EdgeInsets.only(top: 6),
                              child: Text(
                                'Frequency: ${client.readFrequencyFromDB}',
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 3.5,
                                    fontWeight: FontWeight.w400),
                              )),
                          Container(
                              margin: EdgeInsets.only(top: 6),
                              child: Text(
                                'Last Service: $lastCleanedFormatted',
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 3.5,
                                    fontWeight: FontWeight.w400),
                              )),
                          Padding(
                            padding: EdgeInsets.only(top: 6),
                          ),
                          // client.displayDayPreferences(
                          //     margin: EdgeInsets.only(left: 3, right: 3)),
                        ]),
                  ),
                ],
              ),
              Container(
                height: 50,
                width: SizeConfig.safeBlockHorizontal * 12,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      left: 0,
                      child: Container(
                        alignment: Alignment.center,
                        // margin: EdgeInsets.only(right: 20),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MessageInboxScreen(admin, client)));
                          },
                          child: Icon(
                            Icons.message,
                            size: SizeConfig.safeBlockHorizontal * 10,
                          ),
                        ),
                      ),
                    ),
                    client.notificationCount < 1
                        ? Container()
                        : Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  client.notificationCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              Flexible(
                  child: CustomButtonWithAlert(
                size: SizeConfig.safeBlockHorizontal * 10,
                title: 'Are you Sure?',
                content: 'Are you sure you want to delete ${client.fullName}',
                icon: Icons.delete,
                actions: [
                  TextButtonX(
                      onPressedX: () {
                        BlocProvider.of<ClientBloc>(context)
                            .add(DeleteClientEvent(client));
                        BlocProvider.of<ClientBloc>(context)
                            .add(LoadClientsEvent(admin: admin));
                        Navigator.pop(context);
                      },
                      childX: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      )),
                  ElevatedButtonX(
                    onPressedX: () => Navigator.pop(context),
                    colorX: Colors.green,
                    childX: Text(
                      'Don\'t Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
