// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_service.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('FriendRequestsScreen build ejecutado');
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final requestsStream = FirebaseFirestore.instance
        .collection('friend_requests')
        .where('to', isEqualTo: currentUid)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de amistad'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestsStream,
        builder: (context, snapshot) {
          print('StreamBuilder ejecutado. hasData: ${snapshot.hasData}');
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data!.docs;
          print('Solicitudes pendientes encontradas: ${requests.length}');
          if (requests.isEmpty) {
            return const Center(
                child: Text('No tienes solicitudes pendientes.'));
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final fromUid = request['from'];
              print('Renderizando solicitud de: $fromUid');
              return ListTile(
                title: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(fromUid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const Text('Cargando...');
                    }
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    return Text(userData['displayName'] ?? 'Sin nombre');
                  },
                ),
                subtitle: Text('UID: $fromUid'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    print('Botón aceptar presionado. fromUid: $fromUid');
                    await FirebaseFirestore.instance
                        .collection('friend_requests')
                        .doc(request.id)
                        .update({'status': 'accepted'});
                    await FriendService.addFriend(fromUid);
                    print('Solicitud aceptada y amigo agregado');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Amistad aceptada')),
                    );
                  },
                  child: const Text('Aceptar'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
