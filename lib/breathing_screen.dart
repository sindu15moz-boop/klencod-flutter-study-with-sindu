import 'package:flutter/material.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isBreathing = false;
  String _breathText = "ابدأ التنفس";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _breathText = "أخرج الهواء... (زفير)");
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _breathText = "خذ نفس عميق... (شهيق)");
        _controller.forward();
      }
    });
  }

  void _toggleBreathing() {
    setState(() => _isBreathing = !_isBreathing);

    if (_isBreathing) {
      setState(() => _breathText = "خذ نفس عميق... (شهيق)");
      _controller.forward();
    } else {
      _controller.reset();
      setState(() => _breathText = "ابدأ التنفس");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("وقت الاسترخاء", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Sanchez')),
                const SizedBox(height: 60),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isBreathing ? _animation.value : 1.0,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 40, spreadRadius: 20)],
                        ),
                        child: Center(
                          child: Icon(_isBreathing ? Icons.air : Icons.self_improvement, size: 80, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                Text(_breathText, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Sanchez')),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _toggleBreathing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E3192),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(_isBreathing ? "إيقاف" : "ابدأ التنفس", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Sanchez')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}