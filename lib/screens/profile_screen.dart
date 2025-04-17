// ignore_for_file: use_build_context_synchronously, deprecated_member_use, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/rank_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
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
    return Scaffold(
      backgroundColor: const Color(0xFF388E3C),
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text('Mi Perfil'),
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
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
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

class TeamStatsWidget extends StatelessWidget {
  final String teamId;
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

        // Aquí mostramos el nombre del equipo destacado
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teamData['name'] ?? 'Equipo sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Guarda los datos en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'displayName': _nameController.text.trim(),
        'photoUrl': _photoUrlController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      Navigator.pushReplacementNamed(context, '/main');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al registrar')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF388E3C),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sports_soccer, size: 64, color: Colors.green[900]),
                const SizedBox(height: 16),
                Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person, color: Colors.green[700]),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email, color: Colors.green[700]),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock, color: Colors.green[700]),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _photoUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL de foto (opcional)',
                    prefixIcon: Icon(Icons.image, color: Colors.green[700]),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registrarse',
                            style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  // ignore: sort_child_properties_last
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green[900],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
