import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_bloc.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_event.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/Models/User/user.dart';
import 'package:the_cleaning_ladies/src/Widgets/AddClientForm/addClientForm.dart';

class AddClient extends StatefulWidget {
  final Admin admin;
  final bool isEditing;
  final Client client;
  final VoidCallback exitEditing;

  AddClient(this.isEditing,
      {@required this.admin, this.client, this.exitEditing});
  @override
  _AddClientState createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  Client client = Client(family: []);
  User family = User();
  List<Day> _dayPreferenceList = [
    Day(name: 'Mon.'),
    Day(name: 'Tues.'),
    Day(name: 'Wed.'),
    Day(name: 'Thurs.'),
    Day(name: 'Fri.'),
    Day(name: 'Sat.'),
  ];

  bool disableAddDemoButton = false;
  void addNewCustomers(int ammount) {
    setState(() {
      disableAddDemoButton = true;
    });
    List<Client> demoAccountList = [];
    for (var i = 0; i < ammount; i++) {
      int randInt3 = Random().nextInt(3);
      int randInt4 = Random().nextInt(4);
      int randDay = Random().nextInt(6);

      demoAccountList.add(Client(
          streetAddress: 'street address $i',
          city: 'city $i',
          state: 'state $i',
          zipCode: 'zipCode $i',
          contactNumber: '+19091234567',
          cleaningFrequency: CleaningFrequency.values.elementAt(randInt4),
          cleaningTimePreference:
              CleaningTimePreference.values.elementAt(randInt3),
          firstName: 'Demo$i',
          lastName: 'Last$i',
          userType: UserType.client,
          dayPreferences: _dayPreferenceList,
          lastCleaning: DateTime.parse(DateFormat('yyyyMMdd').format(
              DateTime.now()
                  .add(Duration(days: 3))
                  .subtract(Duration(days: randDay))))));
    }
    BlocProvider.of<ClientBloc>(context)
        .add(AddDemoClientsEvent(demoAccountList));
    BlocProvider.of<ClientBloc>(context).add(LoadClientsEvent());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.isEditing
        ? AddClientForm(
            exitEditing: widget.exitEditing,
            client: widget.client,
            isEditing: true,
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Adding New Client'),
              actions: <Widget>[
                FlatButton(
                  child: Icon(Icons.autorenew),
                  disabledColor: Colors.grey[600],
                  onPressed:
                      disableAddDemoButton ? null : () => addNewCustomers(5),
                ),
              ],
            ),
            body: AddClientForm(
              isEditing: false,
              client: client,
            ),
          );
  }
}
