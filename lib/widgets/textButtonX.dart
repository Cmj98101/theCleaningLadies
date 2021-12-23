import 'package:flutter/material.dart';

class TextButtonX extends StatefulWidget {
  final VoidCallback onPressedX;
  final VoidCallback onLongPressX;
  final Widget childX;
  final Color colorX;
  TextButtonX({this.onPressedX, this.onLongPressX, this.childX, this.colorX});
  @override
  _TextButtonXState createState() => _TextButtonXState();
}

class _TextButtonXState extends State<TextButtonX> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressedX,
      onLongPress: widget.onLongPressX,
      child: widget.childX,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              widget.colorX == null ? null : widget.colorX)),
    );
  }
}
