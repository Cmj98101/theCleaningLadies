import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_cleaning_ladies/src/Admin/Screens/moreClientInfo.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/ClientRepo/clientRepo.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client.state.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_bloc.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_event.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';

class SelectClientForAppointment extends StatefulWidget {
  @override
  _SelectClientForAppointmentState createState() =>
      _SelectClientForAppointmentState();
}

class _SelectClientForAppointmentState
    extends State<SelectClientForAppointment> {
  TextEditingController searchCustomerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientBloc>(
      create: (context) =>
          ClientBloc(clientRepository: FirebaseClientsRepository())
            ..add(LoadClientsEvent()),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Select Customer',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20.0, right: 20.0, left: 20.0),
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                    style: TextStyle(fontSize: 20),
                    controller: searchCustomerController,
                    onChanged: (text) {
                      setState(() {});
                    },
                    decoration: InputDecoration.collapsed(
                        hintText: 'Search Customer Here'),
                  )),
                ],
              ),
              // margin: EdgeInsets.only(bottom: 20),
            ),
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

  Widget showClients({
    bool isFilteredList = false,
    List<Client> filtered,
    ClientLoaded state,
  }) {
    return ListView.builder(
        itemCount: isFilteredList ? filtered.length : state.clients.length,
        itemBuilder: (BuildContext context, int index) {
          var client = isFilteredList ? filtered[index] : state.clients[index];

          return InkWell(
            onTap: () {
              Navigator.pop(context, client);
            },
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              height: 100,
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
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
                                                              ? Colors
                                                                  .green[400]
                                                              : Colors
                                                                  .red[400]),
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
                                  builder: (context) => MoreClientInfo(
                                        client: client,
                                      )));
                        },
                        child: Icon(Icons.arrow_forward_ios),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
