import 'package:flutter/material.dart';

class FormValidation {
  final GlobalKey<FormState> key;
  Function() onSuccessFullValidation;
  Function() unSuccessFullValidation;

  FormValidation(
    this.key, {
    @required this.onSuccessFullValidation,
    @required this.unSuccessFullValidation,
  });

  bool validateAndSaveForm() {
    var form = key.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submitForm() => validateAndSaveForm()
      ? onSuccessFullValidation()
      : unSuccessFullValidation();
}
