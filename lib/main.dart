import 'package:contact/splash_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff111821),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: 'splashScreen',
      routes: {
        'splashScreen': (context) => const SplashScreen(),
        'homeScreen': (context) =>  HomeScreen()},
    );
  }
}