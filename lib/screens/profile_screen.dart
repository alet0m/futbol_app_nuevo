// ignore_for_file: use_build_context_synchronously, deprecated_member_use, use_key_in_widget_constructors, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/rank_data.dart';
import '../services/friend_service.dart';

class ProfileScreen extends StatelessWidget {
  final String? profileUid;
  const ProfileScreen({super.key, this.profileUid});

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
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

  Widget _buildStat(String label, dynamic value, {Color? color}) {
    return Column(
      children: [
        Text(
          value?.toString() ?? '0',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color ?? Colors.green[900],
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String uidToShow = profileUid ?? currentUid;

    return Scaffold(
      backgroundColor: const Color(0xFF388E3C),
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Text(currentUid == uidToShow ? 'Mi Perfil' : 'Perfil'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(uidToShow),
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

              // Aquí empieza la lógica para amistad
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final myData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final myFriends = List<String>.from(myData['friends'] ?? []);
                  final isOwnProfile = currentUid == uidToShow;
                  final isFriend = myFriends.contains(uidToShow);

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('friend_requests')
                        .where('from', isEqualTo: currentUid)
                        .where('to', isEqualTo: uidToShow)
                        .where('status', isEqualTo: 'pending')
                        .get(),
                    builder: (context, requestSnapshot) {
                      final hasPendingRequest = requestSnapshot.hasData &&
                          requestSnapshot.data!.docs.isNotEmpty;

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
                                          data['photoUrl']
                                              .toString()
                                              .isNotEmpty)
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
                                Text('División: ${rangoInfo.nombre}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.amber)),
                                Text(rangoInfo.descripcion),
                                const SizedBox(height: 24),
                                // Estadísticas visualmente atractivas
                                Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.07),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Estadísticas',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildStat(
                                              'Partidos', stats['matchesPlayed']),
                                          _buildStat('Goles', stats['goals']),
                                          _buildStat('Asistencias',
                                              stats['assists']),
                                          _buildStat('MVP',
                                              stats['playerOfTheMatch']),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildStat('Victorias', stats['wins'],
                                              color: Colors.green),
                                          _buildStat('Derrotas', stats['losses'],
                                              color: Colors.red),
                                          _buildStat('Amarillas',
                                              stats['yellowCards'],
                                              color: Colors.amber),
                                          _buildStat('Rojas',
                                              stats['redCards'],
                                              color: Colors.redAccent),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                const Text('Tus equipos:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 8),
                                if (equipos.isEmpty)
                                  const Text('No tienes equipos registrados.',
                                      style: TextStyle(color: Colors.grey)),
                                ...equipos.map<Widget>((team) => Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: ListTile(
                                        leading: const Icon(Icons.group,
                                            color: Colors.green),
                                        title: Text(team['name'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    )),
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
                                if (!isOwnProfile &&
                                    !isFriend &&
                                    !hasPendingRequest)
                                  ElevatedButton(
                                    onPressed: () async {
                                      await FriendService.sendFriendRequest(
                                          uidToShow);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Solicitud enviada')),
                                      );
                                    },
                                    child: const Text('Agregar amigo'),
                                  ),
                                if (isFriend)
                                  const Text('Ya son amigos',
                                      style:
                                          TextStyle(color: Colors.green)),
                                if (hasPendingRequest && !isFriend)
                                  const Text('Solicitud pendiente',
                                      style:
                                          TextStyle(color: Colors.orange)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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