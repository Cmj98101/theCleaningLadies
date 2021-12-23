import 'package:flutter/material.dart';

class ElapsedTime {
  int days;
  int hour;
  int min;
  ElapsedTime({this.days, @required this.hour, @required this.min});
  int get totalInMin => ((hour * 60) + min);

  Map<String, Object> toDocument() {
    return {'days': days ?? 0, 'hour': hour ?? 0, 'min': min ?? 0};
  }
}
