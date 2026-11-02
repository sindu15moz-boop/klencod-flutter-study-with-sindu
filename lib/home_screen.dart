import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_language.dart';
import 'settings_screen.dart'; // <--- زدنا هادي باش يخدم زر الإعدادات
import 'posts_screen.dart';
import 'friends_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int seconds = 1500;
  bool isRunning = false;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _animation;
  String _studentName = "";
  int streak = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _animation = Tween<double>(begin: -5, end: 5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentName = prefs.getString('student_name') ?? "طالب";
      streak = prefs.getInt('streak') ?? 0;
    });
  }

  String get timerText {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _setTime(int minutes) {
    if (!isRunning) {
      setState(() {
        seconds = minutes * 60;
      });
    }
  }

  void _toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
      setState(() => isRunning = false);
    } else {
      if (seconds == 0) return;
      setState(() => isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (seconds > 0) { 
          setState(() => seconds--); 
        } else {
          _timer?.cancel();
          setState(() => isRunning = false);
          _showProofDialog();
        }
      });
    }
  }

  // نافذة اختيار اللغة
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

  void _showProofDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text('خلص الوقت!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontFamily: 'Sanchez')),
        content: const Text('لازم تصور درسك باش تثبت بلي كنت تقرا.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontFamily: 'Sanchez')),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _takePicture();
            },
            child: const Text('تصوير الدرس', style: TextStyle(fontFamily: 'Sanchez')),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );

    if (image != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref().child('study_proofs/$fileName.jpg');
        await ref.putFile(File(image.path));
        String downloadUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('sessions').add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'proofImage': downloadUrl,
          'date': FieldValue.serverTimestamp(),
          'duration': (1500 - seconds) ~/ 60, 
        });

        _saveStudyTime();

        if (!mounted) return;
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تسجيل جلستك بنجاح! 🎉", style: TextStyle(fontFamily: 'Sanchez'))),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e", style: TextStyle(fontFamily: 'Sanchez'))),
        );
      }
    } else {
      _showProofDialog();
    }
  }

  void _saveStudyTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('total_study_minutes') ?? 0;
    int studied = (1500 - seconds) ~/ 60;
    await prefs.setInt('total_study_minutes', current + studied);

    int newStreak = streak + 1;
    await prefs.setInt('streak', newStreak);
    if (mounted) {
      setState(() => streak = newStreak);
    }
  }

  @override
  void dispose() { 
    _timer?.cancel(); 
    _controller.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildTimerScreen(),
      const PostsScreen(),
      const FriendsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: "المجتمع"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "الأصدقاء"),
        ],
      ),
    );
  }

  Widget _buildTimerScreen() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${AppLanguage.get('welcome')} $_studentName",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Sanchez'),
                ),
                Row(
                  children: [
                    Text(
                      "🔥 $streak",
                      style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    // زر اللغة
                    IconButton(
                      icon: const Icon(Icons.language, color: Colors.white),
                      onPressed: _showLanguageDialog,
                    ),
                    // زر الإعدادات
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/ghost.png',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.black12),
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timerText,
                        style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w300, color: Colors.white, fontFamily: 'Sanchez'),
                      ),
                      const SizedBox(height: 20),
                      if (!isRunning)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCircleTimeButton(15),
                            _buildCircleTimeButton(25),
                            _buildCircleTimeButton(45),
                            _buildCircleTimeButton(60),
                          ],
                        ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(25),
                        ),
                        onPressed: _toggleTimer, 
                        child: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 40),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleTimeButton(int minutes) {
    bool isSelected = seconds == minutes * 60;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => _setTime(minutes),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          child: Text(
            "$minutes",
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sanchez',
            ),
          ),
        ),
      ),
    );
  }
}