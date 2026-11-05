import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _hasSearched = false;

  // دالة البحث عن صديق بالإيميل
  Future<void> _searchFriend() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResults.clear();
    });

    try {
      // نبحثو في مجموعة users على الإيميل
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: query)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // لقيناه
        setState(() {
          _searchResults = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        });
      } else {
        // ما لقيناهش
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // دالة إضافة صديق
  Future<void> _addFriend(String friendEmail) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // نسجلو الصديق في مجموعة المستخدم الحالي
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .add({
      'email': friendEmail,
      'addedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة $friendEmail كصديق!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('الأصدقاء', style: TextStyle(fontFamily: 'Sanchez', color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // خانة البحث
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'أدخل إيميل صديقك...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  onPressed: _searchFriend,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // النتائج
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasSearched && _searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'نحن آسفون، لم نجد هذا المستخدم.',
                            style: TextStyle(color: Colors.white54, fontFamily: 'Sanchez', fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final friend = _searchResults[index];
                            return Card(
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(
                                  friend['email'] ?? 'مستخدم',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add, color: Colors.green),
                                  onPressed: () => _addFriend(friend['email']),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}