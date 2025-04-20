// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  Future<List<Map<String, dynamic>>> _getFriends() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return [];

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .get();
    final friendsList = List<String>.from(userDoc.data()?['friends'] ?? []);

    if (friendsList.isEmpty) return [];

    final usersQuery = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendsList)
        .get();

    return usersQuery.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Amigos'),
        backgroundColor: Colors.green[900],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes amigos aún.'));
          }
          final friends = snapshot.data!;
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend['photoUrl'] != null &&
                          friend['photoUrl'].toString().isNotEmpty
                      ? NetworkImage(friend['photoUrl'])
                      : null,
                  child: (friend['photoUrl'] == null ||
                          friend['photoUrl'].toString().isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(friend['displayName'] ?? 'Sin nombre'),
                subtitle: Text(friend['email'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(profileUid: friend['uid']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
