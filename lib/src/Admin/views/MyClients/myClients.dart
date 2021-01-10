import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client_event.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/notifications/notifications.dart';
import 'package:the_cleaning_ladies/src/Admin/views/MyClients/clientTile.dart';
import 'package:the_cleaning_ladies/src/Admin/views/addClient.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/ClientRepo/clientRepo.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client.state.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client_bloc.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/src/admin/views/messageInbox.dart';

class MyClients extends StatefulWidget {
  final Admin admin;
  final EasyDB easyDB;
  MyClients({@required this.admin, @required this.easyDB});
  @override
  _MyClientsState createState() => _MyClientsState();
}

class _MyClientsState extends State<MyClients> {
  PushNotifications _pushNotifications;
  ClientBloc _clientBloc =
      ClientBloc(clientRepository: FirebaseClientsRepository());
  TextEditingController searchCustomerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pushNotifications = PushNotifications(
        admin: widget.admin,
        context: context,
        isMounted: () => mounted,
        onNotification: (admin, client) async {
          return await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MessageInboxScreen(admin, client)));
        });
  }

  @override
  void dispose() {
    super.dispose();
    _clientBloc.close();
    _pushNotifications.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocProvider<ClientBloc>(
      create: (context) =>
          ClientBloc(clientRepository: FirebaseClientsRepository())
            ..add(LoadClientsEvent(admin: widget.admin)),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute<AddClient>(
                    builder: (_) => BlocProvider.value(
                          value: _clientBloc,
                          child: AddClient(
                            false,
                            admin: widget.admin,
                          ),
                        )))),
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

          return ClientTile(
            client: client,
            admin: widget.admin,
          );
        });
  }
}
