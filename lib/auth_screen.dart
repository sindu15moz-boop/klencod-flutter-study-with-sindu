
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  String _getAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح.';

      case 'user-not-found':
        return 'هذا الحساب غير موجود. أنشئي حساباً جديداً.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'الإيميل أو كلمة المرور غير صحيحة.';

      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستعمل من قبل.';

      case 'weak-password':
        return 'كلمة المرور ضعيفة. استعملي 6 أحرف على الأقل.';

      case 'network-request-failed':
        return 'تحققي من اتصال الإنترنت وحاولي مجدداً.';

      case 'too-many-requests':
        return 'محاولات كثيرة. انتظري قليلاً ثم أعيدي المحاولة.';

      case 'operation-not-allowed':
        return 'طريقة تسجيل الدخول غير مفعّلة في Firebase.';

      case 'user-disabled':
        return 'هذا الحساب معطّل.';

      default:
        return 'حدث خطأ: ${e.message ?? e.code}';
    }
  }

  Future<void> _goToHome(User? user) async {
    if (!mounted || user == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  Future<void> _login() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('أدخلي البريد الإلكتروني وكلمة المرور.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signIn(email, password);
      await _goToHome(user);
    } on FirebaseAuthException catch (e) {
      _showMessage(_getAuthError(e));
    } catch (e) {
      _showMessage('تعذّر تسجيل الدخول. تحققي من الإنترنت.');
      print('LOGIN ERROR: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUp() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('أدخلي البريد الإلكتروني وكلمة المرور.');
      return;
    }

    if (password.length < 6) {
      _showMessage('كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signUp(email, password);

      if (user != null) {
        _showMessage('تم إنشاء الحساب بنجاح.');
        await _goToHome(user);
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(_getAuthError(e));
    } catch (e) {
      _showMessage('تعذّر إنشاء الحساب. حاولي مجدداً.');
      print('SIGNUP ERROR: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _googleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        await _goToHome(user);
      } else {
        _showMessage('تم إلغاء تسجيل الدخول بجوجل.');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(_getAuthError(e));
    } catch (e) {
      _showMessage('فشل تسجيل الدخول بجوجل. راجعي إعدادات Google في Firebase.');
      print('GOOGLE ERROR: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Sanchez',
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),

              const SizedBox(height: 30),

              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'دخول',
                        style: TextStyle(fontFamily: 'Sanchez'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'إنشاء حساب',
                        style: TextStyle(fontFamily: 'Sanchez'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: _googleSignIn,
                      icon: const Icon(Icons.login),
                      label: const Text('الدخول باستخدام Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
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
