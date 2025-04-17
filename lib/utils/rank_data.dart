class RankInfo {
  final String nombre;
  final String descripcion;

  RankInfo(this.nombre, this.descripcion);
}

final List<Map<String, dynamic>> rangos = [
  {
    'key': 'cantera',
    'info': RankInfo('Cantera', 'Aquí empieza el sueño.'),
    'requisitos': (Map<String, dynamic> stats) =>
        (stats['matchesPlayed'] ?? 0) >= 5 &&
        (stats['wins'] ?? 0) >= 2 &&
        (stats['teams'] != null && (stats['teams'] as List).isNotEmpty),
  },
  {
    'key': 'barrial',
    'info': RankInfo('Barrial', 'Ya no eres novato, ahora eres del barrio.'),
    'requisitos': (Map<String, dynamic> stats) =>
        (stats['matchesPlayed'] ?? 0) >= 10 &&
        (stats['wins'] ?? 0) >= 5 &&
        ((stats['goals'] ?? 0) >= 10),
  },
  {
    'key': 'aficionado',
    'info': RankInfo('Aficionado', 'Empieza a notarse tu talento.'),
    'requisitos': (Map<String, dynamic> stats) =>
        (stats['matchesPlayed'] ?? 0) >= 15 &&
        (stats['wins'] ?? 0) >= 7 &&
        (stats['playerOfTheMatch'] ?? 0) >= 3,
  },
  {
    'key': 'regional',
    'info': RankInfo('Regional', 'Ya dominas tu zona.'),
    'requisitos': (Map<String, dynamic> stats) =>
        (stats['matchesPlayed'] ?? 0) >= 20 &&
        (stats['wins'] ?? 0) >= 10 &&
        (stats['liveMatches'] ?? 0) >= 3,
  },
  {
    'key': 'nacional',
    'info': RankInfo('Nacional', 'Ahora todos te ven jugar.'),
    'requisitos': (Map<String, dynamic> stats) =>
        (stats['matchesPlayed'] ?? 0) >= 30 &&
        (stats['wins'] ?? 0) >= 15 &&
        (stats['teamMembers'] ?? 0) >= 5,
  },
  {
    'key': 'leyenda',
    'info': RankInfo('Leyenda', 'Tu nombre está en los libros.'),
    'requisitos': (Map<String, dynamic> stats) =>
        (stats['matchesPlayed'] ?? 0) >= 50 &&
        (stats['wins'] ?? 0) >= 30 &&
        ((stats['goals'] ?? 0) +
                    (stats['assists'] ?? 0) +
                    (stats['playerOfTheMatch'] ?? 0)) /
                ((stats['matchesPlayed'] ?? 1)) >
            1.5,
  },
  {
    'key': 'idolo',
    'info': RankInfo('Ídolo', 'Eres inspiración para otros.'),
    'requisitos': (Map<String, dynamic> stats) =>
        (stats['isTop5Percent'] == true) &&
        (stats['featuredMatches'] ?? 0) >= 5,
  },
  {
    'key': 'elite',
    'info': RankInfo('Élite', 'Los mejores entre los mejores.'),
    'requisitos': (Map<String, dynamic> stats) =>
        (stats['isTop50World'] == true),
  },
];

RankInfo getRangoPorStats(Map<String, dynamic> stats) {
  for (final rango in rangos.reversed) {
    if ((rango['requisitos'] as bool Function(Map<String, dynamic>))(stats)) {
      return rango['info'] as RankInfo;
    }
  }
  // Si no cumple ninguno, retorna el primero (Cantera)
  return rangos.first['info'] as RankInfo;
}
