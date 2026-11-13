import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('معلومات حول التطبيق', style: TextStyle(fontFamily: 'Sanchez')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            // أيقونة التطبيق
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white24,
              child: Icon(Icons.menu_book, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            // اسم التطبيق
            const Text(
              'Study with Sindu',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Sanchez'),
            ),
            const SizedBox(height: 10),
            
            // ⬇️⬇️ الجملة اللي طلبتي ⬇️⬇️
            const Text(
              'تم تصميم الواجهة من طرف: zouzii',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Sanchez'),
            ),
            // ⬆️⬆️ الجملة اللي طلبتي ⬆️⬆️

            const SizedBox(height: 10),
            const Text(
              'نسخة تجريبية',
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // معلومات المطور
            _buildInfoCard('المطور', 'بن مزوز رحاب'),
            _buildInfoCard('البلد', 'الجزائر 🇩🇿'),
            _buildInfoCard('الإصدار', '1.2.2'),
            _buildInfoCard('النوع', 'نسخة تجريبية'),

            const Spacer(),
            const Text(
              'جميع الحقوق محفوظة © 2024',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}