import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/src/Admin/EasyDB/EasyDb.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/Admin/displayManager.dart';
import 'package:the_cleaning_ladies/src/Auth/auth.dart';
import 'package:the_cleaning_ladies/src/Auth/authHandler.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/Client/displayManager.dart';
import 'package:the_cleaning_ladies/src/login.dart';
import 'package:the_cleaning_ladies/src/signup.dart';

enum AuthStatus { admin, client, loggedOff, signUp }

class ScreenManager extends StatefulWidget {
  final Auth auth;
  ScreenManager({@required this.auth});
  @override
  _ScreenManagerState createState() => _ScreenManagerState();
}

class _ScreenManagerState extends State<ScreenManager> {
  AuthStatus authStatus;
  Admin admin;
  Client client;
  @override
  void initState() {
    super.initState();
    // setState(() {
    HandleAuth.getCurrentUser(
      context,
      logInAdmin: (loggedInAdmin) {
        admin = loggedInAdmin;
        loginAdmin();
      },
      logInClient: (loggedInClient) {
        client = loggedInClient;
        loginUser();
      },
      onLoggedOff: () => onLoggedOff,
    );
  }

  void loginAdmin() {
    setState(() {
      authStatus = AuthStatus.admin;
    });
  }

  void loginUser() {
    setState(() {
      authStatus = AuthStatus.client;
    });
  }

  void signUpUser() {
    setState(() {
      authStatus = AuthStatus.client;
    });
  }

  void onLoggedOff() {
    setState(() {
      authStatus = AuthStatus.loggedOff;
    });
  }

  void onLoginTap() {
    setState(() {
      authStatus = AuthStatus.loggedOff;
    });
  }

  void onSignUpTap() {
    setState(() {
      authStatus = AuthStatus.signUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.admin:
        return AdminDisplayManager(
          admin,
          DataBaseRepo(),
          onLoggedOff: onLoggedOff,
        );
        break;
      case AuthStatus.client:
        return ClientDisplayManager(admin, client, DataBaseRepo());
        break;
      case AuthStatus.loggedOff:
        return Login(
          onSignInAdmin: loginAdmin,
          onSignInClient: loginUser,
          onSignUpTap: onSignUpTap,
        );
        break;
      case AuthStatus.signUp:
        return SignUp(
            auth: widget.auth, onSignUp: signUpUser, onLoginTap: onLoginTap);
        break;

      default:
        return Login(
          onSignInAdmin: loginAdmin,
          onSignInClient: loginUser,
          onSignUpTap: onSignUpTap,
        );
        break;
    }
  }
}
