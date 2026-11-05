import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // دالة كتسجل المستخدم في Firestore (إذا ما كانش مسجل)
  Future<void> _saveUserToFirestore(User user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // إذا كان جديد، نسجلو
      await docRef.set({
        'email': user.email,
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'طالب',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // تسجيل الدخول بالإيميل وكلمة المرور
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        await _saveUserToFirestore(result.user!);
      }
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
      if (result.user != null) {
        await _saveUserToFirestore(result.user!);
      }
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // تسجيل الدخول بجوجل
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        await _saveUserToFirestore(result.user!);
      }
      return result.user;
    } catch (e) {
      print("Error Google Sign-In: $e");
      return null;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}