// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamFirestoreService {
  // Referencia a la colección de equipos
  final CollectionReference teams =
      FirebaseFirestore.instance.collection('teams');

  // CREATE - Crear un equipo con tipo
  Future<void> createTeam(String teamName, String type) {
    // Obtenemos el usuario actual en el momento de la llamada
    final currentUser = FirebaseAuth.instance.currentUser;
    return teams.add({
      'name': teamName,
      'type': type, // Guarda el tipo de equipo
      'createdBy': currentUser?.uid,
      'members': [currentUser?.uid],
      'timestamp': Timestamp.now()
    });
  }

  // READ - Obtener equipos donde el usuario es miembro
  Stream<QuerySnapshot> getTeams() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return FirebaseFirestore.instance
          .collection('empty_collection_for_null_user')
          .snapshots();
    }

    return teams.where('members', arrayContains: currentUser.uid).snapshots();
  }

  // UPDATE - Actualizar nombre del equipo
  Future<void> updateTeamName(String docId, String newName) {
    return teams.doc(docId).update({
      'name': newName,
    });
  }

  // UPDATE - Añadir miembro al equipo con validación de máximo
  Future<void> addMember(String docId, String memberId) async {
    // Verifica si el usuario existe en la colección 'users'
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(memberId)
        .get();
    if (!userDoc.exists) {
      throw Exception('El usuario no existe.');
    }

    final doc = await teams.doc(docId).get();
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'];
    final members = List<String>.from(data['members'] ?? []);
    final maxMembers = type == 'futbolito' ? 10 : 16;

    if (members.length >= maxMembers) {
      throw Exception(
          'Este equipo ya tiene el máximo de integrantes permitidos.');
    }

    await teams.doc(docId).update({
      'members': FieldValue.arrayUnion([memberId])
    });
  }

  // UPDATE - Eliminar miembro del equipo
  Future<void> removeMember(String docId, String memberId) {
    return teams.doc(docId).update({
      'members': FieldValue.arrayRemove([memberId])
    });
  }

  // DELETE - Eliminar un equipo
  Future<void> deleteTeam(String docId) {
    return teams.doc(docId).delete();
  }
}
