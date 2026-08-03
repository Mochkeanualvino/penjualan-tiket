class JadwalModel {
  final String id;
  final String filmId;
  final String judulFilm;
  final String posterUrl;
  final String studioId;
  final String namaStudio;
  final DateTime tanggal;
  final String jam; // e.g. "14:30"
  final double hargaTiket;

  JadwalModel({
    required this.id,
    required this.filmId,
    required this.judulFilm,
    required this.posterUrl,
    required this.studioId,
    required this.namaStudio,
    required this.tanggal,
    required this.jam,
    required this.hargaTiket,
  });

  factory JadwalModel.fromMap(Map<String, dynamic> map, String docId) {
    return JadwalModel(
      id: docId,
      filmId: map['filmId'] ?? '',
      judulFilm: map['judulFilm'] ?? '',
      posterUrl: map['posterUrl'] ?? '',
      studioId: map['studioId'] ?? '',
      namaStudio: map['namaStudio'] ?? '',
      tanggal: map['tanggal'] != null 
          ? (map['tanggal'] is DateTime ? map['tanggal'] : DateTime.parse(map['tanggal'].toString())) 
          : DateTime.now(),
      jam: map['jam'] ?? '12:00',
      hargaTiket: (map['hargaTiket'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'filmId': filmId,
      'judulFilm': judulFilm,
      'posterUrl': posterUrl,
      'studioId': studioId,
      'namaStudio': namaStudio,
      'tanggal': tanggal.toIso8601String(),
      'jam': jam,
      'hargaTiket': hargaTiket,
    };
  }
}
