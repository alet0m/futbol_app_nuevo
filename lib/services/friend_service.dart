// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  static Future<void> sendFriendRequest(String toUid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null || currentUid == toUid) return;

    // Verifica que no exista ya una solicitud pendiente en ambos sentidos
    final existing = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .where('from', whereIn: [currentUid, toUid])
        .where('to', whereIn: [currentUid, toUid])
        .get();

    if (existing.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'from': currentUid,
        'to': toUid,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('ya enviaste una solicitud de amistad');
    }
  }

  static Stream<QuerySnapshot> getFriendRequests() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('friend_requests')
        .where('to', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  static Future<void> respondToRequest(
      String requestId, String response) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .update({'status': response});
  }

  static Future<void> addFriend(String otherUid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    print('addFriend called: currentUid=$currentUid, otherUid=$otherUid');
    if (currentUid == null) {
      print('No user logged in');
      return;
    }
    final users = FirebaseFirestore.instance.collection('users');
    try {
      await users.doc(currentUid).update({
        'friends': FieldValue.arrayUnion([otherUid])
      });
      print('Successfully added $otherUid to $currentUid friends');
    } catch (e) {
      print('Error updating friends: $e');
    }
  }
}
