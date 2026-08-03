class FilmModel {
  final String id;
  final String judul;
  final String genre;
  final int durasi; // in minutes
  final String ratingUsia; // e.g. "SU", "13+", "17+", "21+"
  final String posterUrl;

  FilmModel({
    required this.id,
    required this.judul,
    required this.genre,
    required this.durasi,
    required this.ratingUsia,
    required this.posterUrl,
  });

  factory FilmModel.fromMap(Map<String, dynamic> map, String docId) {
    return FilmModel(
      id: docId,
      judul: map['judul'] ?? '',
      genre: map['genre'] ?? '',
      durasi: (map['durasi'] ?? 0) is int ? (map['durasi'] ?? 0) : int.parse(map['durasi'].toString()),
      ratingUsia: map['ratingUsia'] ?? 'SU',
      posterUrl: map['posterUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'genre': genre,
      'durasi': durasi,
      'ratingUsia': ratingUsia,
      'posterUrl': posterUrl,
    };
  }
}
