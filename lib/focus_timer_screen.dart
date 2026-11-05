import 'package:flutter/material.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  int selectedMinutes = 80;
  bool isDeepFocus = false;

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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // الكارد الكبير
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
                      
                      // الوقت
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('$selectedMinutes', style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(width: 8),
                          const Text('دقيقة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // شريط الخطوط (Slider)
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

                      // كارد التركيز العميق
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
              
              // زر البدء
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // كود البدء
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3B2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text('ابدأ التركيز', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}