import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_bloc.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_event.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/Models/User/user.dart';

typedef WidgetCallBack = Widget Function();

class AddClientForm extends StatefulWidget {
  final bool isEditing;
  final Client client;
  final VoidCallback exitEditing;
  AddClientForm({this.exitEditing, this.client, this.isEditing});

  @override
  _AddClientFormState createState() => _AddClientFormState();
}

class _AddClientFormState extends State<AddClientForm> {
  final clientFormKey = GlobalKey<FormState>();

  final familyFormKey = GlobalKey<FormState>();
  Client client;

  User family = User();

  CleaningFrequency _cleaningFrequency = CleaningFrequency.weekly;

  CleaningTimePreference _cleaningTimePreference =
      CleaningTimePreference.earlyMornings;

  bool addFamily = false;

  bool _addingFamilyMember = false;

  bool timePreferenceIsCustom = false;

  List<Day> _dayPreferenceList = [
    Day(name: 'Mon.'),
    Day(name: 'Tues.'),
    Day(name: 'Wed.'),
    Day(name: 'Thurs.'),
    Day(name: 'Fri.'),
    Day(name: 'Sat.'),
  ];

  bool validateAndSaveClientForm() {
    var form = clientFormKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  submitClientForm() {
    if (validateAndSaveClientForm()) {
      client.dayPreferences = _dayPreferenceList;
      BlocProvider.of<ClientBloc>(context).add(AddClientEvent(client));
      BlocProvider.of<ClientBloc>(context).add(LoadClientsEvent());
      Navigator.pop(context);
    }
  }

  updateClient() {
    if (validateAndSaveClientForm()) {
      BlocProvider.of<ClientBloc>(context).add(UpdateClientEvent(client));
      widget.exitEditing();
    }
  }

  bool validateAndSaveFamilyForm() {
    var form = familyFormKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  submitFamilyForm() {
    if (validateAndSaveFamilyForm()) {
      setState(() {
        client.family.add(User.family(
            firstName: family.firstName,
            lastName: family.lastName,
            relation: family.relation));
      });
    }
  }

  handleScheduleChange(CleaningFrequency scheduled) {
    setState(() {
      _cleaningFrequency = scheduled;
      client.cleaningFrequency = _cleaningFrequency;
      print(client.cleaningFrequency);
    });
  }

  handleKeyRequiredChange(bool val) {
    setState(() {
      client.keyRequired = val;
    });
  }

  @override
  void initState() {
    super.initState();
    client = widget.client;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 20),
        child: Form(
            key: clientFormKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    // margin: EdgeInsets.only(left: 15),
                    child: TextFormField(
                      initialValue: widget.isEditing ? client.firstName : '',
                      decoration: InputDecoration(labelText: 'First Name'),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      onSaved: (val) => client.firstName = val.trim(),
                    ),
                  ),
                  Container(
                    // margin: EdgeInsets.only(left: 15),
                    child: TextFormField(
                      initialValue: widget.isEditing ? client.lastName : '',
                      decoration: InputDecoration(labelText: 'Last Name'),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      onSaved: (val) => client.lastName = val.trim(),
                    ),
                  ),
                  Container(
                    // margin: EdgeInsets.only(left: 15),
                    child: TextFormField(
                      initialValue:
                          widget.isEditing ? client.formatPhoneNumber : '',
                      decoration: InputDecoration(labelText: 'Mobile Number'),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneInputFormatter()],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      onSaved: (val) => client.contactNumber = val.trim(),
                    ),
                  ),
                  Container(
                    // margin: EdgeInsets.only(left: 15),
                    child: TextFormField(
                      initialValue:
                          widget.isEditing ? client.streetAddress : '',
                      decoration: InputDecoration(labelText: 'Street Address'),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      onSaved: (val) => client.streetAddress = val.trim(),
                    ),
                  ),
                  Container(
                    // margin: EdgeInsets.only(left: 15),
                    child: TextFormField(
                      initialValue:
                          widget.isEditing ? client.buildingNumber : '',
                      decoration: InputDecoration(labelText: 'Suite, APT #'),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      onSaved: (val) => client.buildingNumber = val.trim(),
                    ),
                  ),
                  Container(
                    // margin: EdgeInsets.only(left: 15),
                    child: TextFormField(
                      initialValue: widget.isEditing ? client.city : '',
                      decoration: InputDecoration(labelText: 'City'),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      onSaved: (val) => client.city = val.trim(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * .45,
                        // margin: EdgeInsets.only(left: 15),
                        child: TextFormField(
                          initialValue: widget.isEditing ? client.state : '',
                          decoration: InputDecoration(labelText: 'State'),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                          onSaved: (val) => client.state = val.trim(),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .45,
                        // margin: EdgeInsets.only(left: 15),
                        child: TextFormField(
                          initialValue: widget.isEditing ? client.zipCode : '',
                          decoration: InputDecoration(labelText: 'Zip Code'),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                          onSaved: (val) => client.zipCode = val.trim(),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    // margin: EdgeInsets.only(left: 15),
                    child: TextFormField(
                      initialValue: widget.isEditing
                          ? client.costPerCleaning.toString()
                          : '',
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        MoneyInputFormatter(
                          thousandSeparator: ThousandSeparator.Comma,
                        )
                      ],
                      decoration: InputDecoration(
                          labelText: 'Cost per Cleaning', prefixText: '\$'),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      onSaved: (val) => client.costPerCleaning =
                          (double.parse(val.trim())).truncate(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      for (var day in widget.isEditing
                          ? client.dayPreferences
                          : _dayPreferenceList)
                        Container(
                          child: InkWell(
                              onTap: () => onDayTapPress(day),
                              onLongPress: () => onDayLongPress(day),
                              child: Text(day.name,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: day.favoribleScale ==
                                              FavoribleScale.isOkay
                                          ? Colors.blue[400]
                                          : day.favoribleScale ==
                                                  FavoribleScale.isPrefered
                                              ? Colors.green[400]
                                              : Colors.red[400]))),
                        )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  Container(
                      child: Text(
                    'Cleaning Frequency',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  )),
                  ListTile(
                    title: Text('Weekly'),
                    leading: Radio(
                        value: CleaningFrequency.weekly,
                        groupValue: widget.isEditing
                            ? client.cleaningFrequency
                            : _cleaningFrequency,
                        onChanged: (scheduled) =>
                            handleScheduleChange(scheduled)),
                  ),
                  ListTile(
                    title: Text('Bi-Weekly'),
                    leading: Radio(
                        value: CleaningFrequency.biWeekly,
                        groupValue: widget.isEditing
                            ? client.cleaningFrequency
                            : _cleaningFrequency,
                        onChanged: (scheduled) =>
                            handleScheduleChange(scheduled)),
                  ),
                  ListTile(
                    title: Text('Monthly'),
                    leading: Radio(
                        value: CleaningFrequency.monthly,
                        groupValue: widget.isEditing
                            ? client.cleaningFrequency
                            : _cleaningFrequency,
                        onChanged: (scheduled) =>
                            handleScheduleChange(scheduled)),
                  ),
                  ListTile(
                    title: Text('Custom'),
                    leading: Radio(
                        value: CleaningFrequency.custom,
                        groupValue: widget.isEditing
                            ? client.cleaningFrequency
                            : _cleaningFrequency,
                        onChanged: (scheduled) =>
                            handleScheduleChange(scheduled)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  Container(
                      child: Text(
                    'Cleaning Frequency',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  )),
                  ListTile(
                    title: Text('Early Mornings'),
                    leading: Radio(
                        value: CleaningTimePreference.earlyMornings,
                        groupValue: widget.isEditing
                            ? client.cleaningTimePreference
                            : _cleaningTimePreference,
                        onChanged: (cleaningTimePreference) =>
                            handlecleaningTimePreferenceChange(
                                cleaningTimePreference)),
                  ),
                  ListTile(
                    title: Text('Late Mornings'),
                    leading: Radio(
                        value: CleaningTimePreference.lateMornings,
                        groupValue: widget.isEditing
                            ? client.cleaningTimePreference
                            : _cleaningTimePreference,
                        onChanged: (cleaningTimePreference) =>
                            handlecleaningTimePreferenceChange(
                                cleaningTimePreference)),
                  ),
                  ListTile(
                    title: Text('Afternoons'),
                    leading: Radio(
                        value: CleaningTimePreference.afternoons,
                        groupValue: widget.isEditing
                            ? client.cleaningTimePreference
                            : _cleaningTimePreference,
                        onChanged: (cleaningTimePreference) =>
                            handlecleaningTimePreferenceChange(
                                cleaningTimePreference)),
                  ),

                  ListTile(
                    title: Text('Custom'),
                    leading: Radio(
                        value: CleaningTimePreference.custom,
                        groupValue: widget.isEditing
                            ? client.cleaningTimePreference
                            : _cleaningTimePreference,
                        onChanged: (cleaningTimePreference) =>
                            handlecleaningTimePreferenceChange(
                                cleaningTimePreference)),
                    trailing: displayTimeInterval(),
                  ),
                  // displayTimeInterval(),
                  // Container(child: TextField(decoration: InputDecoration(labelText: 'Custom Time'),),),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  ListTile(
                      title: Text('Key Required?'),
                      leading: Checkbox(
                        value: client?.keyRequired ?? false,
                        onChanged: (val) => handleKeyRequiredChange(val),
                      )),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  Container(
                      child: Text(
                    'Family Section',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  )),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                  ),
                  addFamily
                      ? Form(
                          key: familyFormKey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                // margin: EdgeInsets.only(left: 15),
                                child: TextFormField(
                                  validator: (value) => value.isEmpty
                                      ? 'First Name field can\'t be Emtpy'
                                      : null,
                                  decoration:
                                      InputDecoration(labelText: 'First Name'),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                  onSaved: (val) =>
                                      family.firstName = val.trim(),
                                ),
                              ),
                              Container(
                                // margin: EdgeInsets.only(left: 15),
                                child: TextFormField(
                                  validator: (value) => value.isEmpty
                                      ? 'LastName field can\'t be Emtpy'
                                      : null,
                                  decoration:
                                      InputDecoration(labelText: 'Last Name'),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                  onSaved: (val) =>
                                      family.lastName = val.trim(),
                                ),
                              ),
                              Container(
                                // margin: EdgeInsets.only(left: 15),
                                child: TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Relation'),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                  onSaved: (val) =>
                                      family.relation = val.trim(),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 15),
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.only(left: 15),
                                        child: RaisedButton(
                                          color: Colors.green[300],
                                          child: Text('Add'),
                                          onPressed: () => submitFamilyForm(),
                                        )),
                                    Container(
                                        margin: EdgeInsets.only(left: 15),
                                        child: RaisedButton(
                                          color: Colors.red,
                                          child: Text('Exit'),
                                          onPressed: () {
                                            _addingFamilyMember = false;
                                            setState(() {
                                              addFamily = !addFamily;
                                            });
                                          },
                                        )),
                                  ]),
                            ],
                          ))
                      : Container(
                          margin: EdgeInsets.only(left: 15),
                          child: RaisedButton(
                            color: Colors.green,
                            child: Text('Add Family Member'),
                            onPressed: () {
                              _addingFamilyMember = true;
                              setState(() {
                                addFamily = !addFamily;
                              });
                            },
                          )),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                  ),
                  client.family.length < 1
                      ? Container()
                      : Container(
                          height: 300,
                          child: ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              var fam = client.family[index];
                              return Container(
                                margin: EdgeInsets.only(left: 15),
                                child: Card(
                                    child: ListTile(
                                  title:
                                      Text('${fam.firstName}, ${fam.lastName}'),
                                  subtitle: Text('${fam.relation}'),
                                  trailing: FlatButton(
                                    child: Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        client.family.removeAt(index);
                                      });
                                    },
                                  ),
                                )),
                              );
                            },
                            itemCount: client.family.length,
                          ),
                        ),
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: RaisedButton(
                      child: Text(widget.isEditing ? 'Update ' : 'Add'),
                      onPressed:
                          widget.isEditing ? updateClient : submitClientForm,
                    ),
                  )
                ],
              ),
            )));
  }

  String customTime = '';

  handlecleaningTimePreferenceChange(CleaningTimePreference time) {
    setState(() {
      _cleaningTimePreference = time;
      client.cleaningTimePreference = _cleaningTimePreference;
      client.customTimePreference = DateTime(2020, 1, 1, 7);
      if (client.cleaningTimePreference == CleaningTimePreference.custom) {
        timePreferenceIsCustom = true;
        customTime = DateFormat('h:mm a').format(client.customTimePreference);
      } else {
        timePreferenceIsCustom = false;
      }
    });
  }

  Widget displayTimeInterval() {
    DateTime time = DateTime(2020, 1, 1);
    return PopupMenuButton<DateTime>(
        enabled: timePreferenceIsCustom ? true : false,
        onSelected: (value) {
          setState(() {
            timePreferenceIsCustom = true;
            customTime = DateFormat('h:mm a').format(value);
            client.customTimePreference = value;
          });
        },
        initialValue: time.add(Duration(minutes: 15 * 15)),
        child: Container(
            child: timePreferenceIsCustom
                ? Text(customTime)
                : Icon(
                    Icons.access_time,
                  )),
        elevation: 6,
        itemBuilder: (BuildContext context) => <PopupMenuEntry<DateTime>>[
              for (var i = 32; i < 65; i++)
                PopupMenuItem<DateTime>(
                  child: Text(
                      '${DateFormat('h:mm a').format(time.add(Duration(minutes: i * 15)))}'),
                  value: time.add(Duration(minutes: i * 15)),
                )
            ]);
  }

  onDayTapPress(Day day) {
    if (day.favoribleScale == FavoribleScale.isOkay) {
      setState(() {
        day.favoribleScale = FavoribleScale.notOkay;
      });
    } else if (day.favoribleScale == FavoribleScale.notOkay) {
      setState(() {
        day.favoribleScale = FavoribleScale.isOkay;
      });
    } else {
      setState(() {
        day.favoribleScale = FavoribleScale.notOkay;
      });
    }
  }

  onDayLongPress(Day day) {
    setState(() {
      day.favoribleScale = FavoribleScale.isPrefered;
    });
  }
}
