// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

/// Este script recorre todos los equipos y asegura que cada miembro
/// tenga el ID del equipo en su campo 'teams' en el documento de usuario.
Future<void> syncTeamsWithUsers() async {
  final firestore = FirebaseFirestore.instance;
  final teamsSnapshot = await firestore.collection('teams').get();

  for (final teamDoc in teamsSnapshot.docs) {
    final teamId = teamDoc.id;
    final teamData = teamDoc.data();
    final members = teamData['members'] as List<dynamic>? ?? [];

    for (final memberUid in members) {
      final userRef = firestore.collection('users').doc(memberUid);
      await userRef.update({
        'teams': FieldValue.arrayUnion([teamId])
      });
    }
  }

  print('Sincronización de equipos con usuarios completada.');
}
