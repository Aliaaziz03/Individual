import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:individual1/AppsFlow/Calendar.dart';
import 'package:individual1/AppsFlow/NavigationBar.dart';
import 'package:individual1/AppsFlow/homepage.dart';
import 'package:individual1/authentication/login.dart';
import 'package:individual1/authentication/register.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
try {
  await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyBPnUqwiVM5P6p0wE7I1Uv1IHkFDgrO940',
      appId: '1:784526548407:android:4729c6b167ee7b184bdc32',
      messagingSenderId: '784526548407',
      projectId: 'individualcsc661',
    ),
  );
  
} catch (e) {
  print("Firebase initialization error: $e");
}
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
   const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home:  LoginPage(),
     
    );
  }
}
class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( );

  }
}
