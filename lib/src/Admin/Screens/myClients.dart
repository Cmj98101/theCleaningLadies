import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/src/Admin/EasyDB/EasyDb.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/addClient.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/messageInbox.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/moreClientInfo.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/ClientRepo/clientRepo.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client.state.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_bloc.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_event.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';

class MyClients extends StatefulWidget {
  final Admin admin;
  final EasyDB easyDB;
  MyClients({@required this.admin, @required this.easyDB});
  @override
  _MyClientsState createState() => _MyClientsState();
}

class _MyClientsState extends State<MyClients> {
  ClientBloc _clientBloc =
      ClientBloc(clientRepository: FirebaseClientsRepository());
  TextEditingController searchCustomerController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _clientBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocProvider<ClientBloc>(
      create: (context) =>
          ClientBloc(clientRepository: FirebaseClientsRepository())
            ..add(LoadClientsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Clients',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            // FlatButton(
            //   child: Icon(Icons.delete),
            //   onPressed: () {
            //     // widget.easyDB.deleteDemos();
            //   },
            // ),
            FlatButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<AddClient>(
                    builder: (_) => BlocProvider.value(
                          value: _clientBloc,
                          child: AddClient(
                            false,
                            admin: widget.admin,
                          ),
                        )));
              },
            )
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            showSearchBar(),
            Container(
              child: Flexible(
                child: BlocBuilder<ClientBloc, ClientState>(
                  builder: (BuildContext context, ClientState state) {
                    if (state is ClientLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ClientLoaded) {
                      List<Client> filtered;
                      if (searchCustomerController.text.isNotEmpty) {
                        filtered = state.clients
                            .where((customer) => customer.firstName
                                .contains(searchCustomerController.text))
                            .toList();
                      }
                      return searchCustomerController.text.isNotEmpty
                          ? showClients(
                              isFilteredList: true, filtered: filtered)
                          : showClients(state: state);
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showSearchBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0, right: 20.0, left: 20.0),
      child: Row(
        children: [
          Flexible(
              child: TextField(
            style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 5.5),
            controller: searchCustomerController,
            onChanged: (text) {
              setState(() {});
            },
            decoration:
                InputDecoration.collapsed(hintText: 'Search Customer Here'),
          )),
        ],
      ),
      // margin: EdgeInsets.only(bottom: 20),
    );
  }

  Widget showClients({
    bool isFilteredList = false,
    List<Client> filtered,
    ClientLoaded state,
  }) {
    return ListView.builder(
        itemCount: isFilteredList ? filtered.length : state.clients.length,
        itemBuilder: (BuildContext context, int index) {
          var client = isFilteredList ? filtered[index] : state.clients[index];

          var freq =
              widget.admin.readFrequencyFromDB('${client.cleaningFrequency}');
          var lastCleanedFormatted = 'N/A';
          var lastCleaning = client.lastCleaning ?? 'N/A';
          if (lastCleaning != 'N/A') {
            lastCleanedFormatted = DateFormat('MM/dd/yy').format(lastCleaning);
          }

          return InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MoreClientInfo(
                          client: client,
                          admin: widget.admin,
                        ))),
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              height: SizeConfig.safeBlockVertical * 22,
              child: Card(
                elevation: 6,
                // color: client.active
                //     ? Colors.green[300]
                //     : Colors.yellow[300],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          width: 15,
                          color: client.active
                              ? Colors.green[300]
                              : Colors.yellow[300],
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 15, right: 15, bottom: 15, left: 20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    child: Text(
                                  '${client.firstName}${(client.lastName.isEmpty ? '' : ', ${client.lastName[0]}.')}',
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.safeBlockHorizontal * 5,
                                      fontWeight: FontWeight.w600),
                                )),
                                Container(
                                    margin: EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Frequency: $freq',
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.safeBlockHorizontal *
                                                  3.5,
                                          fontWeight: FontWeight.w400),
                                    )),
                                Container(
                                    margin: EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Last Cleaning: $lastCleanedFormatted',
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.safeBlockHorizontal *
                                                  3.5,
                                          fontWeight: FontWeight.w400),
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(top: 6),
                                ),
                                Container(
                                  child: Card(
                                    child: Container(
                                      margin: EdgeInsets.all(3),
                                      child: Row(
                                        children: <Widget>[
                                          for (var day in client.dayPreferences)
                                            Container(
                                                margin: EdgeInsets.only(
                                                    left: 3, right: 3),
                                                child: Text(
                                                  day.name,
                                                  style: TextStyle(
                                                    color: day.favoribleScale ==
                                                            FavoribleScale
                                                                .isOkay
                                                        ? Colors.blue[400]
                                                        : day.favoribleScale ==
                                                                FavoribleScale
                                                                    .isPrefered
                                                            ? Colors.green[400]
                                                            : Colors.red[400],
                                                    fontSize: SizeConfig
                                                            .safeBlockHorizontal *
                                                        3,
                                                  ),
                                                ))
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MessageInboxScreen(
                                      widget.admin, client)));
                        },
                        child: Icon(
                          Icons.message,
                          size: SizeConfig.safeBlockHorizontal * 7,
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(right: 20),
                        child: DeleteButtonWithAlert(
                          client: client,
                        ))
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class DeleteButtonWithAlert extends StatelessWidget {
  final Client client;
  DeleteButtonWithAlert({@required this.client});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Are you sure?'),
          content: Text(
              'Are you sure you would like to delete ${client.firstName} from the you customers list?'),
          actions: [
            FlatButton(
                onPressed: () {
                  BlocProvider.of<ClientBloc>(context)
                      .add(DeleteClientEvent(client));
                  BlocProvider.of<ClientBloc>(context).add(LoadClientsEvent());
                  Navigator.pop(context);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                )),
            RaisedButton(
              onPressed: () => Navigator.pop(context),
              color: Colors.green,
              child: Text(
                'Don\'t Delete',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
      child: Icon(
        Icons.delete,
        size: SizeConfig.safeBlockHorizontal * 7,
      ),
    );
  }
}
