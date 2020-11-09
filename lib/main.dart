import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_cleaning_ladies/src/Auth/auth.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/ClientRepo/clientRepo.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_bloc.dart';
import 'src/ScreenManager/screenManager.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/AppointmentRepo/appointmentRepo.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/appointment_bloc.dart';
import 'package:the_cleaning_ladies/src/BLoC/Appointments/appointment_event.dart';
import 'package:the_cleaning_ladies/src/BLoC/Clients/client_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SyncfusionLicense.registerLicense(
  //     "NT8mJyc2IWhia31hfWN9Z2ZoYmF8YGJ8ampqanNiYmlmamlmanMDHmgwOyE6ICc8Izs2IX05JzYwOxM0PjI6P30wPD4=");
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<ClientBloc>(
            create: (context) =>
                ClientBloc(clientRepository: FirebaseClientsRepository())
                  ..add(LoadClientsEvent()),
          ),
          BlocProvider<AppointmentBloc>(
            create: (context) => AppointmentBloc(
                appointmentsRepository: FireBaseAppointmentsRepository())
              ..add(LoadAppointmentsEvent()),
          )
        ],
        child: MaterialApp(
          title: 'The Cleaning Ladies',
          theme: ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: ScreenManager(auth: ImpAuth()),
        ));
  }
}
