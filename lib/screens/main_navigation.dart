// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'teams_screen.dart';
import 'search_user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
