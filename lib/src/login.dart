import 'dart:async';

import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/src/Auth/authHandler.dart';
import 'package:the_cleaning_ladies/models/error_handlers/errorHandlers.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';

class Login extends StatefulWidget {
  final Function(Admin) onSignInAdmin;
  final Function(Client) onSignInClient;
  final VoidCallback onSignUpTap;
  Login(
      {@required this.onSignInAdmin,
      @required this.onSignInClient,
      @required this.onSignUpTap});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _emailTextFieldController = TextEditingController();
  TextEditingController _passwordTextFieldController = TextEditingController();
  String _email;
  String _password;
  String errorMsgDisplay = '';

  void onLogInTapped() {
    print('logging in');

    HandleAuth.login(context,
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
        email: _email,
        password: _password,
        logInAdmin: (admin) => widget.onSignInAdmin(admin),
        logInClient: (client) => widget.onSignInClient(client),
        formKey: formKey);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              child: Text(
                'Login',
                style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 5.5,
                    fontWeight: FontWeight.bold),
              ),
            ),
            errorMsgDisplay.isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      errorMsgDisplay,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 4,
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
                          onChanged: (value) => _email = value.trim(),
                          controller: _emailTextFieldController,
                          validator: (value) => value.isEmpty
                              ? 'Email field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => _email = value.trim(),
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 4.5),
                          decoration: InputDecoration(
                              hintText: 'Email',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black))),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: TextFormField(
                          onChanged: (value) => _password = value.trim(),
                          controller: _passwordTextFieldController,
                          validator: (value) => value.isEmpty
                              ? 'Password field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => _password = value.trim(),
                          obscureText: true,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal * 4.5),
                          decoration: InputDecoration(
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black))),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: RaisedButton(
                          onPressed: () => onLogInTapped(),
                          child: Text('Login'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: FlatButton(
                            onPressed: () {
                              widget.onSignUpTap();
                            },
                            child: Text(
                                'Don\'t have an account one signup one here')),
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
