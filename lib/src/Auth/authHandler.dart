import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/src/Admin/admin.dart';
import 'package:the_cleaning_ladies/src/Auth/auth.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';
import 'package:the_cleaning_ladies/src/ErrorHandlers/errorHandlers.dart';
import 'package:the_cleaning_ladies/src/Models/User/user.dart' as modelUser;

class HandleAuth {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  GlobalKey<FormState> formKey;
  Auth auth = ImpAuth();
  String email;
  String password;

  Function(bool) isLoading;
  Function(Admin) logInAdmin;
  Function(Client) logInClient;
  Function() onLoggedOff;
  Function(String) onErrorMsg;
  HandleAuth.logOut(BuildContext context,
      {@required this.onLoggedOff, @required this.isLoading}) {
    isLoading(true);
    auth.signOutUser();
    onLoggedOff();
    isLoading(false);
  }
  HandleAuth.login(BuildContext context,
      {@required this.email,
      @required this.password,
      @required this.isLoading,
      @required this.logInAdmin,
      @required this.logInClient,
      @required this.formKey,
      @required this.onErrorMsg}) {
    processSignIn(context, isLoading);
  }
  HandleAuth.getCurrentUser(
    BuildContext context, {
    @required this.logInAdmin,
    @required this.logInClient,
    @required this.onLoggedOff,
  }) {
    auth.getCurrentUser((user) async {
      if (user == null) {
        return onLoggedOff;
      }
      DocumentSnapshot snap = await getUserFromDb(user);
      modelUser.UserType userType;

      if (snap.exists) {
        Map<String, dynamic> data = snap.data();
        userType = userTypes['${data['userType']}'];
        userType == modelUser.UserType.admin
            ? logInAdmin(Admin.fromDocument(snap))
            : logInClient(Client.fromDocSnapDocument(snap));
      }
    });
  }
  Map<String, modelUser.UserType> userTypes = {
    'UserType.admin': modelUser.UserType.admin,
    'UserType.client': modelUser.UserType.client
  };

  Future<DocumentSnapshot> getUserFromDb(User user) async =>
      await _db.doc('Users/${user.uid}').get();

  Future<void> signInUser(User user) async {
    DocumentSnapshot snap = await getUserFromDb(user);
    modelUser.UserType userType;
    if (snap.exists) {
      Map<String, dynamic> data = snap.data();
      userType = userTypes['${data['userType']}'];
      userType == modelUser.UserType.admin
          ? logInAdmin(Admin.fromDocument(snap))
          : logInClient(Client.fromDocSnapDocument(snap));
    } else {
      throw DocumentDoesNotExist(message: 'User does Not Exist In DB');
    }
  }

  void processSignIn(BuildContext context, Function(bool) isLoading) async {
    if (validateAndSave()) {
      isLoading(true);
      User user =
          await auth.signInWithEmailAndPassword(email, password, onError: (e) {
        print(e.code);
        return onErrorMsg(LoginErrorHandler(e.code).friendlyErrorMessage);
      });
      if (user != null) {
        await signInUser(user);
      }
      isLoading(false);
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
