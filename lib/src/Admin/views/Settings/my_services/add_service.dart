import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:the_cleaning_ladies/models/service/service.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';

class AddService extends StatefulWidget {
  final Admin admin;
  AddService({@required this.admin});

  @override
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  GlobalKey<FormState> serviceFormKey = GlobalKey<FormState>();

  Service service = Service();
  bool isAddingMore = false;
  bool validateAndSave() {
    final form = serviceFormKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void handleSubmit() {
    if (validateAndSave()) {
      widget.admin.services.add(service);
      widget.admin.services.list.add(service);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adding'),
      ),
      body: Container(
        child: Form(
          key: serviceFormKey,
          child: Column(
            children: [
              Container(
                child: CheckboxListTile(
                  onChanged: (val) {
                    setState(() {
                      isAddingMore = val;
                    });
                  },
                  value: isAddingMore,
                  title: Text('Adding More?'),
                ),
              ),
              Container(
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Service Name'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  onSaved: (val) => service.name = val.trim(),
                ),
              ),
              Container(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: 'Service Duration (minutes)'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  onSaved: (val) => service.duration =
                      Duration(minutes: int.parse(val.trim())),
                ),
              ),
              Container(
                // margin: EdgeInsets.only(left: 15),
                child: TextFormField(
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  onSaved: (val) => service.cost = (double.parse(val.trim())),
                ),
              ),
              Container(
                child: RaisedButton(
                  child: Text('Add'),
                  onPressed: () {
                    handleSubmit();

                    if (!isAddingMore) {
                      Navigator.pop(context);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
