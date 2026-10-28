
  
      import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const StudyApp());
}

class StudyApp extends StatefulWidget {
  const StudyApp({super.key});
  @override
  State<StudyApp> createState() => _StudyAppState();
}

class _StudyAppState extends State<StudyApp> {
  int themeMode = 0;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      themeMode = prefs.getInt('theme_mode') ?? 0;
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _isLoading = false;
    });
  }

  void changeTheme(int mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode);
    setState(() => themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (themeMode == 0) {
      bgColor = const Color(0xFF121212);
      textColor = Colors.white;
    } else if (themeMode == 1) {
      bgColor = const Color(0xFF424242);
      textColor = Colors.white;
    } else if (themeMode == 2) {
      bgColor = const Color(0xFFE0F7FA);
      textColor = Colors.black;
    } else if (themeMode == 3) {
      bgColor = const Color(0xFFE8F5E9);
      textColor = Colors.black;
    } else {
      bgColor = Colors.white;
      textColor = Colors.black;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        brightness: themeMode >= 2 ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: bgColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: textColor,
            foregroundColor: bgColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(color: textColor.withOpacity(0.3), width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: textColor.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: textColor, width: 1.5)),
          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
          prefixIconColor: textColor.withOpacity(0.7),
        ),
      ),
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (_isLoggedIn
              ? MainAppScreen(themeMode: themeMode, onThemeChange: changeTheme)
              : AuthScreen(themeMode: themeMode, onThemeChange: changeTheme)),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const AuthScreen({super.key, required this.themeMode, required this.onThemeChange});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  void _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_isLogin) {
      String? savedEmail = prefs.getString('user_email');
      String? savedPassword = prefs.getString('user_password');
      if (savedEmail == _emailController.text && savedPassword == _passwordController.text) {
        await prefs.setBool('is_logged_in', true);
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen(themeMode: widget.themeMode, onThemeChange: widget.onThemeChange)));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("البريد الإلكتروني أو كلمة المرور غير صحيحة")));
      }
    } else {
      await prefs.setString('user_email', _emailController.text);
      await prefs.setString('user_password', _passwordController.text);
      await prefs.setBool('is_logged_in', true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إنشاء الحساب بنجاح!")));
        setState(() => _isLogin = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
                child: Icon(Icons.person_outline, size: 60, color: widget.themeMode >= 2 ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 30),
              Text(_isLogin ? "تسجيل الدخول" : "إنشاء حساب", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300, color: textColor)),
              const SizedBox(height: 30),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: "البريد الإلكتروني", prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 15),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "كلمة المرور", prefixIcon: Icon(Icons.lock_outline))),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _submit, child: Text(_isLogin ? "دخول" : "إنشاء حساب", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400))),
              ),
              TextButton(onPressed: () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? "ليس لديك حساب؟ سجل هنا" : "لديك حساب؟ دخل من هنا", style: TextStyle(color: textColor.withOpacity(0.6)))),
            ],
          ),
        ),
      ),
    );
  }
}
class WelcomeScreen extends StatelessWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const WelcomeScreen({super.key, required this.themeMode, required this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    Color textColor = themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories_outlined, size: 80, color: textColor),
              const SizedBox(height: 30),
              Text("أهلاً بك في غرفة الدراسة!", textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300, color: textColor)),
              const SizedBox(height: 20),
              Text("لقد اخترت المكان الصحيح. الدراسة هي مفتاح نجاحك، والنجاح ليس صعباً، بل يحتاج إلى القليل من التنظيم والصبر.\n\nهنا، سنساعدك على التركيز، والاسترخاء، والوصول إلى هدفك.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7), height: 1.6)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LanguageScreen(themeMode: themeMode, onThemeChange: onThemeChange))),
                  child: const Text("هل أنت مستعد للبدء؟", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const LanguageScreen({super.key, required this.themeMode, required this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    Color textColor = themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("اختر اللغة / Choisir la langue", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: textColor)),
              const SizedBox(height: 40),
              _buildLangButton(context, "العربية"),
              const SizedBox(height: 15),
              _buildLangButton(context, "Français"),
              const SizedBox(height: 15),
              _buildLangButton(context, "English"),
              const SizedBox(height: 15),
              _buildLangButton(context, "الدارجة"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String label) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen(themeMode: themeMode, onThemeChange: onThemeChange))),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const ProfileScreen({super.key, required this.themeMode, required this.onThemeChange});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedLevel = "السنة الأولى ثانوي";
  final List<String> _levels = ["السنة الأولى متوسط", "السنة الثانية متوسط", "السنة الثالثة متوسط", "السنة الرابعة متوسط", "السنة الأولى ثانوي", "السنة الثانية ثانوي", "السنة الثالثة ثانوي", "السنة الأولى جامعي", "السنة الثانية جامعي", "السنة الثالثة جامعي"];

  void _saveAndContinue() async {
    if (_nameController.text.trim().isEmpty) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_name', _nameController.text.trim());
    await prefs.setString('student_level', _selectedLevel);
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainAppScreen(themeMode: widget.themeMode, onThemeChange: widget.onThemeChange)));
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: textColor)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text("معلومات الطالب", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: textColor)),
            const SizedBox(height: 30),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "الاسم الكامل", prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(labelText: "المستوى الدراسي", prefixIcon: Icon(Icons.school_outlined)),
              items: _levels.map((String level) => DropdownMenuItem<String>(value: level, child: Text(level, style: TextStyle(color: textColor, fontWeight: FontWeight.w300)))).toList(),
              onChanged: (String? newValue) => setState(() => _selectedLevel = newValue!),
              dropdownColor: widget.themeMode == 0 ? const Color(0xFF1E1E1E) : (widget.themeMode == 1 ? const Color(0xFF616161) : Colors.white),
            ),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveAndContinue, child: const Text("متابعة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)))),
          ],
        ),
      ),
    );
  }
}