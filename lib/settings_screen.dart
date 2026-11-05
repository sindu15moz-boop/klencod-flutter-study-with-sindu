import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_language.dart';
import 'auth_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLanguage.get('language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('العربية'),
                onTap: () async {
                  await AppLanguage.changeLanguage('ar');
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                title: const Text('Français'),
                onTap: () async {
                  await AppLanguage.changeLanguage('fr');
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () async {
                  await AppLanguage.changeLanguage('en');
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // نافذة التعليقات والمساعدة
  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('التعليقات والمساعدة', style: TextStyle(color: Colors.white, fontFamily: 'Sanchez')),
          content: TextField(
            controller: feedbackController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'اكتب مشكلتك أو اقتراحك هنا...',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (feedbackController.text.isNotEmpty) {
                  // نسجلو التعليق في Firestore
                  await FirebaseFirestore.instance.collection('feedback').add({
                    'userId': FirebaseAuth.instance.currentUser?.uid,
                    'email': FirebaseAuth.instance.currentUser?.email,
                    'text': feedbackController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('شكراً لك! تم إرسال تعليقك.')),
                  );
                }
              },
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(AppLanguage.get('settings'), style: const TextStyle(fontFamily: 'Sanchez')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. معلومات الحساب
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(
                  user?.email ?? 'لا يوجد إيميل',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Sanchez'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // 2. زر تغيير اللغة
          ListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: const Icon(Icons.language, color: Colors.white),
            title: Text(AppLanguage.get('language'), style: const TextStyle(color: Colors.white, fontFamily: 'Sanchez')),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            onTap: _showLanguageDialog,
          ),
          const SizedBox(height: 15),

          // 3. زر معلومات حول التطبيق
          ListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text('معلومات حول التطبيق', style: TextStyle(color: Colors.white, fontFamily: 'Sanchez')),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          const SizedBox(height: 15),

          // 4. زر التعليقات والمساعدة
          ListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: const Icon(Icons.help_outline, color: Colors.white),
            title: const Text('التعليقات والمساعدة', style: TextStyle(color: Colors.white, fontFamily: 'Sanchez')),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            onTap: _showFeedbackDialog,
          ),
          const SizedBox(height: 15),

          // 5. زر تسجيل الخروج
          ListTile(
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(AppLanguage.get('logout'), style: const TextStyle(color: Colors.red, fontFamily: 'Sanchez')),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}