import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_cleaning_ladies/src/Admin/EasyDB/EasyDb.dart';
import 'package:the_cleaning_ladies/src/Client/client.dart';

abstract class ClientsRepository {
  Stream<List<Client>> clients();
  Future<void> addNewClient(Client appointment);
  Future<void> addNewClientDemo(List<Client> demos);
  Future<void> deleteClient(Client appointment);
  Future<void> updateClient(Client update);
}

class FirebaseClientsRepository implements ClientsRepository {
  final appointmentCollection = FirebaseFirestore.instance.collection('Users');
  EasyDB _easyDb = DataBaseRepo();
  @override
  Future<void> addNewClient(Client client) {
    return _easyDb.createUserData('/Users', client.toDocument());
  }

  Future<void> addNewClientDemo(List<Client> demos) async {
    for (var demo in demos) {
      await _easyDb.createUserData('/Users', demo.toDocumentDemos());
    }
    return;
  }

  @override
  Stream<List<Client>> clients() {
    // List<Client> _clients = [];
    // _clients.clear();
    return appointmentCollection
        .where('businessCode', isEqualTo: 'TCL')
        .where('userType', isEqualTo: 'UserType.client')
        // .orderBy('activeForCleaning', descending: true)
        // .orderBy('lastCleaning', descending: true)
        .snapshots()
        .map((snap) {
      List<Client> clients =
          snap.docs.map((doc) => Client.fromQueryDocSnapDocument(doc)).toList();
      clients.sort((client1, client2) =>
          client1.lastCleaning.compareTo(client2.lastCleaning));
      // clients.sort((client1, client2)=> Comparator<bool>(client1.active, client2.active).);

      return clients;
    });
  }

  @override
  Future<void> deleteClient(Client client) {
    return _easyDb.deleteDocFromDB('Users/${client.id}');
  }

  @override
  Future<void> updateClient(Client client) {
    return _easyDb.editDocumentData('Users/${client.id}', client.toDocument());
  }
}
