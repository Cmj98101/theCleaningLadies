import 'package:flutter/material.dart';

class LoginErrorHandler {
  final String errorCode;
  String friendlyErrorMessage;
  LoginErrorHandler(this.errorCode) {
    handleError(errorCode);
  }

  /// Handles Errors from Firestore SignIn
  void handleError(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        friendlyErrorMessage = 'Invalid Email!';
        break;
      case 'wrong-password':
        friendlyErrorMessage = 'Invalid Password!';
        break;
      case 'user-not-found':
        friendlyErrorMessage = 'An account was not found under that email!';
        break;
      case 'user-disabled':
        friendlyErrorMessage = 'Account is Disabled!';
        break;
      case 'ERROR_TOO_MANY_REQUESTS':
        friendlyErrorMessage =
            'Too many attempts to login. Please try again later.';
        break;
      case 'ERROR_OPERATION_NOT_ALLOWED':
        friendlyErrorMessage = 'You can not Sign In using this method';
        break;
      case 'ERROR_NETWORK_REQUEST_FAILED':
        friendlyErrorMessage =
            'Looks like you are not connected to the internet';
        break;
      default:
        friendlyErrorMessage =
            'There has been an error on signing in please try again later.';
    }
  }
}

abstract class AbstractUFM {
  void showAlertDialog(BuildContext context);
}

class UserFriendlyMessages implements AbstractUFM {
  String title;
  String content;
  String confirmButtonTitle;
  VoidCallback onConfirm;
  BuildContext context;
  UserFriendlyMessages(
      this.title, this.content, this.confirmButtonTitle, this.onConfirm);
  UserFriendlyMessages.loading(this.context) {
    showLoadingPopUp(context);
  }
  void showLoadingPopUp(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
                height: 200,
                child: Center(
                    child: SizedBox(
                  child: CircularProgressIndicator(),
                  width: 50,
                  height: 50,
                )))));
  }

  void showAlertDialog(BuildContext context) {
    // return object of type Dialog
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: Text(
                content,
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                RaisedButton(
                    elevation: 5,
                    child: Text(
                      confirmButtonTitle,
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.red,
                    onPressed: onConfirm),
              ],
            ));
  }
}

class ErrorMessage {
  final String message;

  ErrorMessage({this.message});
}

class FailedToGetCurrentUser extends ErrorMessage {
  FailedToGetCurrentUser({String message}) : super(message: message);
}

class DocumentDoesNotExist extends ErrorMessage {
  DocumentDoesNotExist({String message}) : super(message: message);
}

class CreateUserFailed extends ErrorMessage {
  CreateUserFailed({String message}) : super(message: message);
}

class UserInfoNull extends ErrorMessage {
  UserInfoNull({String message}) : super(message: message);
}

class CreateUserError extends ErrorMessage {
  CreateUserError({String message}) : super(message: message);
}

class DeleteUserError extends ErrorMessage {
  DeleteUserError({String message}) : super(message: message);
}

class FieldFoundOnNull {
  var field;
  FieldFoundOnNull(this.field);
  String message() => '$field was found to be null';
}
