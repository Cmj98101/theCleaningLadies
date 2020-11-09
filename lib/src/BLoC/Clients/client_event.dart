import 'package:the_cleaning_ladies/src/Client/client.dart';

abstract class ClientEvent {}

class LoadClientsEvent extends ClientEvent {}

class AddClientEvent extends ClientEvent {
  final Client client;

  AddClientEvent(this.client);
}

class UpdateClientEvent extends ClientEvent {
  final Client client;

  UpdateClientEvent(this.client);
}

class ClientUpdatedEvent extends ClientEvent {
  final List<Client> clients;

  ClientUpdatedEvent(this.clients);
}

class DeleteClientEvent extends ClientEvent {
  final Client client;

  DeleteClientEvent(this.client);
}

class AddDemoClientsEvent extends ClientEvent {
  final List<Client> clients;

  AddDemoClientsEvent(this.clients);
}
