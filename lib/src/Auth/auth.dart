import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

abstract class Auth {
  Future<dynamic> getCurrentUser(Function(dynamic) onUser);
  Future<User> signInWithEmailAndPassword(String email, String password,
      {@required Function(FirebaseAuthException) onError});
  Future<User> createUser(String email, String password);
  Future<User> createUserFromAdminAccount(String email, String password);
  void signOutUser();
}

class ImpAuth extends Auth {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<dynamic> getCurrentUser(Function(dynamic) onUser) async {
    return await onUser(_auth.currentUser);
  }

  Future<User> signInWithEmailAndPassword(String email, String password,
      {@required Function(FirebaseAuthException) onError}) async {
    UserCredential userCredential;
    userCredential = await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((e) => onError(e));

    return userCredential?.user ?? null;
  }

  Future<User> createUser(String email, String password) async {
    UserCredential userCredential;

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .catchError((e) => print(e));
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print('from default catch ${e.code}');
    }
    return userCredential.user;
  }

  Future<User> createUserFromAdminAccount(String email, String password) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    await FirebaseAuth.instanceFor(app: app)
        .createUserWithEmailAndPassword(email: email, password: password);
    User user =
        await FirebaseAuth.instanceFor(app: app).authStateChanges().first;
    return user;
  }

  void signOutUser() async {
    return await _auth.signOut();
  }
}
