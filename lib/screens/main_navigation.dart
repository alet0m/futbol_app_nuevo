// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'teams_screen.dart';
import 'search_user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'friend_requests_screen.dart';
import 'notifications_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Ajusta estos valores según tu lógica
  final String selectedMyTeamId = '';
  final String selectedMyTeamName = '';

  List<Widget> get _screens => [
        MatchesScreen(
          tuEquipoId: selectedMyTeamId,
          tuEquipoName: selectedMyTeamName,
        ),
        TeamsScreen(),
        SearchUserScreen(),
        ProfileScreen(profileUid: FirebaseAuth.instance.currentUser!.uid),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fútbol App'),
        automaticallyImplyLeading: false, // Quita la flecha de volver
        actions: [
          notificationsBadgeIcon(context),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Partidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Equipos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Widget para el icono de notificaciones con punto rojo
Widget notificationsBadgeIcon(BuildContext context) {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('friend_requests')
        .where('to', isEqualTo: currentUid)
        .where('status', isEqualTo: 'pending')
        .snapshots(),
    builder: (context, snapshot) {
      final hasNotifications =
          snapshot.hasData && snapshot.data!.docs.isNotEmpty;
      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notificaciones',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          if (hasNotifications)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    },
  );
}

Widget friendRequestsIcon(BuildContext context) {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('friend_requests')
        .where('to', isEqualTo: currentUid)
        .where('status', isEqualTo: 'pending')
        .snapshots(),
    builder: (context, snapshot) {
      int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Solicitudes de amistad',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendRequestsScreen()),
              );
            },
          ),
          if (count > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    },
  );
}
