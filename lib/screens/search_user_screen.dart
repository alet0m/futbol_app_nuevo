// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import '../services/friend_service.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _uidController = TextEditingController();
  Map<String, dynamic>? _userData;
  String? _searchedUid;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    // saveFcmToken(); // Eliminado porque ya no se usa FCM asasdsadadsadsdsa
  }

  Future<void> _searchUser() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      if (doc.exists) {
        _userData = doc.data();
        _searchedUid = uid;
        _notFound = false;
      } else {
        _userData = null;
        _searchedUid = null;
        _notFound = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar usuario por UID')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _uidController,
              decoration: const InputDecoration(
                labelText: 'UID de usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _searchUser,
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 24),
            if (_userData != null && _searchedUid != null)
              Card(
                child: ListTile(
                  leading: _userData!['photoUrl'] != null &&
                          _userData!['photoUrl'].toString().isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(_userData!['photoUrl']))
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(_userData!['displayName'] ?? 'Sin nombre'),
                  subtitle: Text(_userData!['email'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchedUid != currentUid)
                        IconButton(
                          icon: const Icon(Icons.person_add),
                          tooltip: 'Agregar amigo',
                          onPressed: () async {
                            try {
                              await FriendService.sendFriendRequest(
                                  _searchedUid!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Solicitud enviada')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'ya enviaste una solicitud de amistad')),
                              );
                            }
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: 'Ver perfil',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfileScreen(profileUid: _searchedUid!),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (_notFound)
              const Text('Usuario no encontrado',
                  style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
