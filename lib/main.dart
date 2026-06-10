import 'package:contact/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'home_screen.dart';

ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en', 'US'));

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Contacts App',
          // How to think about it: These MUST be here for Material widgets (like AppBar) 
          // to work, even if we force the direction to LTR.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'AE'),
            Locale('en', 'US'),
          ],
          locale: locale,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xff111821),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          // This builder forces the app to ALWAYS be LTR so your buttons don't jump.
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            );
          },
          initialRoute: 'splashScreen',
          routes: {
            'splashScreen': (context) => const SplashScreen(),
            'homeScreen': (context) => HomeScreen(),
          },
        );
      },
    );
  }
}
