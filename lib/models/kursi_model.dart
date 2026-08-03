class KursiModel {
  final String id;
  final String studioId;
  final String namaStudio;
  final String nomorKursi;
  final String status; // 'Tersedia' or 'Dipesan'

  KursiModel({
    required this.id,
    required this.studioId,
    required this.namaStudio,
    required this.nomorKursi,
    required this.status,
  });

  bool get isTersedia => status.toLowerCase() == 'tersedia';

  factory KursiModel.fromMap(Map<String, dynamic> map, String docId) {
    return KursiModel(
      id: docId,
      studioId: map['studioId'] ?? '',
      namaStudio: map['namaStudio'] ?? '',
      nomorKursi: map['nomorKursi'] ?? '',
      status: map['status'] ?? 'Tersedia',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studioId': studioId,
      'namaStudio': namaStudio,
      'nomorKursi': nomorKursi,
      'status': status,
    };
  }
}
