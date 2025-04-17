// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/friend_service.dart';

class FriendRequestsScreen extends StatelessWidget {
  // ignore: use_super_parameters
  const FriendRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de amistad')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FriendService.getFriendRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return const Center(
                child: Text('No tienes solicitudes pendientes.'));
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return ListTile(
                title: Text('Solicitud de: ${request['from']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        FriendService.respondToRequest(request.id, 'accepted');
                        // Aquí puedes llamar a FriendService.addFriend si lo deseas
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        FriendService.respondToRequest(request.id, 'rejected');
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
