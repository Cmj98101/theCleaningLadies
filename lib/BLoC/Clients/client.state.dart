import 'package:the_cleaning_ladies/models/user_models/client.dart';

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
