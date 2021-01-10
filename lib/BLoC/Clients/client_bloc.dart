import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/ClientRepo/clientRepo.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client.state.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client_event.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientsRepository _clientRepository;

  StreamSubscription _clientSubscription;
  ClientState get initialState => ClientLoading();
  ClientBloc({@required ClientsRepository clientRepository})
      : assert(clientRepository != null),
        _clientRepository = clientRepository,
        super(null);
  @override
  Stream<ClientState> mapEventToState(ClientEvent event) async* {
    if (event is LoadClientsEvent) {
      yield* _loadClientsToState(event);
    } else if (event is AddClientEvent) {
      yield* _mapAddClientToState(event);
    } else if (event is UpdateClientEvent) {
      yield* _mapUpdateClientToState(event);
    } else if (event is DeleteClientEvent) {
      yield* _mapDeleteClientToState(event);
    } else if (event is ClientUpdatedEvent) {
      yield* _mapClientUpdateToState(event);
    } // else if (event is AddDemoClientsEvent) {
    //   yield* _mapAddDemoClientToState(event);
    // }
  }

  Stream<ClientState> _loadClientsToState(LoadClientsEvent event) async* {
    _clientSubscription?.cancel();
    _clientSubscription = _clientRepository.clients(event.admin).listen(
          (clients) => add(ClientUpdatedEvent(clients)),
        );
  }

  Stream<ClientState> _mapAddClientToState(AddClientEvent event) async* {
    _clientRepository.addNewClient(event.client);
  }

  // Stream<ClientState> _mapAddDemoClientToState(
  //     AddDemoClientsEvent event) async* {
  //   _clientRepository.addNewClientDemo(event.clients);
  // }

  Stream<ClientState> _mapUpdateClientToState(UpdateClientEvent event) async* {
    _clientRepository.updateClient(event.client);
  }

  Stream<ClientState> _mapDeleteClientToState(DeleteClientEvent event) async* {
    _clientRepository.deleteClient(event.client);
  }

  Stream<ClientState> _mapClientUpdateToState(ClientUpdatedEvent event) async* {
    yield ClientLoaded(event.clients);
  }

  @override
  Future<void> close() {
    _clientSubscription?.cancel();
    return super.close();
  }
}
