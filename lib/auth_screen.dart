import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // دالة الدخول
  void _login() async {
    setState(() => _isLoading = true);
    final user = await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل الدخول: تحققي من الإيميل، الباسورد، أو الاتصال.')),
      );
    }
  }

  // دالة إنشاء حساب
  void _signUp() async {
    setState(() => _isLoading = true);
    final user = await _authService.signUp(_emailController.text.trim(), _passwordController.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إنشاء الحساب: الإيميل مستعمل أو كلمة المرور ضعيفة.')),
      );
    }
  }

  // دالة الدخول بجوجل
  void _googleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _authService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل الدخول بجوجل: تأكدي من SHA-1 أو google-services.json.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('تسجيل الدخول', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Sanchez')),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني', labelStyle: TextStyle(color: Colors.white54)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'كلمة المرور', labelStyle: TextStyle(color: Colors.white54)),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
                          child: const Text('دخول', style: TextStyle(fontFamily: 'Sanchez')),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                          child: const Text('إنشاء حساب', style: TextStyle(fontFamily: 'Sanchez')),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _googleSignIn,
                          icon: const Icon(Icons.login),
                          label: const Text('الدخول باستخدام Google'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}