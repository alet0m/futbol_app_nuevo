// ignore_for_file: use_build_context_synchronously, sort_child_properties_last, unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/rank_data.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _playerUidController = TextEditingController();

  final Map<String, Map<String, int>> _playerLimits = {
    'Futbolito': {'min': 6, 'max': 10},
    'Fútbol 11': {'min': 11, 'max': 16},
  };
  String _selectedType = 'Futbolito';

  Future<void> _createTeam(String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (_teamNameController.text.trim().isEmpty || user == null) return;

    // 1. Crea el equipo y obtén el ID
    final teamRef = await FirebaseFirestore.instance.collection('teams').add({
      'name': _teamNameController.text.trim(),
      'createdBy': user.uid,
      'type': type,
      'members': [user.uid],
      'createdAt': Timestamp.now(),
      'stats': {
        "pointsClasificatoria": 0,
        "pointsCasual": 0,
        "matchesPlayed": 0,
        "goals": 0,
        "goalsAgainst": 0,
        "wins": 0,
        "draws": 0,
        "losses": 0
      }
    });

    // 2. Agrega el ID del equipo al array 'teams' del usuario
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'teams': FieldValue.arrayUnion([teamRef.id])
    });

    _teamNameController.clear();
    Navigator.of(context).pop();
  }

  Future<void> _editTeamName(String teamId, String currentName) async {
    _teamNameController.text = currentName;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre del equipo'),
        content: TextField(
          controller: _teamNameController,
          decoration: const InputDecoration(labelText: 'Nuevo nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_teamNameController.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('teams')
                    .doc(teamId)
                    .update({'name': _teamNameController.text.trim()});
              }
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    _teamNameController.clear();
  }

  Future<void> _addPlayer(
      String teamId, List members, String type, String createdBy) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Solo el admin puede agregar jugadores
    if (user.uid != createdBy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solo el administrador puede agregar jugadores.')),
      );
      return;
    }

    if (_playerUidController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes ingresar el UID del jugador.')),
      );
      return;
    }
    final uid = _playerUidController.text.trim();

    // Verifica si el usuario existe en la colección users
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El usuario no existe.')),
      );
      return;
    }

    final limits = _playerLimits[type]!;
    final max = limits['max']!;

    if (members.length >= max) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Máximo de $max jugadores para $type.')),
      );
      return;
    }

    if (members.contains(uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El usuario ya está en el equipo.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('teams').doc(teamId).update({
      'members': FieldValue.arrayUnion([uid])
    });

    _playerUidController.clear();
    Navigator.of(context).pop();
  }

  Future<void> _removePlayer(
      String teamId, String uid, List members, String type) async {
    final limits = _playerLimits[type]!;
    final min = limits['min']!;
    if (members.length <= min) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'El equipo debe tener al menos $min jugadores para $type.')),
      );
      return;
    }
    await FirebaseFirestore.instance.collection('teams').doc(teamId).update({
      'members': FieldValue.arrayRemove([uid])
    });
  }

  Future<List<Map<String, String>>> _getMemberInfos(List members) async {
    if (members.isEmpty) return [];
    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: members)
        .get();
    return usersSnap.docs
        .map((doc) => {
              'uid': doc.id,
              'name': (doc.data()['displayName'] ?? doc.id).toString(),
            })
        .toList();
  }

  Future<void> _deleteTeam(String teamId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar equipo?'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este equipo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('teams').doc(teamId).delete();
    }
  }

  void _showCreateTeamDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String localSelectedType = _selectedType;
        return AlertDialog(
          title: const Text('Crear equipo'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _teamNameController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre del equipo'),
                  ),
                  DropdownButton<String>(
                    value: localSelectedType,
                    items: _playerLimits.keys
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        localSelectedType = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedType = localSelectedType;
                });
                _createTeam(localSelectedType);
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showAddPlayerDialog(
      String teamId, List members, String type, String createdBy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar jugador'),
        content: TextField(
          controller: _playerUidController,
          decoration: const InputDecoration(labelText: 'UID del jugador'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _addPlayer(teamId, members, type, createdBy),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Debes iniciar sesión.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateTeamDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('teams')
            .where('members', arrayContains: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay equipos aún.'));
          }
          final teams = snapshot.data!.docs;
          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final data = team.data() as Map<String, dynamic>;
              final isOwner = data['createdBy'] == user.uid;
              final members = List<String>.from(data['members'] ?? []);
              final type = data['type'] ?? 'Futbolito';
              final limits = _playerLimits[type]!;
              final min = limits['min']!;
              final max = limits['max']!;

              return FutureBuilder<List<Map<String, String>>>(
                future: _getMemberInfos(members),
                builder: (context, snapshot) {
                  final memberInfos = snapshot.data ?? [];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ExpansionTile(
                      title: Text('${data['name']} ($type)'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jugadores: ${members.length}/$max'),
                          TeamStatsWidget(teamId: team.id),
                        ],
                      ),
                      trailing: isOwner
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () =>
                                      _editTeamName(team.id, data['name']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.person_add,
                                      color: Colors.blue),
                                  onPressed: () => _showAddPlayerDialog(team.id,
                                      members, type, data['createdBy']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteTeam(team.id),
                                ),
                              ],
                            )
                          : null,
                      children: memberInfos.map((member) {
                        final isAdmin = member['uid'] == data['createdBy'];
                        return ListTile(
                          title: Text('${member['name']}'),
                          subtitle: Text('UID: ${member['uid']}'),
                          trailing: isOwner && !isAdmin
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () => _removePlayer(
                                      team.id, member['uid']!, members, type),
                                )
                              : isAdmin
                                  ? const Text('Admin',
                                      style: TextStyle(color: Colors.green))
                                  : null,
                        );
                      }).toList(),
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

class TeamStatsWidget extends StatelessWidget {
  final String teamId;
  // ignore: use_key_in_widget_constructors
  const TeamStatsWidget({required this.teamId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('teams').doc(teamId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final teamData = snapshot.data!.data() as Map<String, dynamic>;
        final stats = teamData['stats'] ?? {};
        final members = teamData['members'] as List? ?? [];

        final rangoEquipo = getRangoPorStats({
          ...stats,
          'teamMembers': members.length,
        });

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(teamData['name'] ?? 'Equipo'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rango equipo: ${rangoEquipo.nombre}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(rangoEquipo.descripcion),
                Text('Jugadores: ${members.length}'),
                Text('Partidos jugados: ${stats['matchesPlayed'] ?? 0}'),
                Text('Goles: ${stats['goals'] ?? 0}'),
                Text('Victorias: ${stats['wins'] ?? 0}'),
                Text('Empates: ${stats['draws'] ?? 0}'),
                Text('Derrotas: ${stats['losses'] ?? 0}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
