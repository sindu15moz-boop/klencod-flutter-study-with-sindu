
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // حفظ بيانات المستخدم دون تعطيل المصادقة
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final docRef = _db.collection('users').doc(user.uid);
      final doc = await docRef.get();

      final data = {
        'email': user.email,
        'name': user.displayName ??
            user.email?.split('@')[0] ??
            'طالب',
      };

      if (!doc.exists) {
        await docRef.set({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.set(data, SetOptions(merge: true));
      }
    } catch (e) {
      // خطأ Firestore لا يلغي نجاح تسجيل الدخول
      print('FIRESTORE ERROR: $e');
    }
  }

  // تسجيل الدخول بالإيميل
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = result.user;

    if (user != null) {
      await _saveUserToFirestore(user);
    }

    return user;
  }

  // إنشاء حساب جديد
  Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = result.user;

    if (user != null) {
      await _saveUserToFirestore(user);
    }

    return user;
  }

  // تسجيل الدخول بجوجل
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn();

    if (googleUser == null) {
      return null;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;

    if (user != null) {
      await _saveUserToFirestore(user);
    }

    return user;
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      print('GOOGLE SIGNOUT ERROR: $e');
    }

    await _auth.signOut();
  }
}
