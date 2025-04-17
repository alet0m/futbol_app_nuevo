import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  static Future<void> sendFriendRequest(String toUid) async {
    final fromUid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('friend_requests').add({
      'from': fromUid,
      'to': toUid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getFriendRequests() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('friend_requests')
        .where('to', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  static Future<void> respondToRequest(String requestId, String response) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .update({'status': response});
  }

  static Future<void> addFriend(String uid1, String uid2) async {
    final users = FirebaseFirestore.instance.collection('users');
    await users.doc(uid1).update({
      'friends': FieldValue.arrayUnion([uid2])
    });
    await users.doc(uid2).update({
      'friends': FieldValue.arrayUnion([uid1])
    });
  }
}