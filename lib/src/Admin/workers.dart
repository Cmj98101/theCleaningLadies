
import 'package:flutter/material.dart';


enum Position {driver, nonDriver}


class Group {
  List<Worker> groupOfWorkers =[];
  Group(this.groupOfWorkers);
}
class Worker {
  String firstName;
  String lastName;
  Position position;
  Worker({@required this.firstName, @required this.lastName, @required this.position});
}