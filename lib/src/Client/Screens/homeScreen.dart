import 'package:flutter/material.dart';

class ClientHomeScreen extends StatefulWidget {
  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Text('Client Screen'),
      ),
    );
  }
}
