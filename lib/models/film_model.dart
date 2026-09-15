class FilmModel {
  final String id;
  final String judul;
  final String genre;
  final int durasi; // in minutes
  final String ratingUsia; // e.g. "SU", "13+", "17+", "21+"
  final String posterUrl;
  final bool isSegeraTayang;
  final String sinopsis;
  final String sutradara;
  final String pemeran;
  final String trailerUrl;

  FilmModel({
    required this.id,
    required this.judul,
    required this.genre,
    required this.durasi,
    required this.ratingUsia,
    required this.posterUrl,
    this.isSegeraTayang = false,
    this.sinopsis = '',
    this.sutradara = '',
    this.pemeran = '',
    this.trailerUrl = '',
  });

  factory FilmModel.fromMap(Map<String, dynamic> map, String docId) {
    int parsedDurasi = 0;
    if (map['durasi'] != null) {
      if (map['durasi'] is int) {
        parsedDurasi = map['durasi'];
      } else if (map['durasi'] is num) {
        parsedDurasi = (map['durasi'] as num).toInt();
      } else {
        final clean = map['durasi'].toString().replaceAll(RegExp(r'[^0-9]'), '');
        parsedDurasi = int.tryParse(clean) ?? 0;
      }
    }

    return FilmModel(
      id: docId,
      judul: map['judul'] ?? '',
      genre: map['genre'] ?? '',
      durasi: parsedDurasi,
      ratingUsia: map['ratingUsia'] ?? 'SU',
      posterUrl: map['posterUrl'] ?? '',
      isSegeraTayang: map['isSegeraTayang'] == true || map['is_segera_tayang'] == true || map['is_segera_tayang'] == 1,
      sinopsis: map['sinopsis'] ?? '',
      sutradara: map['sutradara'] ?? '',
      pemeran: map['pemeran'] ?? '',
      trailerUrl: map['trailerUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'genre': genre,
      'durasi': durasi,
      'ratingUsia': ratingUsia,
      'posterUrl': posterUrl,
      'isSegeraTayang': isSegeraTayang,
      'sinopsis': sinopsis,
      'sutradara': sutradara,
      'pemeran': pemeran,
      'trailerUrl': trailerUrl,
    };
  }
}
