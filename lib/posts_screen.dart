import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'firestore_service.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _postController = TextEditingController();
  final User? _user = FirebaseAuth.instance.currentUser;
  File? _selectedImage;

  // دالة تختار صورة
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // دالة تنشر البوست
  void _addPost() async {
    if (_postController.text.trim().isEmpty || _user == null) return;

    String? imageUrl;
    if (_selectedImage != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('post_images/$fileName.jpg');
      await ref.putFile(_selectedImage!);
      imageUrl = await ref.getDownloadURL();
    }

    await _firestoreService.addPost(
      _user!.uid,
      _user!.email ?? 'طالب',
      _postController.text.trim(),
      imageUrl,
    );

    _postController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  // نافذة التعليقات
  void _showCommentsDialog(String postId) {
    final TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('التعليقات', style: TextStyle(color: Colors.white, fontFamily: 'Sanchez')),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final comments = snapshot.data!.docs;
                      if (comments.isEmpty) return const Center(child: Text('لا توجد تعليقات', style: TextStyle(color: Colors.white54)));
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            title: Text(comment['userEmail'], style: const TextStyle(color: Colors.orange, fontSize: 12)),
                            subtitle: Text(comment['text'], style: const TextStyle(color: Colors.white)),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(hintText: 'أضف تعليقاً...', hintStyle: TextStyle(color: Colors.white54)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () async {
                        if (commentController.text.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('comments')
                              .add({
                            'userId': _user!.uid,
                            'userEmail': _user!.email,
                            'text': commentController.text,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة باش نجيبو الاسم الأول (اللي قبل @)
  String _getFirstName(String email) {
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("المجتمع", style: TextStyle(fontFamily: 'Sanchez', color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // خانة كتابة البوست
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                if (_selectedImage != null)
                  Stack(
                    children: [
                      Image.file(_selectedImage!, height: 100),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setState(() => _selectedImage = null),
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _postController,
                        decoration: InputDecoration(
                          hintText: "شاركنا تقدمك...",
                          hintStyle: const TextStyle(color: Colors.white54, fontFamily: 'Sanchez'),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.white54),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _addPost,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // قائمة البوستات
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getPosts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final posts = snapshot.data!.docs;
                if (posts.isEmpty) return const Center(child: Text("لا توجد بوستات بعد", style: TextStyle(color: Colors.white54)));
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    int likes = post['likes'] ?? 0;
                    String email = post['userName'] ?? 'مستخدم';
                    String firstName = _getFirstName(email); // الاسم الأول فقط

                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              // الاسم الأول باللون الأبيض الخافت
                              title: Text(firstName, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                              subtitle: Text(post['content'] ?? '', style: const TextStyle(color: Colors.white)),
                            ),
                            if (post['imageUrl'] != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Image.network(post['imageUrl'], fit: BoxFit.cover),
                              ),
                            const Divider(color: Colors.white24),
                            Row(
                              children: [
                                // زر اللايك (كي يزيد مرة وحدة)
                                GestureDetector(
                                  onTap: () async {
                                    // نتحققو واش المستخدم ديجا دار لايك
                                    await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
                                      'likes': likes + 1,
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.favorite, color: Colors.red, size: 20),
                                      const SizedBox(width: 5),
                                      Text('$likes', style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // زر التعليق
                                GestureDetector(
                                  onTap: () => _showCommentsDialog(post.id),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.comment, color: Colors.white54, size: 20),
                                      SizedBox(width: 5),
                                      Text('تعليق', style: TextStyle(color: Colors.white54)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}