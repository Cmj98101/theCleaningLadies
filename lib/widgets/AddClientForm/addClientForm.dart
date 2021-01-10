import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client_bloc.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client_event.dart';
import 'package:the_cleaning_ladies/widgets/AddClientForm/family_section.dart';

class AddClientForm extends StatefulWidget {
  final bool isEditing;
  final Client client;
  final Admin admin;
  final VoidCallback exitEditing;
  AddClientForm({this.exitEditing, this.client, this.isEditing, this.admin});

  @override
  _AddClientFormState createState() => _AddClientFormState();
}

class _AddClientFormState extends State<AddClientForm> {
  final clientFormKey = GlobalKey<FormState>();

  Client client;

  ServiceFrequency _serviceFrequency = ServiceFrequency.weekly;
  PaymentType _paymentType = PaymentType.cash;
  bool _keyRequired;
  ServiceTimePreference _serviceTimePreference =
      ServiceTimePreference.earlyMornings;

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
      client.serviceFrequency = _serviceFrequency;
      client.serviceTimePreference = _serviceTimePreference;
      client.keyRequired = _keyRequired;
      client.paymentType = _paymentType;
      client.dayPreferences = _dayPreferenceList;
      client.adminUserId = widget.admin.id;
      client.notificationCount = 0;
      client.businessCode = widget.admin.businessCode;
      BlocProvider.of<ClientBloc>(context).add(AddClientEvent(client));
      BlocProvider.of<ClientBloc>(context)
          .add(LoadClientsEvent(admin: widget.admin));
      Navigator.pop(context);
    }
  }

  updateClient() {
    if (validateAndSaveClientForm()) {
      client.serviceFrequency = _serviceFrequency;
      client.serviceTimePreference = _serviceTimePreference;
      client.keyRequired = _keyRequired;
      client.paymentType = _paymentType;
      client.adminUserId = widget.admin.id;
      changeDayPreferences();
      BlocProvider.of<ClientBloc>(context).add(UpdateClientEvent(client));
      widget.exitEditing();
    }
  }

  void changeDayPreferences() {
    for (int i = 0; i < _dayPreferenceList.length; i++) {
      client.dayPreferences[i].favoribleScale =
          _dayPreferenceList[i].favoribleScale;
    }
  }

  handlePaymentChange(PaymentType paymentType) {
    setState(() {
      _paymentType = paymentType;
      print(_paymentType);
    });
  }

  handleScheduleChange(ServiceFrequency serviceFrequency) {
    setState(() {
      _serviceFrequency = serviceFrequency;
      print(_serviceFrequency);
    });
  }

  handleKeyRequiredChange(bool val) {
    setState(() {
      _keyRequired = val;
    });
  }

  @override
  void initState() {
    super.initState();
    client = widget.client;
    _keyRequired = client?.keyRequired ?? false;
    _paymentType = client?.paymentType ?? PaymentType.unknown;
    _serviceFrequency = client.serviceFrequency;
    _serviceTimePreference = client.serviceTimePreference;
    if (widget.isEditing) {
      for (int i = 0; i < _dayPreferenceList.length; i++) {
        _dayPreferenceList[i].favoribleScale =
            client.dayPreferences[i].favoribleScale;
      }
    }
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
                          labelText: 'Cost per Service', prefixText: '\$'),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      onSaved: (val) =>
                          client.costPerCleaning = (double.parse(val.trim())),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  showFavoribleDaySelection(),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  showPaymentTypeSelection(),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  showServiceFrequencySelection(),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  showServiceTimePreference(),
                  // displayTimeInterval(),
                  // Container(child: TextField(decoration: InputDecoration(labelText: 'Custom Time'),),),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  ListTile(
                      title: Text('Key Required?'),
                      leading: Checkbox(
                        value: _keyRequired,
                        onChanged: (val) => handleKeyRequiredChange(val),
                      )),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  FamilySection(
                    client: client,
                  ),
                  showSubmitBtn(),
                ],
              ),
            )));
  }

  Widget showFavoribleDaySelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (var day
            in widget.isEditing ? _dayPreferenceList : _dayPreferenceList)
          Container(
            child: InkWell(
                onTap: () => onDayTapPress(day),
                onLongPress: () => onDayLongPress(day),
                child: Text(day.name,
                    style: TextStyle(
                        fontSize: 18,
                        color: day.favoribleScale == FavoribleScale.isOkay
                            ? Colors.blue[400]
                            : day.favoribleScale == FavoribleScale.isPrefered
                                ? Colors.green[400]
                                : Colors.red[400]))),
          )
      ],
    );
  }

  Widget showTitleText({@required String title}) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }

  Widget showListTileText({@required String title}) {
    return Text(title);
  }

  Widget showPaymentTypeSelection() {
    return Column(
      children: [
        showTitleText(title: 'Payment Type'),
        ListTile(
          title: showListTileText(title: 'Cash'),
          leading: Radio(
              value: PaymentType.cash,
              groupValue: _paymentType,
              onChanged: (paymentType) => handlePaymentChange(paymentType)),
          trailing: Icon(
            FontAwesomeIcons.moneyBillWave,
            color: _paymentType == PaymentType.cash
                ? Colors.green[600]
                : Colors.grey,
          ),
        ),
        ListTile(
          title: showListTileText(title: 'Check'),
          leading: Radio(
              value: PaymentType.check,
              groupValue: _paymentType,
              onChanged: (paymentType) => handlePaymentChange(paymentType)),
          trailing: Icon(
            FontAwesomeIcons.moneyCheck,
            color: _paymentType == PaymentType.check
                ? Colors.blue[300]
                : Colors.grey,
          ),
        ),
        ListTile(
          title: showListTileText(title: 'Online'),
          leading: Radio(
              value: PaymentType.quickPay,
              groupValue: _paymentType,
              onChanged: (paymentType) => handlePaymentChange(paymentType)),
          trailing: Icon(
            FontAwesomeIcons.ccVisa,
            color: _paymentType == PaymentType.quickPay
                ? Colors.black
                : Colors.grey,
          ),
        ),
        ListTile(
          title: showListTileText(title: 'Uknown'),
          leading: Radio(
              value: PaymentType.unknown,
              groupValue: _paymentType,
              onChanged: (paymentType) => handlePaymentChange(paymentType)),
          trailing: Icon(
            FontAwesomeIcons.questionCircle,
            color: _paymentType == PaymentType.unknown
                ? Colors.orange
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  showServiceFrequencySelection() {
    return Column(
      children: [
        showTitleText(title: 'Service Frequency'),
        ListTile(
          title: showListTileText(title: 'Weekly'),
          leading: Radio(
              value: ServiceFrequency.weekly,
              groupValue: _serviceFrequency,
              onChanged: (scheduled) => handleScheduleChange(scheduled)),
        ),
        ListTile(
          title: showListTileText(title: 'Bi-Weekly'),
          leading: Radio(
              value: ServiceFrequency.biWeekly,
              groupValue: _serviceFrequency,
              onChanged: (scheduled) => handleScheduleChange(scheduled)),
        ),
        ListTile(
          title: showListTileText(title: 'Monthly'),
          leading: Radio(
              value: ServiceFrequency.monthly,
              groupValue: _serviceFrequency,
              onChanged: (scheduled) => handleScheduleChange(scheduled)),
        ),
        ListTile(
          title: showListTileText(title: 'Custom'),
          leading: Radio(
              value: ServiceFrequency.custom,
              groupValue: _serviceFrequency,
              onChanged: (scheduled) => handleScheduleChange(scheduled)),
        ),
      ],
    );
  }

  Widget showServiceTimePreference() {
    return Column(
      children: [
        showTitleText(title: 'Service Time Preference'),
        ListTile(
          title: showListTileText(title: 'Early Mornings'),
          leading: Radio(
              value: ServiceTimePreference.earlyMornings,
              groupValue: _serviceTimePreference,
              onChanged: (serviceTimePreference) =>
                  handleServiceTimePreferenceChange(serviceTimePreference)),
        ),
        ListTile(
          title: showListTileText(title: 'Late Mornings'),
          leading: Radio(
              value: ServiceTimePreference.lateMornings,
              groupValue: _serviceTimePreference,
              onChanged: (serviceTimePreference) =>
                  handleServiceTimePreferenceChange(serviceTimePreference)),
        ),
        ListTile(
          title: showListTileText(title: 'Afternoons'),
          leading: Radio(
              value: ServiceTimePreference.afternoons,
              groupValue: _serviceTimePreference,
              onChanged: (serviceTimePreference) =>
                  handleServiceTimePreferenceChange(serviceTimePreference)),
        ),
        ListTile(
          title: showListTileText(title: 'Custom'),
          leading: Radio(
              value: ServiceTimePreference.custom,
              groupValue: _serviceTimePreference,
              onChanged: (serviceTimePreference) =>
                  handleServiceTimePreferenceChange(serviceTimePreference)),
          trailing: displayTimeInterval(),
        ),
      ],
    );
  }

  showSubmitBtn() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: RaisedButton(
        child: Text(widget.isEditing ? 'Update ' : 'Add'),
        onPressed: widget.isEditing ? updateClient : submitClientForm,
      ),
    );
  }

  String customTime = '';

  handleServiceTimePreferenceChange(ServiceTimePreference time) {
    setState(() {
      _serviceTimePreference = time;
      client.serviceTimePreference = _serviceTimePreference;
      client.customTimePreference = DateTime(2020, 1, 1, 7);
      if (client.serviceTimePreference == ServiceTimePreference.custom) {
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
