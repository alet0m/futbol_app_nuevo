import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'search_user_screen.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _uidController = TextEditingController();
  String? _searchedUid;
  bool _notFound = false;

  Future<void> _searchUser() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _searchedUid = doc.exists ? uid : null;
      _notFound = !doc.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            if (_searchedUid != null)
              Expanded(
                child: ProfileScreen(profileUid: _searchedUid!),
              ),
            if (_notFound)
              const Text('Usuario no encontrado', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

List<Widget> get _screens => [
  MatchesScreen(
    tuEquipoId: selectedMyTeamId,
    tuEquipoName: selectedMyTeamName,
  ),
  TeamsScreen(),
  SearchUserScreen(), // <--- Agregado aquí
  ProfileScreen(
    profileUid: FirebaseAuth.instance.currentUser!.uid,
  ),
];