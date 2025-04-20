import 'package:cloud_firestore/cloud_firestore.dart';

class FriendService {
  static Future<void> addFriend(String uid1, String uid2) async {
    final users = FirebaseFirestore.instance.collection('users');
    await users.doc(uid1).update({
      'friends': FieldValue.arrayUnion([uid2])
    });
    await users.doc(uid2).update({
      'friends': FieldValue.arrayUnion([uid1])
    });
  }

  // ...otras funciones...
}