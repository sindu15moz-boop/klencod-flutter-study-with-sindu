import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: Text('صفحة الدردشة (تحت التطوير)', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}