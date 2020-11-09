import 'package:the_cleaning_ladies/src/Client/client.dart';

class ClientState {
  ClientState(); 
}
class ClientLoading extends ClientState {}
class ClientLoaded extends ClientState {
  final List<Client> clients;

  ClientLoaded([this.clients = const <Client>[]]);


  @override
  String toString() => 'clientsLoaded { clients: $clients }';
}