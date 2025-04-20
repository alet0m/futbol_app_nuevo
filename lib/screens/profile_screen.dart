// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/rank_data.dart';
import '../services/friend_service.dart';

class ProfileScreen extends StatelessWidget {
  final String profileUid;
  const ProfileScreen({super.key, required this.profileUid});

  Future<Map<String, dynamic>?> _getUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(profileUid)
        .get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> _getTeams(List teamsIds) async {
    if (teamsIds.isEmpty) return [];
    final teamsSnap = await FirebaseFirestore.instance
        .collection('teams')
        .where(FieldPath.documentId, whereIn: teamsIds)
        .get();
    return teamsSnap.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'] ?? 'Equipo',
              'modalidad': doc['type'] ?? doc['modalidad'] ?? 'futbolito',
              'stats': doc['stats'] ?? {},
              'members': doc['members'] ?? [],
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = FirebaseAuth.instance.currentUser?.uid == profileUid;

    return Scaffold(
      backgroundColor: const Color(0xFF388E3C),
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Text(isOwnProfile ? 'Mi Perfil' : 'Perfil'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text('No se encontraron datos del usuario.'));
          }
          final data = snapshot.data!;
          final stats = data['stats'] ?? {};
          final teams = data['teams'] ?? [];

          final rangoInfo = getRangoPorStats({
            ...stats,
            'teams': teams,
          });

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _getTeams(teams),
            builder: (context, teamsSnapshot) {
              if (!teamsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final equipos = teamsSnapshot.data!;
              final equiposFutbol11 =
                  equipos.where((e) => e['modalidad'] == 'Fútbol 11').toList();
              final equiposFutbolito =
                  equipos.where((e) => e['modalidad'] == 'Futbolito').toList();

              return Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF388E3C),
                          backgroundImage: (data['photoUrl'] != null &&
                                  data['photoUrl'].toString().isNotEmpty)
                              ? NetworkImage(data['photoUrl'])
                              : null,
                          child: (data['photoUrl'] == null ||
                                  data['photoUrl'].toString().isEmpty)
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data['displayName'] ?? 'Sin nombre',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['email'] ?? '',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text('Rango: ${rangoInfo.nombre}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(rangoInfo.descripcion),
                        if (isOwnProfile)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.people),
                              label: const Text('Ver amigos'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[800],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/friends');
                              },
                            ),
                          ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const Text('Tus equipos:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),

                        // Sección equipos de Futbol 11
                        if (equiposFutbol11.isNotEmpty) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 12, bottom: 4),
                              child: Text(
                                'Equipos de Fútbol 11',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.green),
                              ),
                            ),
                          ),
                          ...equiposFutbol11.map<Widget>((team) => Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.sports_soccer,
                                      color: Colors.green),
                                  title: Text(team['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      'Jugadores: ${(team['members'] as List).length}'),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              )),
                        ],

                        // Sección equipos de Futbolito
                        if (equiposFutbolito.isNotEmpty) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 12, bottom: 4),
                              child: Text(
                                'Equipos de Futbolito',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.orange),
                              ),
                            ),
                          ),
                          ...equiposFutbolito.map<Widget>((team) => Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.sports,
                                      color: Colors.orange),
                                  title: Text(team['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      'Jugadores: ${(team['members'] as List).length}'),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              )),
                        ],

                        if (equiposFutbol11.isEmpty && equiposFutbolito.isEmpty)
                          const Text('No tienes equipos registrados.',
                              style: TextStyle(color: Colors.grey)),

                        const SizedBox(height: 24),
                        const Divider(),
                        const Text('Tus estadísticas:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                            'Partidos jugados: ${stats['matchesPlayed'] ?? 0}'),
                        Text('Goles: ${stats['goals'] ?? 0}'),
                        Text('Asistencias: ${stats['assists'] ?? 0}'),
                        Text('Victorias: ${stats['wins'] ?? 0}'),
                        Text('Derrotas: ${stats['losses'] ?? 0}'),
                        Text(
                            'Jugador del partido: ${stats['playerOfTheMatch'] ?? 0}'),
                        Text(
                            'Tarjetas amarillas: ${stats['yellowCards'] ?? 0}'),
                        Text('Tarjetas rojas: ${stats['redCards'] ?? 0}'),
                        const SizedBox(height: 24),
                        if (isOwnProfile)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text('Cerrar sesión'),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              }
                            },
                          ),
                        if (!isOwnProfile)
                          ElevatedButton(
                            onPressed: () async {
                              await FriendService.sendFriendRequest(profileUid);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Solicitud enviada')),
                              );
                            },
                            child: const Text('Agregar amigo'),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
