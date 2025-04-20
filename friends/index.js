/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const {onDocumentWritten} = require("firebase-functions/v2/firestore");

exports.onFriendAdded = onDocumentWritten("/friends/{friendId}", (event) => {
  const friend = event.data;
  logger.info("New friend added:", friend);
});

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onFriendRequestAccepted = functions.firestore
  .document('friend_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Solo actúa si el status cambió a 'accepted'
    if (before.status !== 'accepted' && after.status === 'accepted') {
      const fromUid = after.from;
      const toUid = after.to;

      const usersRef = admin.firestore().collection('users');

      // Agrega cada uno al campo friends del otro
      await usersRef.doc(fromUid).update({
        friends: admin.firestore.FieldValue.arrayUnion(toUid)
      });
      await usersRef.doc(toUid).update({
        friends: admin.firestore.FieldValue.arrayUnion(fromUid)
      });
    }
    return null;
  });
