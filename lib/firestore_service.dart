import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // دالة إضافة بوست (مع صورة أو بلا صورة)
  Future<void> addPost(String userId, String userName, String content, String? imageUrl) async {
    await _db.collection('posts').add({
      'userId': userId,
      'userName': userName,
      'content': content,
      'imageUrl': imageUrl, // <--- زدنا هادي (كتقبل null إذا ماكانش صورة)
      'likes': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPosts() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> addFriend(String userId, String friendEmail) async {
    await _db.collection('users').doc(userId).collection('friends').add({
      'email': friendEmail,
    });
  }
}