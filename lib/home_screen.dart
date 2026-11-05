import 'package:flutter/material.dart';
import 'focus_timer_screen.dart'; // صفحة الدراسة
import 'posts_screen.dart';      // المجتمع
import 'friends_screen.dart';    // الأصدقاء
import 'chat_screen.dart';       // الدردشة (راح نخلقوها)
import 'settings_screen.dart';   // الإعدادات

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // قائمة الصفحات
  final List<Widget> _screens = [
    const FocusTimerScreen(), // 0: الدراسة
    const PostsScreen(),      // 1: المجتمع
    const FriendsScreen(),    // 2: الأصدقاء
    const ChatScreen(),       // 3: الدردشة
    const SettingsScreen(),   // 4: الإعدادات
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed, // باش يبانو 5 أزرار
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "الدراسة"),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: "المجتمع"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "الأصدقاء"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "الدردشة"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
      ),
    );
  }
}