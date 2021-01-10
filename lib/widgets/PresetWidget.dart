import 'package:flutter/material.dart';

class ITextHeading extends StatelessWidget {
  final String text;
  final double fontSize;
  ITextHeading(this.text, {this.fontSize = 20});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }
}
