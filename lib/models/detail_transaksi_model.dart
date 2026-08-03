class DetailTransaksiModel {
  final String id;
  final String transaksiId;
  final String jadwalId;
  final String kursiId;
  final String nomorKursi;
  final double harga;

  DetailTransaksiModel({
    required this.id,
    required this.transaksiId,
    required this.jadwalId,
    required this.kursiId,
    required this.nomorKursi,
    required this.harga,
  });

  factory DetailTransaksiModel.fromMap(Map<String, dynamic> map, String docId) {
    return DetailTransaksiModel(
      id: docId,
      transaksiId: map['transaksiId'] ?? '',
      jadwalId: map['jadwalId'] ?? '',
      kursiId: map['kursiId'] ?? '',
      nomorKursi: map['nomorKursi'] ?? '',
      harga: (map['harga'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transaksiId': transaksiId,
      'jadwalId': jadwalId,
      'kursiId': kursiId,
      'nomorKursi': nomorKursi,
      'harga': harga,
    };
  }
}
