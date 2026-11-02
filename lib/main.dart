import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_screen.dart';
import 'app_language.dart'; // <--- زدنا هادي باش اللغة تخدم

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AppLanguage.loadLanguage(); // <--- زدنا هادي باش تحمل اللغة
  runApp(const StudyApp());
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(AppLanguage.currentLang), // <--- زدنا هادي باش التطبيق ياخد اللغة
      theme: ThemeData(
        fontFamily: 'Sanchez',
        scaffoldBackgroundColor: const Color(0xFF121212),
        brightness: Brightness.dark,
      ),
      home: const AuthScreen(),
    );
  }
}