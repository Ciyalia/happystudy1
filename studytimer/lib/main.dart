import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:studytimer/pages/homepage.dart';
import 'package:studytimer/screens/welcome/welcome_screen.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize time zone data
  tzdata.initializeTimeZones();

  // Set local time zone
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/logo');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key})
      : super(key: key); 

  @override
  Widget build(BuildContext context) {
    bool isUserLoggedIn() {
      bool userLoggedIn = false;
      return userLoggedIn;
    }

    return isUserLoggedIn() ? const HomePage() : const WelcomeScreen();
  }
}
