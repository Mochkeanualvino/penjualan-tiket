class PembayaranModel {
  final String id;
  final String transaksiId;
  final String metode; // 'Midtrans Snap', 'Transfer Bank', 'QRIS', 'E-Wallet'
  final String status; // 'Pending', 'Berhasil', 'Gagal'
  final double jumlah;
  final DateTime tanggalPembayaran;
  final String? snapToken;
  final String? orderId;
  final String? vaNumber;

  PembayaranModel({
    required this.id,
    required this.transaksiId,
    required this.metode,
    required this.status,
    required this.jumlah,
    required this.tanggalPembayaran,
    this.snapToken,
    this.orderId,
    this.vaNumber,
  });

  factory PembayaranModel.fromMap(Map<String, dynamic> map, String docId) {
    return PembayaranModel(
      id: docId,
      transaksiId: map['transaksiId'] ?? '',
      metode: map['metode'] ?? 'Midtrans Snap',
      status: map['status'] ?? 'Pending',
      jumlah: (map['jumlah'] ?? 0.0).toDouble(),
      tanggalPembayaran: map['tanggalPembayaran'] != null 
          ? (map['tanggalPembayaran'] is DateTime ? map['tanggalPembayaran'] : DateTime.parse(map['tanggalPembayaran'].toString()))
          : DateTime.now(),
      snapToken: map['snapToken'],
      orderId: map['orderId'],
      vaNumber: map['vaNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transaksiId': transaksiId,
      'metode': metode,
      'status': status,
      'jumlah': jumlah,
      'tanggalPembayaran': tanggalPembayaran.toIso8601String(),
      'snapToken': snapToken,
      'orderId': orderId,
      'vaNumber': vaNumber,
    };
  }
}
