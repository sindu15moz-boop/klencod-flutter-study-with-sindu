import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const StudyApp());
}

class StudyApp extends StatefulWidget {
  const StudyApp({super.key});
  @override
  State<StudyApp> createState() => _StudyAppState();
}

class _StudyAppState extends State<StudyApp> {
  int themeMode = 0;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      themeMode = prefs.getInt('theme_mode') ?? 0;
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _isLoading = false;
    });
  }

  void changeTheme(int mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode);
    setState(() => themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (themeMode == 0) {
      bgColor = const Color(0xFF121212);
      textColor = Colors.white;
    } else if (themeMode == 1) {
      bgColor = const Color(0xFF424242);
      textColor = Colors.white;
    } else if (themeMode == 2) {
      bgColor = const Color(0xFFE0F7FA);
      textColor = Colors.black;
    } else if (themeMode == 3) {
      bgColor = const Color(0xFFE8F5E9);
      textColor = Colors.black;
    } else {
      bgColor = Colors.white;
      textColor = Colors.black;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        brightness: themeMode >= 2 ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: bgColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: textColor,
            foregroundColor: bgColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(color: textColor.withOpacity(0.3), width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: textColor.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: textColor, width: 1.5)),
          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
          prefixIconColor: textColor.withOpacity(0.7),
        ),
      ),
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (_isLoggedIn
              ? MainAppScreen(themeMode: themeMode, onThemeChange: changeTheme)
              : AuthScreen(themeMode: themeMode, onThemeChange: changeTheme)),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const AuthScreen({super.key, required this.themeMode, required this.onThemeChange});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  void _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_isLogin) {
      String? savedEmail = prefs.getString('user_email');
      String? savedPassword = prefs.getString('user_password');
      if (savedEmail == _emailController.text && savedPassword == _passwordController.text) {
        await prefs.setBool('is_logged_in', true);
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen(themeMode: widget.themeMode, onThemeChange: widget.onThemeChange)));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("البريد الإلكتروني أو كلمة المرور غير صحيحة")));
      }
    } else {
      await prefs.setString('user_email', _emailController.text);
      await prefs.setString('user_password', _passwordController.text);
      await prefs.setBool('is_logged_in', true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إنشاء الحساب بنجاح!")));
        setState(() => _isLogin = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
                child: Icon(Icons.person_outline, size: 60, color: widget.themeMode >= 2 ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 30),
              Text(_isLogin ? "تسجيل الدخول" : "إنشاء حساب", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300, color: textColor)),
              const SizedBox(height: 30),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: "البريد الإلكتروني", prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 15),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "كلمة المرور", prefixIcon: Icon(Icons.lock_outline))),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _submit, child: Text(_isLogin ? "دخول" : "إنشاء حساب", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400))),
              ),
              TextButton(onPressed: () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? "ليس لديك حساب؟ سجل هنا" : "لديك حساب؟ دخل من هنا", style: TextStyle(color: textColor.withOpacity(0.6)))),
            ],
          ),
        ),
      ),
    );
  }
}
class WelcomeScreen extends StatelessWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const WelcomeScreen({super.key, required this.themeMode, required this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    Color textColor = themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories_outlined, size: 80, color: textColor),
              const SizedBox(height: 30),
              Text("أهلاً بك في غرفة الدراسة!", textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300, color: textColor)),
              const SizedBox(height: 20),
              Text("لقد اخترت المكان الصحيح. الدراسة هي مفتاح نجاحك، والنجاح ليس صعباً، بل يحتاج إلى القليل من التنظيم والصبر.\n\nهنا، سنساعدك على التركيز، والاسترخاء، والوصول إلى هدفك.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7), height: 1.6)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LanguageScreen(themeMode: themeMode, onThemeChange: onThemeChange))),
                  child: const Text("هل أنت مستعد للبدء؟", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const LanguageScreen({super.key, required this.themeMode, required this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    Color textColor = themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("اختر اللغة / Choisir la langue", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: textColor)),
              const SizedBox(height: 40),
              _buildLangButton(context, "العربية"),
              const SizedBox(height: 15),
              _buildLangButton(context, "Français"),
              const SizedBox(height: 15),
              _buildLangButton(context, "English"),
              const SizedBox(height: 15),
              _buildLangButton(context, "الدارجة"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String label) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen(themeMode: themeMode, onThemeChange: onThemeChange))),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const ProfileScreen({super.key, required this.themeMode, required this.onThemeChange});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedLevel = "السنة الأولى ثانوي";
  final List<String> _levels = ["السنة الأولى متوسط", "السنة الثانية متوسط", "السنة الثالثة متوسط", "السنة الرابعة متوسط", "السنة الأولى ثانوي", "السنة الثانية ثانوي", "السنة الثالثة ثانوي", "السنة الأولى جامعي", "السنة الثانية جامعي", "السنة الثالثة جامعي"];

  void _saveAndContinue() async {
    if (_nameController.text.trim().isEmpty) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_name', _nameController.text.trim());
    await prefs.setString('student_level', _selectedLevel);
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainAppScreen(themeMode: widget.themeMode, onThemeChange: widget.onThemeChange)));
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: textColor)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text("معلومات الطالب", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: textColor)),
            const SizedBox(height: 30),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "الاسم الكامل", prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(labelText: "المستوى الدراسي", prefixIcon: Icon(Icons.school_outlined)),
              items: _levels.map((String level) => DropdownMenuItem<String>(value: level, child: Text(level, style: TextStyle(color: textColor, fontWeight: FontWeight.w300)))).toList(),
              onChanged: (String? newValue) => setState(() => _selectedLevel = newValue!),
              dropdownColor: widget.themeMode == 0 ? const Color(0xFF1E1E1E) : (widget.themeMode == 1 ? const Color(0xFF616161) : Colors.white),
            ),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveAndContinue, child: const Text("متابعة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)))),
          ],
        ),
      ),
    );
  }
}
class MainAppScreen extends StatefulWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const MainAppScreen({super.key, required this.themeMode, required this.onThemeChange});
  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    Color navBg = widget.themeMode == 0 ? const Color(0xFF121212) : (widget.themeMode == 1 ? const Color(0xFF424242) : (widget.themeMode == 2 ? const Color(0xFFE0F7FA) : (widget.themeMode == 3 ? const Color(0xFFE8F5E9) : Colors.white)));

    final screens = [
      RoomScreen(themeMode: widget.themeMode, onThemeChange: widget.onThemeChange),
      SoundScreen(themeMode: widget.themeMode),
      SettingsScreen(themeMode: widget.themeMode, onThemeChange: widget.onThemeChange),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: navBg,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: textColor,
        unselectedItemColor: textColor.withOpacity(0.4),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), activeIcon: Icon(Icons.timer), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.music_note_outlined), activeIcon: Icon(Icons.music_note), label: "الأصوات"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: "الإعدادات"),
        ],
      ),
    );
  }
}

