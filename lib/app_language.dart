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
    },
  };

  // الدالة اللي كترجع الكلمة حسب اللغة
  static String get(String key) {
    return _translations[currentLang]?[key] ?? key;
  }
}