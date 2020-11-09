import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/src/Auth/auth.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';

class SignUp extends StatefulWidget {
  final Auth auth;
  final VoidCallback onSignUp;
  final VoidCallback onLoginTap;
  SignUp(
      {@required this.auth,
      @required this.onSignUp,
      @required this.onLoginTap});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
            Text(
              'Login',
              style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 5.5,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Form(
                  child: Column(
                children: [
                  Container(
                    child: TextFormField(
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
                      onPressed: () {
                        widget.onSignUp();
                      },
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
