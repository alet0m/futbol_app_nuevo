// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeFriendsFieldForAllUsers() async {
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final usersSnapshot = await usersCollection.get();

  for (var doc in usersSnapshot.docs) {
    final data = doc.data();
    if (!data.containsKey('friends')) {
      try {
        await usersCollection.doc(doc.id).update({'friends': []});
        print('Campo friends inicializado para usuario: ${doc.id}');
      } catch (e) {
        print('Error al actualizar usuario ${doc.id}: $e');
      }
    } else {
      print('Usuario ${doc.id} ya tiene campo friends');
    }
  }
  print('Inicialización terminada.');
}
