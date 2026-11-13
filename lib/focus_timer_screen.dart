import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart'; // <--- الفيديو
import 'breathing_screen.dart'; // <--- زر التنفس

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  int selectedMinutes = 80;
  int seconds = 80 * 60;
  bool isRunning = false;
  bool isDeepFocus = false;
  Timer? _timer;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    // تهيئة الفيديو (المسار الصحيح)
    _videoController = VideoPlayerController.asset('assets/background.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.setPlaybackSpeed(0.5); // السرعة البطيئة
        _videoController.play();
        setState(() {});
      });
  }

  void _toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
      setState(() => isRunning = false);
    } else {
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
    final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 60);

    if (image != null) {
      if (!mounted) return;
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref().child('study_proofs/$fileName.jpg');
        await ref.putFile(File(image.path));
        String downloadUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('sessions').add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'proofImage': downloadUrl,
          'date': FieldValue.serverTimestamp(),
          'duration': selectedMinutes,
        });

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

  String get timerText {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5CA87F), Color(0xFFD3EBE0)],
        ),
      ),
      child: Stack(
        children: [
          // 1. الفيديو في الخلفية
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController