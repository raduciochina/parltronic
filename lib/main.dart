import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:parktronic/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parktronic/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parktronic',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // home: const LoginScreen(),
      home: AnimatedSplashScreen(
        splash: 'assets/logo.png',
        nextScreen: LoginScreen(),
        splashTransition: SplashTransition.fadeTransition,
        splashIconSize: double.maxFinite,
        duration: 1650,
      ),
    );
  }
}
