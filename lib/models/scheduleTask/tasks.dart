enum Status { schedule, pending, complete }

class Task {
  String id;
  String message;
  Status status;
  String cellNumber;
  DateTime performAt;
}
