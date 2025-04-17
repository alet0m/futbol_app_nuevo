import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  static Future<void> createMatch({
    required String teamA,
    required String teamB,
    required String teamAName,
    required String teamBName,
    required DateTime date,
    required String location,
    required String tipo,
    required String modalidad,
    required int duracion,
    required int entretiempo,
    required int jugadoresPorEquipo,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final match = {
      'teamA': teamA,
      'teamB': teamB,
      'teamAName': teamAName,
      'teamBName': teamBName,
      'createdBy': user.uid,
      'date': date,
      'location': location,
      'status': 'pending',
      'acceptedByA': true,
      'acceptedByB': false,
      'scoreA': 0,
      'scoreB': 0,
      'events': [],
      'createdAt': DateTime.now(),
      'tipo': tipo,
      'modalidad': modalidad,
      'duracion': duracion,
      'entretiempo': entretiempo,
      'jugadoresPorEquipo': jugadoresPorEquipo,
    };

    await FirebaseFirestore.instance.collection('matches').add(match);
  }
}
