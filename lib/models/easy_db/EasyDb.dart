import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/user.dart';

abstract class EasyDB {
  Future<void> createUserData(String path, Map<String, dynamic> data,
      {bool createAutoId = true,
      bool addAutoIDToDoc = true,
      bool duplicateDoc = false,
      List<String> duplicatedCollectionPath,
      List<Map<String, Object>> duplicatedData,
      @required Function(String) onCreation});
  Future<DocumentSnapshot> getUserData(String documentPath);
  Future<void> editDocumentData(String pathTo, Map<String, dynamic> data);
  void deleteAppointmentDemos(Admin admin);
  Future<void> deleteDemos();
  Future<void> deleteDocFromDB(String pathToDoc,
      {List<String> pathToDocCollections, bool areCollectionsInside = false});
}

class DataBaseRepo implements EasyDB {
  var _db = FirebaseFirestore.instance;

  /// Adds a new document to the collection path with [data] and auto generated Id by default
  /// if [createAutoId] is false then make sure to include your set [id] in path string
  Future<void> createUserData(String path, Map<String, dynamic> data,
      {bool createAutoId = true,
      bool addAutoIDToDoc = true,
      bool duplicateDoc = false,
      List<String> duplicatedCollectionPath,
      List<Map<String, Object>> duplicatedData,
      @required Function(String) onCreation}) async {
    try {
      if (createAutoId) {
        return _db.collection(path).add(data).then((ref) async {
          if (duplicateDoc) {
            for (var i = 0; i < duplicatedCollectionPath.length; i++) {
              await _db
                  .doc('${duplicatedCollectionPath[i]}/${ref.id}')
                  .set(duplicatedData[i].isEmpty ? {} : duplicatedData[i])
                  .onError((error, stackTrace) =>
                      throw ('Error creating Duplicate data! check EasyDB'))
                  .catchError(() async {
                return await _db.collection('Log').add({
                  'path': '${duplicatedCollectionPath[i]}/${ref.id}',
                  'dupData': duplicatedData[i].isEmpty ? {} : duplicatedData[i]
                });
              });
            }
          }
          if (addAutoIDToDoc) {
            return await ref.update({'id': ref.id});
          }
          onCreation(ref.id);
        });
      } else {
        return await _db.doc(path).set(data);
      }
    } catch (e) {
      print('Error adding Data $e');
    }
  }

  Future<DocumentSnapshot> getUserData(String documentPath) async {
    return await _db.doc(documentPath).get();
  }

  Future<void> editDocumentData(
    String pathTo,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.doc('$pathTo').update(data);
    } catch (error) {
      print('ERROR editing document data: $error');
    }
  }

  Future<void> deleteUserFromAuth(User user) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    await auth.FirebaseAuth.instanceFor(app: app)
        .signInWithEmailAndPassword(email: user.email, password: user.password);
    auth.User loggedInUser =
        await auth.FirebaseAuth.instanceFor(app: app).authStateChanges().first;
    loggedInUser.delete();
  }

  Future<void> deleteDocFromDB(String pathToDoc,
      {List<String> pathToDocCollections,
      bool areCollectionsInside = false}) async {
    if (areCollectionsInside) {
      if (pathToDocCollections.isNotEmpty) {
        for (String path in pathToDocCollections) {
          _db.collection('$path').get().then((snapshot) {
            for (DocumentSnapshot doc in snapshot.docs) {
              doc.reference.delete();
            }
          });
        }
      }
    }
    if (pathToDoc.isNotEmpty) {
      await _db.doc('$pathToDoc').delete();
    } else {
      print('Cannot delete empty path');
    }
  }

  void deleteAppointmentDemos(Admin admin) {
    _db.collection('Users/${admin.id}/Appointments').get().then((snap) {
      snap.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
  }

  Future<void> deleteDemos() async {
    await _db.collection('Users').get().then((snap) {
      snap.docs.forEach((doc) async {
        await doc.reference.delete();
      });
    });
  }
}
