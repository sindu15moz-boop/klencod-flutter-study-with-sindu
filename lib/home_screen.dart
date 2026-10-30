import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        if (seconds > 0) { setState(() => seconds--); } 
        else {
          _timer?.cancel();
          setState(() => isRunning = false);
          _saveStudyTime();
        }
      });
    }
  }

  void _saveStudyTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('total_study_minutes') ?? 0;
    int studied = (1500 - seconds) ~/ 60;
    await prefs.setInt('total_study_minutes', current + studied);
    
    int newStreak = streak + 1;
    await prefs.setInt('streak', newStreak);
    setState(() => streak = newStreak);
  }

  @override
  void dispose() { _timer?.cancel(); _controller.dispose(); super.dispose(); }

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
                  "مرحباً $_studentName",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Sanchez'),
                ),
                Text(
                  "🔥 $streak",
                  style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'ghost.png',
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