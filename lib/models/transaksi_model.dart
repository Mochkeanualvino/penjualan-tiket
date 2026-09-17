import 'pembayaran_model.dart';

class TransaksiModel {
  final String id;
  final String userId;
  final String userEmail;
  final String filmJudul;
  final String posterUrl;
  final String namaStudio;
  final DateTime tanggalTayang;
  final String jamTayang;
  final List<String> daftarKursi;
  final double totalHarga;
  final String status; // 'Pending', 'Berhasil', 'Dibatalkan'
  final DateTime tanggalTransaksi;
  final PembayaranModel? pembayaran;
  final bool isUsed;
  final DateTime? usedAt;

  TransaksiModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.filmJudul,
    required this.posterUrl,
    required this.namaStudio,
    required this.tanggalTayang,
    required this.jamTayang,
    required this.daftarKursi,
    required this.totalHarga,
    required this.status,
    required this.tanggalTransaksi,
    this.pembayaran,
    this.isUsed = false,
    this.usedAt,
  });

  factory TransaksiModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransaksiModel(
      id: docId,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      filmJudul: map['filmJudul'] ?? '',
      posterUrl: map['posterUrl'] ?? '',
      namaStudio: map['namaStudio'] ?? '',
      tanggalTayang: map['tanggalTayang'] != null 
          ? (map['tanggalTayang'] is DateTime ? map['tanggalTayang'] : DateTime.parse(map['tanggalTayang'].toString()))
          : DateTime.now(),
      jamTayang: map['jamTayang'] ?? '',
      daftarKursi: List<String>.from(map['daftarKursi'] ?? []),
      totalHarga: (map['totalHarga'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Pending',
      tanggalTransaksi: map['tanggalTransaksi'] != null 
          ? (map['tanggalTransaksi'] is DateTime ? map['tanggalTransaksi'] : DateTime.parse(map['tanggalTransaksi'].toString()))
          : DateTime.now(),
      pembayaran: map['pembayaran'] != null 
          ? PembayaranModel.fromMap(Map<String, dynamic>.from(map['pembayaran']), map['pembayaran']['id'] ?? '') 
          : null,
      isUsed: map['isUsed'] == true || map['is_used'] == 1,
      usedAt: map['usedAt'] != null 
          ? (map['usedAt'] is DateTime ? map['usedAt'] : DateTime.tryParse(map['usedAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'filmJudul': filmJudul,
      'posterUrl': posterUrl,
      'namaStudio': namaStudio,
      'tanggalTayang': tanggalTayang.toIso8601String(),
      'jamTayang': jamTayang,
      'daftarKursi': daftarKursi,
      'totalHarga': totalHarga,
      'status': status,
      'tanggalTransaksi': tanggalTransaksi.toIso8601String(),
      'pembayaran': pembayaran?.toMap(),
      'isUsed': isUsed,
      'usedAt': usedAt?.toIso8601String(),
    };
  }
}
