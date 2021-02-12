import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';

abstract class ClientsRepository {
  Stream<List<Client>> clients(Admin admin);
  Future<void> addNewClient(Client appointment);
  // Future<void> addNewClientDemo(List<Client> demos);
  Future<void> deleteClient(Client appointment);
  Future<void> updateClient(Client update);
}

class FirebaseClientsRepository implements ClientsRepository {
  final appointmentCollection = FirebaseFirestore.instance.collection('Users');
  EasyDB _easyDb = DataBaseRepo();
  @override
  Future<void> addNewClient(Client client) {
    return _easyDb.createUserData('/Users', client.toDocument(),
        onCreation: (docId) {});
  }

  // Future<void> addNewClientDemo(List<Client> demos) async {
  //   for (var demo in demos) {
  //     await _easyDb.createUserData('/Users', demo.toDocumentDemos());
  //   }
  //   return;
  // }

  @override
  Stream<List<Client>> clients(Admin admin) {
    // List<Client> _clients = [];
    // _clients.clear();
    return appointmentCollection
        .where('businessCode', isEqualTo: '${admin.businessCode}')
        .where('userType', isEqualTo: 'UserType.client')
        // .orderBy('activeForCleaning', descending: true)
        // .orderBy('lastCleaning', descending: true)
        .snapshots()
        .map((snap) {
      List<Client> clients =
          snap.docs.map((doc) => Client.fromDocumentSnap(doc)).toList();
      clients.sort((client1, client2) =>
          client1.lastService.compareTo(client2.lastService));
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