class RoomScreen extends StatefulWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const RoomScreen({super.key, required this.themeMode, required this.onThemeChange});
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with SingleTickerProviderStateMixin {
  int seconds = 1500;
  bool isRunning = false;
  bool isBreak = false;
  bool isFocusMode = false;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _animation;
  String _studentName = "";
  int streak = 0;

  final List<String> _motivations = [
    "أحسنت! لقد قطعت شوطاً كبيراً اليوم.",
    "استمر، فكل دقيقة تقربك من هدفك.",
    "أنت تبني مستقبلك الآن، لا تتوقف!",
    "رائع! لقد أثبتت أنك قادر على التركيز.",
    "العلم نور، وأنت اليوم تزداد نوراً.",
    "تعب اليوم هو راحة الغد، واصل التقدم.",
    "أنت أقوى من التحديات، استمر في القراءة.",
    "خطوة بخطوة، تصل إلى القمة.",
    "اجعل من دراستك عادة، ومن النجاح نتيجة.",
    "لا شيء مستحيل أمام الإصرار والعزيمة."
  ];

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
        isBreak = false;
      });
    }
  }

  void _startBreak(int minutes) {
    setState(() {
      seconds = minutes * 60;
      isBreak = true;
      isRunning = false;
    });
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
          if (isBreak) {
            _showBreakEndDialog();
          } else {
            _saveStudyTime();
            _showRelaxationDialog();
          }
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

  void _showRelaxationDialog() {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    String randomMotivation = _motivations[Random().nextInt(_motivations.length)];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: widget.themeMode == 0 ? const Color(0xFF1E1E1E) : (widget.themeMode == 1 ? const Color(0xFF616161) : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text('أحسنت!', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w300)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(randomMotivation, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('اختر مدة الراحة التي تناسبك:', textAlign: TextAlign.center, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16)),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Wrap(
            spacing: 10,
            children: [
              _buildBreakButton(5, textColor),
              _buildBreakButton(10, textColor),
              _buildBreakButton(15, textColor),
              _buildBreakButton(20, textColor),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: textColor.withOpacity(0.3), width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('تخطي الراحة', style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w300)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakButton(int minutes, Color textColor) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: textColor.withOpacity(0.3), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      onPressed: () {
        Navigator.pop(context);
        _startBreak(minutes);
      },
      child: Text("$minutes د", style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8), fontWeight: FontWeight.w300)),
    );
  }

  void _showBreakEndDialog() {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: widget.themeMode == 0 ? const Color(0xFF1E1E1E) : (widget.themeMode == 1 ? const Color(0xFF616161) : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text('خلصت الراحة!', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w300)),
        content: Text('أتمنى أنك ارتحت. يالاه نعاودو نقراو ونركزو!', textAlign: TextAlign.center, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor,
              foregroundColor: widget.themeMode >= 2 ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                seconds = 1500;
                isBreak = false;
              });
            },
            child: const Text('العودة للدراسة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { _timer?.cancel(); _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      appBar: isFocusMode ? null : AppBar(
        title: Text(isBreak ? "وقت الراحة" : "مرحباً $_studentName", style: TextStyle(color: textColor, fontWeight: FontWeight.w300)), 
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Center(
              child: Text("🔥 $streak", style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'ghost.png',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.black12),
            ),
          ),
          Positioned.fill(
            child: Container(color: isFocusMode ? Colors.black.withOpacity(0.8) : Colors.black.withOpacity(0.3)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isFocusMode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      "راك في وضع التركيز... ركز في القراية!",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                
                Text(
                  timerText,
                  style: TextStyle(fontSize: 80, fontWeight: FontWeight.w300, color: Colors.white, letterSpacing: 2),
                ),
                const SizedBox(height: 20),
                
                if (!isRunning && !isBreak && !isFocusMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircleTimeButton(15, textColor),
                      _buildCircleTimeButton(25, textColor),
                      _buildCircleTimeButton(45, textColor),
                      _buildCircleTimeButton(60, textColor),
                    ],
                  ),
                
                const SizedBox(height: 30),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(25),
                    elevation: 5,
                  ),
                  onPressed: _toggleTimer, 
                  child: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 40),
                ),
                
                const SizedBox(height: 30),
                
                if (!isFocusMode) ...[
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BreathingScreen(themeMode: widget.themeMode)));
                    },
                    icon: const Icon(Icons.air, color: Colors.white),
                    label: const Text("تمرين التنفس", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        isFocusMode = true;
                      });
                    },
                    icon: const Icon(Icons.center_focus_strong, color: Colors.orange),
                    label: const Text("التركيز العميق", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        isFocusMode = false;
                      });
                    },
                    icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                    label: const Text("خروج من وضع التركيز", style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleTimeButton(int minutes, Color textColor) {
    bool isSelected = seconds == minutes * 60 && !isBreak;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => _setTime(minutes),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: isSelected ? textColor : Colors.white.withOpacity(0.2),
          child: Text(
            "$minutes",
            style: TextStyle(
              color: isSelected ? (widget.themeMode >= 2 ? Colors.white : Colors.black) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
class BreathingScreen extends StatefulWidget {
  final int themeMode;
  const BreathingScreen({super.key, required this.themeMode});
  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _text = "شهيق";
  bool _isInhaling = true;
  int _secondsLeft = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _isInhaling = !_isInhaling;
          _secondsLeft = 10;
          _text = _isInhaling ? "شهيق" : "زفير";
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      backgroundColor: widget.themeMode == 0 ? const Color(0xFF121212) : (widget.themeMode == 1 ? const Color(0xFF424242) : (widget.themeMode == 2 ? const Color(0xFFE0F7FA) : (widget.themeMode == 3 ? const Color(0xFFE8F5E9) : Colors.white))),
      appBar: AppBar(title: Text("الاسترخاء", style: TextStyle(color: textColor, fontWeight: FontWeight.w300)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 200 * _animation.value,
                  height: 200 * _animation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: textColor.withOpacity(0.1),
                    border: Border.all(color: textColor.withOpacity(0.5), width: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Text("$_secondsLeft", style: TextStyle(fontSize: 60, fontWeight: FontWeight.w300, color: textColor)),
            const SizedBox(height: 40),
            LinearProgressIndicator(
              value: (10 - _secondsLeft) / 10,
              backgroundColor: textColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
              minHeight: 10,
            ),
            const SizedBox(height: 20),
            Text(_text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: textColor)),
            const SizedBox(height: 60),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: textColor,
                foregroundColor: widget.themeMode >= 2 ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("إنهاء التمرين", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
            ),
          ],
        ),
      ),
    );
  }
}

class SoundScreen extends StatefulWidget {
  final int themeMode;
  const SoundScreen({super.key, required this.themeMode});
  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingSound;

  void _playSound(String fileName) async {
    if (_playingSound == fileName) {
      await _audioPlayer.stop();
      setState(() => _playingSound = null);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('assets/$fileName'));
      setState(() => _playingSound = fileName);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      appBar: AppBar(title: Text("أصوات الطبيعة", style: TextStyle(color: textColor, fontWeight: FontWeight.w300)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSoundTile("المطر (1)", "rain1.mp3", textColor),
          _buildSoundTile("المطر (2)", "rain2.mp3", textColor),
          _buildSoundTile("البحر", "ocean.mp3", textColor),
          _buildSoundTile("الضوضاء (1)", "noise1.mp3", textColor),
          _buildSoundTile("الضوضاء (2)", "noise2.mp3", textColor),
        ],
      ),
    );
  }

  Widget _buildSoundTile(String title, String fileName, Color textColor) {
    bool isPlaying = _playingSound == fileName;
    return ListTile(
      leading: Icon(isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: () => _playSound(fileName),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final int themeMode;
  final Function(int) onThemeChange;
  const SettingsScreen({super.key, required this.themeMode, required this.onThemeChange});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int totalMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => totalMinutes = prefs.getInt('total_study_minutes') ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      appBar: AppBar(title: Text("الإعدادات", style: TextStyle(color: textColor, fontWeight: FontWeight.w300)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(leading: Icon(Icons.palette_outlined, color: textColor), title: Text("تغيير الألوان", style: TextStyle(color: textColor, fontWeight: FontWeight.w300))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColorButton(0, Colors.black, textColor),
              _buildColorButton(1, Colors.grey, textColor),
              _buildColorButton(2, const Color(0xFFE0F7FA), textColor), 
              _buildColorButton(3, const Color(0xFFE8F5E9), textColor), 
              _buildColorButton(4, Colors.white, textColor),
            ],
          ),
          const Divider(color: Colors.white24),
          ListTile(leading: Icon(Icons.security_outlined, color: textColor), title: Text("الخصوصية والأمان", style: TextStyle(fontWeight: FontWeight.w300, color: textColor))),
          const Divider(color: Colors.white24),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: Icon(Icons.privacy_tip_outlined, color: textColor),
            title: Text("سياسة الخصوصية", style: TextStyle(color: textColor, fontWeight: FontWeight.w300)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor.withOpacity(0.5)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyScreen(themeMode: widget.themeMode))),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.bar_chart_outlined, color: textColor),
            title: Text("سجل وقت الدراسة", style: TextStyle(color: textColor, fontWeight: FontWeight.w300)),
            subtitle: Text("لقد درست $totalMinutes دقيقة حتى الآن", style: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.w300)),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.info_outline, color: textColor),
            title: Text("حول التطبيق", style: TextStyle(color: textColor, fontWeight: FontWeight.w300)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor.withOpacity(0.5)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen(themeMode: widget.themeMode))),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(int mode, Color color, Color textColor) {
    bool isSelected = widget.themeMode == mode;
    return GestureDetector(
      onTap: () => widget.onThemeChange(mode),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.green : textColor.withOpacity(0.2), width: isSelected ? 3 : 1),
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  final int themeMode;
  const AboutScreen({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    Color textColor = themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      appBar: AppBar(title: Text("حول التطبيق", style: TextStyle(color: textColor, fontWeight: FontWeight.w300)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: textColor),
            const SizedBox(height: 20),
            Text("Study Room", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300, color: textColor)),
            const SizedBox(height: 10),
            Text("الإصدار: 1.0.0", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7), fontWeight: FontWeight.w300)),
            const SizedBox(height: 5),
            Text("المطور: بن مزوز رحاب", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7), fontWeight: FontWeight.w300)),
            const SizedBox(height: 5),
            Text("البلد: الجزائر 🇩🇿", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7), fontWeight: FontWeight.w300)),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  final int themeMode;
  const PrivacyPolicyScreen({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    Color textColor = themeMode >= 2 ? Colors.black : Colors.white;
    return Scaffold(
      appBar: AppBar(title: Text("سياسة الخصوصية", style: TextStyle(color: textColor, fontWeight: FontWeight.w300)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("خصوصيتك تهمنا", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: textColor)),
              const SizedBox(height: 15),
              Text("1. التطبيق لا يقوم بتسجيل أي بيانات شخصية أو إرسالها لأي جهة خارجية.\n\n2. جميع التسجيلات الصوتية والصور يتم تخزينها محلياً على هاتفك فقط.\n\n3. لا يوجد أي تتبع لموقعك أو مراقبة لاستخدامك.\n\n4. التطبيق صديق للبيئة وللطلبة، وهدفه مساعدتك على التركيز.", style: TextStyle(fontSize: 16, height: 1.6, color: textColor.withOpacity(0.7), fontWeight: FontWeight.w300)),
            ],
          ),
        ),
      ),
    );
  }
}