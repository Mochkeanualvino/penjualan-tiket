class FoodModel {
  final String id;
  final String nama;
  final double harga;
  final String kategori;
  final String imageUrl;
  final String diskonHari; // Hari tertentu diskon: e.g. "Jumat", "Senin", "Semua"
  final int diskonPersen; // e.g. 20 => 20% diskon

  FoodModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.kategori,
    required this.imageUrl,
    this.diskonHari = '',
    this.diskonPersen = 0,
  });

  double get hargaSetelahDiskon {
    if (diskonPersen <= 0) return harga;
    return harga - (harga * diskonPersen / 100);
  }

  factory FoodModel.fromMap(Map<String, dynamic> map, String docId) {
    return FoodModel(
      id: docId,
      nama: map['nama'] ?? map['name'] ?? '',
      harga: (map['harga'] ?? map['price'] ?? 0).toDouble(),
      kategori: map['kategori'] ?? map['category'] ?? 'Makanan',
      imageUrl: map['imageUrl'] ?? map['img'] ?? '',
      diskonHari: map['diskonHari'] ?? '',
      diskonPersen: map['diskonPersen'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'harga': harga,
      'kategori': kategori,
      'imageUrl': imageUrl,
      'diskonHari': diskonHari,
      'diskonPersen': diskonPersen,
    };
  }
}

class FoodOrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final List<Map<String, dynamic>> items; // [{nama, count, harga, subtotal}]
  final double totalHarga;
  final String status;
  final DateTime tanggal;

  FoodOrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalHarga,
    required this.status,
    required this.tanggal,
  });

  factory FoodOrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return FoodOrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalHarga: (map['totalHarga'] ?? 0).toDouble(),
      status: map['status'] ?? 'Diproses',
      tanggal: DateTime.tryParse(map['tanggal'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'items': items,
      'totalHarga': totalHarga,
      'status': status,
      'tanggal': tanggal.toIso8601String(),
    };
  }
}
