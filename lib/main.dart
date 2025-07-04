// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_language_interpreter/theme_data.dart';
import 'splash_screen.dart';

void main() {
  runApp(const ArabicSignApp());
}

class ArabicSignApp extends StatelessWidget {
  const ArabicSignApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Arabic Sign Language',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7E22CE),

          brightness: Brightness.light,
        ),
        elevatedButtonTheme: elevatedButtonTheme,
        cardTheme: cardThemeData,
      ),
      home: const SplashScreen(),
    );
  }
}
