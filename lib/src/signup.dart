import 'dart:async';

import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/error_handlers/errorHandlers.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/user.dart';
import 'package:the_cleaning_ladies/src/Auth/auth.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/src/auth/authHandler.dart';

class SignUp extends StatefulWidget {
  final Auth auth;
  final VoidCallback onSignUp;
  final VoidCallback onLoginTap;
  final Function(Admin) onSignInAdmin;

  SignUp({
    @required this.auth,
    @required this.onSignUp,
    @required this.onLoginTap,
    @required this.onSignInAdmin,
  });
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  User user;
  TextEditingController _businessNameTFC = TextEditingController();
  TextEditingController _emailTFC = TextEditingController();
  TextEditingController _passwordTFC = TextEditingController();
  TextEditingController _firstNameTFC = TextEditingController();
  TextEditingController _lastNameTFC = TextEditingController();
  TextEditingController _cityTFC = TextEditingController();
  TextEditingController _stateTFC = TextEditingController();
  TextEditingController _zipCodeTFC = TextEditingController();
  TextEditingController _contactNumberTFC = TextEditingController();

  String errorMsgDisplay = '';

  void onSignUpTapped() {
    print('logging in');

    HandleAuth.signUp(context,
        user: user,
        isLoading: (isLoading) {
          setState(() {
            isLoading
                ? UserFriendlyMessages.loading(context)
                : Navigator.pop(context);
          });
        },
        onErrorMsg: (errorMsg) {
          setState(() {
            errorMsgDisplay = errorMsg;
          });
          Timer(Duration(seconds: 4), () {
            setState(() {
              errorMsgDisplay = '';
            });
          });
        },
        logInAdmin: (admin) => widget.onSignInAdmin(admin),
        formKey: formKey);
  }

  @override
  void initState() {
    super.initState();
    user = User();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      // ),
      body: Container(
        height: SizeConfig.safeBlockVertical * 100,
        margin: EdgeInsets.all(40),
        child: ListView(
          children: [
            Text(
              'Sign Up',
              style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 5.5,
                  fontWeight: FontWeight.bold),
            ),
            errorMsgDisplay.isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      errorMsgDisplay,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 3,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Container(
                        child: TextFormField(
                          onChanged: (value) =>
                              user.businessName = value.trim(),
                          controller: _businessNameTFC,
                          validator: (value) => value.isEmpty
                              ? 'Business name field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => user.businessName = value.trim(),
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 3),
                          decoration: InputDecoration(
                              hintText: 'Business Name',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black))),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              child: TextFormField(
                                onChanged: (value) =>
                                    user.firstName = value.trim(),
                                controller: _firstNameTFC,
                                validator: (value) => value.isEmpty
                                    ? 'First name field can\'t be Emtpy'
                                    : null,
                                onSaved: (value) =>
                                    user.firstName = value.trim(),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 3),
                                decoration: InputDecoration(
                                    hintText: 'First Name',
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black))),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              margin: EdgeInsets.only(top: 10),
                              child: TextFormField(
                                onChanged: (value) =>
                                    user.lastName = value.trim(),
                                controller: _lastNameTFC,
                                validator: (value) => value.isEmpty
                                    ? 'Last Name field can\'t be Emtpy'
                                    : null,
                                onSaved: (value) =>
                                    user.lastName = value.trim(),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 3),
                                decoration: InputDecoration(
                                    hintText: 'Last Name',
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        // width: SizeConfig.safeBlockHorizontal * 35,
                        margin: EdgeInsets.only(top: 10),
                        child: TextFormField(
                          onChanged: (value) => user.email = value.trim(),
                          controller: _emailTFC,
                          validator: (value) => value.isEmpty
                              ? 'Email field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => user.email = value.trim(),
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 3),
                          decoration: InputDecoration(
                              hintText: 'Email',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black))),
                        ),
                      ),
                      Container(
                        // width: SizeConfig.safeBlockHorizontal * 35,
                        margin: EdgeInsets.only(top: 10),
                        child: TextFormField(
                          onChanged: (value) => user.city = value.trim(),
                          controller: _cityTFC,
                          validator: (value) => value.isEmpty
                              ? 'City field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => user.city = value.trim(),
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 3),
                          decoration: InputDecoration(
                              hintText: 'City',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black))),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              margin: EdgeInsets.only(top: 10),
                              child: TextFormField(
                                onChanged: (value) => user.state = value.trim(),
                                controller: _stateTFC,
                                validator: (value) => value.isEmpty
                                    ? 'State field can\'t be Emtpy'
                                    : null,
                                onSaved: (value) => user.state = value.trim(),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 3),
                                decoration: InputDecoration(
                                    hintText: 'State',
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black))),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              margin: EdgeInsets.only(top: 10),
                              child: TextFormField(
                                onChanged: (value) =>
                                    user.zipCode = value.trim(),
                                controller: _zipCodeTFC,
                                validator: (value) => value.isEmpty
                                    ? 'Zip code field can\'t be Emtpy'
                                    : null,
                                onSaved: (value) => user.zipCode = value.trim(),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 3),
                                decoration: InputDecoration(
                                    hintText: 'Postal Code',
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        // width: SizeConfig.safeBlockHorizontal * 35,
                        margin: EdgeInsets.only(top: 10),
                        child: TextFormField(
                          onChanged: (value) =>
                              user.contactNumber = value.trim(),
                          controller: _contactNumberTFC,
                          validator: (value) => value.isEmpty
                              ? 'Contact Number field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => user.contactNumber = value.trim(),
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 3),
                          decoration: InputDecoration(
                              hintText: 'Contact Number',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black))),
                        ),
                      ),
                      Container(
                        // width: SizeConfig.safeBlockHorizontal * 35,
                        margin: EdgeInsets.only(top: 10),
                        child: TextFormField(
                          onChanged: (value) => user.password = value.trim(),
                          controller: _passwordTFC,
                          validator: (value) => value.isEmpty
                              ? 'Password field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => user.password = value.trim(),
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 3),
                          decoration: InputDecoration(
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black))),
                        ),
                      ),
                      Container(
                        width: SizeConfig.safeBlockHorizontal * 50,
                        margin: EdgeInsets.only(top: 30),
                        child: RaisedButton(
                          onPressed: () => onSignUpTapped(),
                          child: Text('Sign Up'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: FlatButton(
                            onPressed: () {
                              widget.onLoginTap();
                            },
                            child: Text('Already have an account login here')),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
