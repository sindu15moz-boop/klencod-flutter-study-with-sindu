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
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : Container(color: Colors.black),
          ),

          // 2. الواجهة فوق الفيديو
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // زر التنفس
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.self_improvement, color: Color(0xFF1E3B2C), size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BreathingScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        children: [
                          const Text('المؤقت', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3B2C))),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(timerText, style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(width: 8),
                              const Text('دقيقة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(13, (index) {
                                bool isCenter = index == 6;
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 3,
                                  height: isCenter ? 25 : 12,
                                  color: isCenter ? Colors.black87 : Colors.black26,
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C9A82).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('تركيز عميق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Text('أثناء التركيز، يمكنك استخدام التطبيقات الموجودة في قائمة السماح فقط.', style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6))),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isDeepFocus,
                                  onChanged: (val) => setState(() => isDeepFocus = val),
                                  activeColor: const Color(0xFF1E3B2C),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _toggleTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E3B2C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: Text(
                        isRunning ? 'إيقاف' : 'ابدأ التركيز',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}