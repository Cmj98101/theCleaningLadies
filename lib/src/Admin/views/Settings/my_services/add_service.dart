import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:the_cleaning_ladies/models/service/service.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/utils/form_validation/form_validation.dart';
import 'package:the_cleaning_ladies/widgets/raisedButtonX.dart';

class AddService extends StatefulWidget {
  final Admin admin;
  AddService({@required this.admin});

  @override
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  GlobalKey<FormState> serviceFormKey = GlobalKey<FormState>();
  FormValidation _validation;
  Service service = Service();
  bool isAddingMore = false;

  @override
  void initState() {
    super.initState();
    _validation = FormValidation(serviceFormKey, onSuccessFullValidation: () {
      widget.admin.services.add(service);
      widget.admin.services.list.add(service);
    }, unSuccessFullValidation: () {});
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
                child: ElevatedButtonX(
                  childX: Text('Add'),
                  onPressedX: () {
                    _validation.submitForm();

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
