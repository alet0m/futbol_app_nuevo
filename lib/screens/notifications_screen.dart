// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('NotificationsScreen build ejecutado');
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final requestsStream = FirebaseFirestore.instance
        .collection('friend_requests')
        .where('to', isEqualTo: currentUid)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
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
              final data = request.data() as Map<String, dynamic>?;
              final isConfirmation = data != null &&
                  data.containsKey('confirmation') &&
                  data['confirmation'] == true;
              print('Renderizando botón aceptar para solicitud de: $fromUid');
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UID: $fromUid'),
                    if (isConfirmation)
                      const Text(
                        'Confirmación: este usuario quiere agregarte como amigo. Acepta para que ambos sean amigos.',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Aceptar',
                      onPressed: () async {
                        print('Botón aceptar presionado. fromUid: $fromUid');
                        await FirebaseFirestore.instance
                            .collection('friend_requests')
                            .doc(request.id)
                            .update({'status': 'accepted'});

                        final currentUid =
                            FirebaseAuth.instance.currentUser?.uid;
                        if (currentUid != null) {
                          // Agrega a A en la lista de amigos de B
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUid)
                              .update({
                            'friends': FieldValue.arrayUnion([fromUid])
                          });

                          // Crea una solicitud de amistad de confirmación de B a A si no existe
                          final reverseRequest = await FirebaseFirestore
                              .instance
                              .collection('friend_requests')
                              .where('from', isEqualTo: currentUid)
                              .where('to', isEqualTo: fromUid)
                              .get();

                          if (reverseRequest.docs.isEmpty) {
                            await FirebaseFirestore.instance
                                .collection('friend_requests')
                                .add({
                              'from': currentUid,
                              'to': fromUid,
                              'status': 'pending',
                              'timestamp': FieldValue.serverTimestamp(),
                              'confirmation':
                                  true, // Campo especial para identificar la confirmación
                            });
                            print(
                                'Solicitud de amistad de confirmación enviada');
                          }
                          print('Amigo agregado directamente');
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Amistad aceptada. Se ha enviado una confirmación de amistad al otro usuario.')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Rechazar',
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('friend_requests')
                            .doc(request.id)
                            .update({'status': 'rejected'});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Solicitud rechazada')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
