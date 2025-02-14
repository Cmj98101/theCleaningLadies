import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_cleaning_ladies/src/Auth/auth.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/ClientRepo/clientRepo.dart';
import 'package:the_cleaning_ladies/BLoC/Clients/client_bloc.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/AppointmentRepo/appointmentRepo.dart';
import 'package:the_cleaning_ladies/BLoC/Appointments/appointment_bloc.dart';
import 'package:the_cleaning_ladies/src/screen_manager/screenManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SyncfusionLicense.registerLicense(
  //     "NT8mJyc2IWhia31hfWN9Z2ZoYmF8YGJ8ampqanNiYmlmamlmanMDHmgwOyE6ICc8Izs2IX05JzYwOxM0PjI6P30wPD4=");
  await Firebase.initializeApp(
      // name: 'TCLMAIN',
      // options: FirebaseOptions(
      // databaseURL: 'https://the-cleaning-ladies.firebaseio.com',
      // appId: '1:223702823231:ios:9ba9ab3c6e36c07f8aa38a',
      // googleAppID: '1:223702823231:android:2fda72010ed8abaa8aa38a',
      // apiKey:
      //     'AAAANBW6MT8:APA91bHhguWmmAQswFVwhOjFjCuTL0shvYMw4Tus3XH2mdNBPq7dGQp9loVGIWKA1cSGjVYceQx38gWfk_BJAAbAdJ6iCjUa9C1UXxnKXUAM1gqisLEoP7GQLis-EW7boRTBviogdLol',
      // messagingSenderId: '223702823231',
      // projectId: 'the-cleaning-ladies'),
      );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    const MaterialColor white = const MaterialColor(
      0xFFFFFFFF,
      const <int, Color>{
        50: const Color(0xFFFFFFFF),
        100: const Color(0xFFFFFFFF),
        200: const Color(0xFFFFFFFF),
        300: const Color(0xFFFFFFFF),
        400: const Color(0xFFFFFFFF),
        500: const Color(0xFFFFFFFF),
        600: const Color(0xFFFFFFFF),
        700: const Color(0xFFFFFFFF),
        800: const Color(0xFFFFFFFF),
        900: const Color(0xFFFFFFFF),
      },
    );
    const MaterialColor orange = const MaterialColor(
      0xFFF28921,
      const <int, Color>{
        50: const Color(0xFFF28921),
        100: const Color(0xFFF28921),
        200: const Color(0xFFF28921),
        300: const Color(0xFFF28921),
        400: const Color(0xFFF28921),
        500: const Color(0xFFF28921),
        600: const Color(0xFFF28921),
        700: const Color(0xFFF28921),
        800: const Color(0xFFF28921),
        900: const Color(0xFFF28921),
      },
    );
    return MultiBlocProvider(
        providers: [
          BlocProvider<ClientBloc>(
              create: (context) =>
                  ClientBloc(clientRepository: FirebaseClientsRepository())
              // ..add(LoadClientsEvent()),
              ),
          BlocProvider<AppointmentBloc>(
              create: (context) => AppointmentBloc(
                  appointmentsRepository: FireBaseAppointmentsRepository())
              // ..add(LoadAppointmentsEvent()),
              )
        ],
        child: MaterialApp(
          title: 'The Cleaning Ladies',
          theme: ThemeData(
            primarySwatch: orange,
            // secondaryHeaderColor: Colors.teal,
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(white),
                    backgroundColor: MaterialStateProperty.all<Color>(orange))),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: ScreenManager(auth: ImpAuth()),
        ));
  }
}
