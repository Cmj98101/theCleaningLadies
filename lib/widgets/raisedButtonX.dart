import 'package:flutter/material.dart';

class ElevatedButtonX extends StatefulWidget {
  final VoidCallback onPressedX;
  final VoidCallback onLongPressX;
  final Widget childX;
  final Color colorX;
  final double elevationX;
  final ShapeBorder shapeX;
  ElevatedButtonX(
      {this.onPressedX,
      this.onLongPressX,
      this.childX,
      this.colorX,
      this.elevationX,
      this.shapeX});
  @override
  _ElevatedButtonXState createState() => _ElevatedButtonXState();
}

class _ElevatedButtonXState extends State<ElevatedButtonX> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressedX,
      onLongPress: widget.onLongPressX,
      child: widget.childX,
      style: ButtonStyle(
          shape: MaterialStateProperty.all<OutlinedBorder>(widget.shapeX),
          elevation: MaterialStateProperty.all<double>(
              widget.elevationX == null ? null : widget.elevationX),
          backgroundColor: MaterialStateProperty.all<Color>(
              widget.colorX == null ? null : widget.colorX)),
    );
  }
}
