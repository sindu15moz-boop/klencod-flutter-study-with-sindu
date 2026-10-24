import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const StudyApp());
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIconColor: Colors.white70,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
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
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("البريد الإلكتروني أو كلمة المرور غير صحيحة")));
      }
    } else {
      await prefs.setString('user_email', _emailController.text);
      await prefs.setString('user_password', _passwordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إنشاء الحساب بنجاح!")));
        setState(() => _isLogin = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.person, size: 60, color: Colors.black),
              ),
              const SizedBox(height: 30),
              Text(_isLogin ? "تسجيل الدخول" : "إنشاء حساب", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 30),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: "البريد الإلكتروني", prefixIcon: Icon(Icons.email))),
              const SizedBox(height: 15),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "كلمة المرور", prefixIcon: Icon(Icons.lock))),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _submit, child: Text(_isLogin ? "دخول" : "إنشاء حساب", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              TextButton(onPressed: () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? "ليس لديك حساب؟ سجل هنا" : "لديك حساب؟ دخل من هنا", style: const TextStyle(color: Colors.white70))),
            ],
          ),
        ),
      ),
    );
  }
}
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories, size: 80, color: Colors.white),
              const SizedBox(height: 30),
              const Text("أهلاً بك في غرفة الدراسة!", textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              const Text("لقد اخترت المكان الصحيح. الدراسة هي مفتاح نجاحك، والنجاح ليس صعباً، بل يحتاج إلى القليل من التنظيم والصبر.\n\nهنا، سنساعدك على التركيز، والاسترخاء، والوصول إلى هدفك.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.6)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LanguageScreen())),
                  child: const Text("هل أنت مستعد للبدء؟", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("اختر اللغة / Choisir la langue", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 40),
              _buildLangButton(context, "العربية"),
              const SizedBox(height: 15),
              _buildLangButton(context, "Français"),
              const SizedBox(height: 15),
              _buildLangButton(context, "English"),
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
        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
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
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainAppScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const Text("معلومات الطالب", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 30),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "الاسم الكامل", prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(labelText: "المستوى الدراسي", prefixIcon: Icon(Icons.school)),
              items: _levels.map((String level) => DropdownMenuItem<String>(value: level, child: Text(level, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (String? newValue) => setState(() => _selectedLevel = newValue!),
              dropdownColor: const Color(0xFF1E1E1E),
            ),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveAndContinue, child: const Text("متابعة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }
}
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});
  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [const RoomScreen(), const SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
      ),
    );
  }
}

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with SingleTickerProviderStateMixin {
  int seconds = 1500;
  bool isRunning = false;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _animation;
  String _studentName = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _animation = Tween<double>(begin: -5, end: 5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _studentName = prefs.getString('student_name') ?? "طالب");
  }

  String get timerText {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
          _showRelaxationDialog();
        }
      });
    }
  }

  void _showRelaxationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('أحسنت!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        content: const Text('لقد درست وبذلت جهداً كبيراً. عقلك يحتاج إلى قسط من الراحة ليعود أقوى.\n\nهل تريد أن تتنفس بعمق؟', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BreathingScreen()));
            },
            child: const Text('ابدأ التنفس', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { _timer?.cancel(); _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("مرحباً $_studentName", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _animation.value),
                child: Image.asset('ghost.png', height: 300, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Text("الصورة غير موجودة", style: TextStyle(color: Colors.white))),
              ),
            ),
            const SizedBox(height: 20),
            Text(timerText, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w300, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _toggleTimer, child: Text(isRunning ? "إيقاف" : "بدء", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("الاسترخاء", style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
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
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Text("$_secondsLeft", style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 40),
            LinearProgressIndicator(
              value: (10 - _secondsLeft) / 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
            const SizedBox(height: 20),
            Text(_text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إنهاء التمرين", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الإعدادات", style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ListTile(leading: Icon(Icons.security, color: Colors.white), title: Text("الخصوصية والأمان", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          const Divider(color: Colors.white24),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: const Icon(Icons.privacy_tip, color: Colors.white),
            title: const Text("سياسة الخصوصية", style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
          ),
          const Divider(color: Colors.white24),
          const ListTile(leading: Icon(Icons.storage, color: Colors.white), title: Text("تخزين البيانات", style: TextStyle(color: Colors.white)), subtitle: Text("جميع بياناتك تحفظ في هاتفك فقط.", style: TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("سياسة الخصوصية", style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
                  body: const Padding(
        padding: EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("خصوصيتك تهمنا", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 15),
              Text("1. التطبيق لا يقوم بتسجيل أي بيانات شخصية أو إرسالها لأي جهة خارجية.\n\n2. جميع التسجيلات الصوتية والصور يتم تخزينها محلياً على هاتفك فقط.\n\n3. لا يوجد أي تتبع لموقعك أو مراقبة لاستخدامك.\n\n4. التطبيق صديق للبيئة وللطلبة، وهدفه مساعدتك على التركيز.", style: TextStyle(fontSize: 16, height: 1.6, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
