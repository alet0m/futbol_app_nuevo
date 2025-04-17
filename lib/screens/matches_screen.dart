// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/match_service.dart';

class MatchesScreen extends StatefulWidget {
  final String? tuEquipoId;
  final String? tuEquipoName;

  const MatchesScreen({super.key, this.tuEquipoId, this.tuEquipoName});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  String? selectedMyTeamId;
  String? selectedMyTeamName;
  String? selectedRivalId;
  String? tipoPartido;
  String? tipoFutbol;
  DateTime? selectedDate;
  final TextEditingController _locationController = TextEditingController();

  List<Map<String, dynamic>> myTeams = [];

  @override
  void initState() {
    super.initState();
    _loadMyTeams();
  }

  Future<void> _loadMyTeams() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final teamsIds = (userDoc.data()?['teams'] as List?)?.cast<String>() ?? [];
    if (teamsIds.isEmpty) return;
    final teamsSnap = await FirebaseFirestore.instance
        .collection('teams')
        .where(FieldPath.documentId, whereIn: teamsIds)
        .get();
    setState(() {
      myTeams = teamsSnap.docs
          .map((doc) => {'id': doc.id, 'name': doc['name'] ?? 'Equipo'})
          .toList();
    });
  }

  void _setValoresPorModalidad(String? modalidad) {
    // No se necesita guardar duración, entretiempo ni jugadores, solo mostrar reglas
  }

  Future<void> _createMatch() async {
    if (selectedMyTeamId == null ||
        selectedRivalId == null ||
        tipoPartido == null ||
        tipoFutbol == null ||
        selectedDate == null ||
        _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    // Validar que el UID del equipo rival exista
    final rivalDoc = await FirebaseFirestore.instance
        .collection('teams')
        .doc(selectedRivalId)
        .get();

    if (!rivalDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El UID del equipo rival no existe')),
      );
      return;
    }

    // Opciones automáticas según modalidad
    int duracion = tipoFutbol == 'futbol11' ? 90 : 60;
    int entretiempo = tipoFutbol == 'futbol11' ? 15 : 0;
    int jugadoresPorEquipo = tipoFutbol == 'futbol11' ? 11 : 7;

    await MatchService.createMatch(
      teamA: selectedMyTeamId!,
      teamB: selectedRivalId!,
      teamAName: selectedMyTeamName ?? '',
      teamBName: rivalDoc['name'] ?? '',
      date: selectedDate!,
      location: _locationController.text.trim(),
      tipo: tipoPartido!,
      modalidad: tipoFutbol!,
      duracion: duracion,
      entretiempo: entretiempo,
      jugadoresPorEquipo: jugadoresPorEquipo,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partido creado correctamente')),
    );
    setState(() {
      selectedMyTeamId = null;
      selectedMyTeamName = null;
      selectedRivalId = null;
      tipoPartido = null;
      tipoFutbol = null;
      selectedDate = null;
      _locationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Partido')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona tu equipo:'),
            DropdownButton<String>(
              value: selectedMyTeamId,
              hint: const Text('Tu equipo'),
              items: myTeams
                  .map((team) => DropdownMenuItem<String>(
                        value: team['id'] as String,
                        child: Text('${team['name']} (${team['id']})'),
                      ))
                  .toList(),
              onChanged: myTeams.isEmpty
                  ? null
                  : (value) {
                      final team = myTeams.firstWhere((t) => t['id'] == value);
                      setState(() {
                        selectedMyTeamId = value;
                        selectedMyTeamName = team['name'];
                      });
                    },
            ),
            const SizedBox(height: 16),
            const Text('UID del equipo rival:'),
            TextField(
              onChanged: (value) {
                selectedRivalId = value.trim();
              },
              decoration: const InputDecoration(
                hintText: 'Ingresa el UID del equipo rival',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tipo de partido:'),
            DropdownButton<String>(
              value: tipoPartido,
              hint: const Text('Selecciona tipo de partido'),
              items: const [
                DropdownMenuItem(value: 'clasificatorio', child: Text('Clasificatorio')),
                DropdownMenuItem(value: 'casual', child: Text('Casual')),
              ],
              onChanged: (value) {
                setState(() {
                  tipoPartido = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Modalidad:'),
            DropdownButton<String>(
              value: tipoFutbol,
              hint: const Text('Selecciona modalidad'),
              items: const [
                DropdownMenuItem(value: 'futbolito', child: Text('Futbolito')),
                DropdownMenuItem(value: 'futbol11', child: Text('Fútbol 11')),
              ],
              onChanged: (value) {
                setState(() {
                  tipoFutbol = value;
                });
                _setValoresPorModalidad(value);
              },
            ),
            const SizedBox(height: 16),
            if (tipoFutbol == 'futbolito') ...[
              const Text('Duración: 60 minutos'),
              const Text('Entretiempo: No'),
              const Text('Jugadores por equipo: mínimo 6, máximo 7 en cancha'),
            ] else if (tipoFutbol == 'futbol11') ...[
              const Text('Duración: 90 minutos'),
              const Text('Entretiempo: 15 minutos'),
              const Text('Jugadores por equipo: 11'),
            ],
            const SizedBox(height: 16),
            const Text('Fecha y hora:'),
            Row(
              children: [
                Text(selectedDate == null
                    ? 'No seleccionada'
                    : '${selectedDate!.toLocal()}'.split(' ')[0]),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: DateTime(now.year + 2),
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          selectedDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: const Text('Seleccionar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Lugar:'),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Ej: Cancha Municipal',
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _createMatch,
                child: const Text('Crear partido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}