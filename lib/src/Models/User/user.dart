enum UserType { admin, client }

class User {
  String firstName;
  String lastName;
  String email;
  String password;
  String id;
  String relation;
  UserType userType;

  User(
      {this.firstName,
      this.lastName,
      this.email,
      this.password,
      this.id,
      this.userType});
  User.family({
    this.firstName,
    this.lastName,
    this.relation,
  });
}
