import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/models/user_models/user.dart';

class FamilySection extends StatefulWidget {
  final Client client;
  FamilySection({@required this.client});
  @override
  _FamilySectionState createState() => _FamilySectionState();
}

class _FamilySectionState extends State<FamilySection> {
  final familyFormKey = GlobalKey<FormState>();

  Client client;
  User family = User();

  @override
  void initState() {
    super.initState();
    client = widget.client;
  }

  bool addFamily = false;
  bool _addingFamilyMember = false;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                        decoration: InputDecoration(labelText: 'First Name'),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                        onSaved: (val) => family.firstName = val.trim(),
                      ),
                    ),
                    Container(
                      // margin: EdgeInsets.only(left: 15),
                      child: TextFormField(
                        validator: (value) => value.isEmpty
                            ? 'LastName field can\'t be Emtpy'
                            : null,
                        decoration: InputDecoration(labelText: 'Last Name'),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                        onSaved: (val) => family.lastName = val.trim(),
                      ),
                    ),
                    Container(
                      // margin: EdgeInsets.only(left: 15),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Relation'),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                        onSaved: (val) => family.relation = val.trim(),
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
                    User fam = client.family[index];
                    return Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Card(
                          child: ListTile(
                        title: Text('${fam.firstName}, ${fam.lastName}'),
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
      ],
    );
  }
}
