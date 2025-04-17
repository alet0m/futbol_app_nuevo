import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeUserAndTeamStats() async {
  final firestore = FirebaseFirestore.instance;

  // Actualiza todos los usuarios
  final users = await firestore.collection('users').get();
  for (final doc in users.docs) {
    final data = doc.data();
    await doc.reference.set({
      'stats': {
        "pointsClasificatoria": data['stats']?['pointsClasificatoria'] ?? 0,
        "pointsCasual": data['stats']?['pointsCasual'] ?? 0,
        "matchesPlayed": data['stats']?['matchesPlayed'] ?? 0,
        "goals": data['stats']?['goals'] ?? 0,
        "assists": data['stats']?['assists'] ?? 0,
        "wins": data['stats']?['wins'] ?? 0,
        "losses": data['stats']?['losses'] ?? 0,
        "yellowCards": data['stats']?['yellowCards'] ?? 0,
        "redCards": data['stats']?['redCards'] ?? 0,
        "minutesPlayed": data['stats']?['minutesPlayed'] ?? 0,
        "playerOfTheMatch": data['stats']?['playerOfTheMatch'] ?? 0
      }
    }, SetOptions(merge: true));
  }

  // Actualiza todos los equipos
  final teams = await firestore.collection('teams').get();
  for (final doc in teams.docs) {
    final data = doc.data();
    await doc.reference.set({
      'stats': {
        "pointsClasificatoria": data['stats']?['pointsClasificatoria'] ?? 0,
        "pointsCasual": data['stats']?['pointsCasual'] ?? 0,
        "matchesPlayed": data['stats']?['matchesPlayed'] ?? 0,
        "goals": data['stats']?['goals'] ?? 0,
        "goalsAgainst": data['stats']?['goalsAgainst'] ?? 0,
        "wins": data['stats']?['wins'] ?? 0,
        "draws": data['stats']?['draws'] ?? 0,
        "losses": data['stats']?['losses'] ?? 0
      }
    }, SetOptions(merge: true));
  }

  // ignore: avoid_print
  print('Usuarios y equipos actualizados correctamente.');
}
