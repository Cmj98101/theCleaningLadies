import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:twilioFlutter/twilioFlutter.dart';

class FindANumber extends StatefulWidget {
  final Admin admin;
  FindANumber({@required this.admin});
  @override
  _FindANumberState createState() => _FindANumberState();
}

class _FindANumberState extends State<FindANumber> {
  TextEditingController _areaCodeFieldController = TextEditingController();
  final searchNumbersFormKey = GlobalKey<FormState>();
  String areaCode = '';
  List<PhoneNumber> availablePhoneNumbers = [];
  Future<List<PhoneNumber>> futureAvailablePhoneNumbers;
  bool isLoadingNumbers = false;
  bool validateAndSaveSearchNumbersForm() {
    var form = searchNumbersFormKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  submitSearchNumbersForm() {
    if (validateAndSaveSearchNumbersForm()) {
      areaCode = _areaCodeFieldController.text;
      setState(() {
        futureAvailablePhoneNumbers =
            widget.admin.searchAvailbleNumbers((isLoading) {
          setState(() {
            isLoadingNumbers = isLoading;
          });
        }, areaCode: areaCode);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    futureAvailablePhoneNumbers = _getAvailablePhoneNumbers();
  }

  Future<List<PhoneNumber>> _getAvailablePhoneNumbers() async {
    return await widget.admin.searchAvailbleNumbers((isLoading) {
      setState(() {
        isLoadingNumbers = isLoading;
      });
    }, areaCode: areaCode);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose A Number'),
      ),
      body: widget.admin.twilioNumber.isNotEmpty
          ? Center(
              child: Container(
                child: Text(
                    'You already have a number! (${widget.admin.twilioNumber})'),
              ),
            )
          : Container(
              child: Column(
                children: [
                  inputAreaCodeSearch(),
                  submitBtn(),
                  showSearchResults(),
                ],
              ),
            ),
    );
  }

  Widget inputAreaCodeSearch() {
    return Form(
      key: searchNumbersFormKey,
      child: Container(
        // height: SizeConfig.safeBlockVertical * 8,
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                'Area Code',
                style: TextStyle(fontSize: 18),
              ),
              padding: EdgeInsets.all(20),
            ),
            Expanded(
              child: Container(
                width: 250,
                child: TextFormField(
                  onChanged: (value) => areaCode = value.trim(),
                  controller: _areaCodeFieldController,
                  maxLength: 3,
                  validator: (value) => value.length == 3
                      ? null
                      : 'Area Code must be 3 digits long!',
                  onSaved: (value) => areaCode = value.trim(),
                  style:
                      TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4.5),
                  decoration: InputDecoration(
                      hintText: 'Area Code',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget submitBtn() {
    return Container(
      width: SizeConfig.safeBlockHorizontal * 50,
      height: SizeConfig.safeBlockVertical * 5,
      child: RaisedButton(
        color: Colors.green[400],
        onPressed: () {
          submitSearchNumbersForm();
        },
        child: Text('Search', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget showSearchResults() {
    return Container(
        // color: Colors.green,
        height: SizeConfig.safeBlockVertical * 66,
        child: isLoadingNumbers
            ? Center(
                child: CircularProgressIndicator(),
              )
            : buildFuture(futureAvailablePhoneNumbers, (snap) {
                List<PhoneNumber> phoneNumberList = snap.data;

                return phoneNumberList.isEmpty
                    ? Container(
                        child: Center(
                          child: Text(
                              'No Numbers Available with that Area Code...'),
                        ),
                      )
                    : ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          PhoneNumber phoneNumber = phoneNumberList[index];

                          return Container(
                            child: Card(
                                elevation: 4,
                                child: ListTile(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: Text('Are you sure?'),
                                                content: Text(
                                                    'You are about to purchase ${phoneNumber.friendlyName}!'),
                                                actions: [
                                                  RaisedButton(
                                                    color: Colors.red,
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('cancel'),
                                                  ),
                                                  RaisedButton(
                                                    color: Colors.green,
                                                    onPressed: () {
                                                      print(
                                                          'Phone Number Purchased ... ${phoneNumber.friendlyName}');

                                                      Navigator.pop(context);
                                                      widget.admin
                                                          .provisionPhoneNumber(
                                                              (isLoading) {
                                                                setState(() {
                                                                  isLoadingNumbers =
                                                                      isLoading;
                                                                });
                                                              },
                                                              phoneNumber:
                                                                  phoneNumber
                                                                      .phoneNumber,
                                                              onDone: () {
                                                                widget.admin
                                                                        .twilioNumber =
                                                                    phoneNumber
                                                                        .phoneNumber;
                                                                setState(() {
                                                                  widget.admin
                                                                      .update({
                                                                    'apiPN':
                                                                        '${widget.admin.twilioNumber}'
                                                                  });
                                                                  print(
                                                                      'PURCHASED ${widget.admin.twilioNumber}');
                                                                });
                                                              });
                                                    },
                                                    child: Text('Buy Number'),
                                                  )
                                                ],
                                              ));
                                    },
                                    title: Text(
                                      phoneNumber.friendlyName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ))),
                          );
                        },
                        itemCount: phoneNumberList.length,
                      );
              }));
  }

  Widget buildFuture(Future future, Widget Function(AsyncSnapshot) widget) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
          switch (snap.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: Container(
                  child: CircularProgressIndicator(),
                ),
              );

              break;

            case ConnectionState.done:
              return widget(snap);
              break;

            default:
              return (Container(
                child: Text('NA'),
              ));
          }
        });
  }
}
