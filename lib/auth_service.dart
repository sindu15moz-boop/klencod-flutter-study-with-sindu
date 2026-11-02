import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تسجيل الدخول بالإيميل وكلمة المرور
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // إنشاء حساب جديد
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // تسجيل الدخول بجوجل
  Future<User?> signInWithGoogle() async {
    try {
      // نفتحو نافذة جوجل باش المستخدم يختار الحساب
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; // المستخدم سكر النافذة
      }

      // نجيبو التوكن تاع جوجل
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // نصايبو الاعتماد (Credential) ونربطوه مع Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // نسجلو الدخول في Firebase
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print("Error Google Sign-In: $e");
      return null;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await GoogleSignIn().signOut(); // نخرجو من جوجل تاني
    await _auth.signOut();
  }
}