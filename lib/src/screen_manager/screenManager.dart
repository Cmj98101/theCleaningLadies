import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/src/Admin/displayManager.dart';
import 'package:the_cleaning_ladies/src/Auth/auth.dart';
import 'package:the_cleaning_ladies/src/Auth/authHandler.dart';
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
        loginAdmin(loggedInAdmin);
      },
      logInClient: (loggedInClient) {
        loginUser(loggedInClient);
      },
      onLoggedOff: () => onLoggedOff,
    );
  }

  void loginAdmin(Admin loggedInAdmin) {
    setState(() {
      admin = loggedInAdmin;

      authStatus = AuthStatus.admin;
    });
  }

  void loginUser(Client loggedInClient) {
    setState(() {
      client = loggedInClient;

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
          onSignInAdmin: (admin) => loginAdmin(admin),
          onSignInClient: (client) => loginUser(client),
          onSignUpTap: onSignUpTap,
        );
        break;
      case AuthStatus.signUp:
        return SignUp(
            onSignInAdmin: (admin) => loginAdmin(admin),
            auth: widget.auth,
            onSignUp: signUpUser,
            onLoginTap: onLoginTap);
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
