import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  // اللغة الحالية (الافتراضية عربية)
  static String currentLang = 'ar';

  // القاموس تاع الترجمات
  static final Map<String, Map<String, String>> _translations = {
    'ar': {
      'welcome': 'مرحباً بك',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'timer': 'المؤقت',
      'community': 'المجتمع',
      'friends': 'الأصدقاء',
      'startFocus': 'ابدأ التركيز',
      'onboarding_title': 'رفيقك للدراسة',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'logout': 'تسجيل الخروج',
      'about': 'معلومات حول التطبيق',
    },
    'en': {
      'welcome': 'Welcome',
      'login': 'Login',
      'signup': 'Sign Up',
      'timer': 'Timer',
      'community': 'Community',
      'friends': 'Friends',
      'startFocus': 'Start Focus',
      'onboarding_title': 'Your Study Companion',
      'settings': 'Settings',
      'language': 'Language',
      'logout': 'Logout',
      'about': 'About App',
    },
    'fr': {
      'welcome': 'Bienvenue',
      'login': 'Connexion',
      'signup': 'S\'inscrire',
      'timer': 'Minuteur',
      'community': 'Communauté',
      'friends': 'Amis',
      'startFocus': 'Commencer le focus',
      'onboarding_title': 'Votre compagnon d\'étude',
      'settings': 'Paramètres',
      'language': 'Langue',
      'logout': 'Déconnexion',
      'about': 'À propos',
    },
  };

  // الدالة اللي كترجع الكلمة حسب اللغة
  static String get(String key) {
    return _translations[currentLang]?[key] ?? key;
  }

  // دالة تبدل اللغة وتحفظها
  static Future<void> changeLanguage(String lang) async {
    currentLang = lang;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', lang);
  }

  // دالة تحمل اللغة المحفوظة كي يحل التطبيق
  static Future<void> loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentLang = prefs.getString('app_lang') ?? 'ar';
  }
}