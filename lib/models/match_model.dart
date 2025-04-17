import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final String teamA;
  final String teamB;
  final String teamAName;
  final String teamBName;
  final String createdBy;
  final DateTime date;
  final String location;
  final String status;
  final bool acceptedByA;
  final bool acceptedByB;
  final int scoreA;
  final int scoreB;
  final List<dynamic> events;
  final DateTime createdAt;

  MatchModel({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.teamAName,
    required this.teamBName,
    required this.createdBy,
    required this.date,
    required this.location,
    required this.status,
    required this.acceptedByA,
    required this.acceptedByB,
    required this.scoreA,
    required this.scoreB,
    required this.events,
    required this.createdAt,
  });

  factory MatchModel.fromMap(String id, Map<String, dynamic> data) {
    return MatchModel(
      id: id,
      teamA: data['teamA'],
      teamB: data['teamB'],
      teamAName: data['teamAName'],
      teamBName: data['teamBName'],
      createdBy: data['createdBy'],
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      status: data['status'],
      acceptedByA: data['acceptedByA'],
      acceptedByB: data['acceptedByB'],
      scoreA: data['scoreA'],
      scoreB: data['scoreB'],
      events: data['events'] ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamA': teamA,
      'teamB': teamB,
      'teamAName': teamAName,
      'teamBName': teamBName,
      'createdBy': createdBy,
      'date': date,
      'location': location,
      'status': status,
      'acceptedByA': acceptedByA,
      'acceptedByB': acceptedByB,
      'scoreA': scoreA,
      'scoreB': scoreB,
      'events': events,
      'createdAt': createdAt,
    };
  }
}
