class PromoModel {
  final String code;
  final String title;
  final String description;
  final double discountPercent;
  final double maxDiscount;
  final double flatDiscount;
  final double minPurchase;
  final String category; // 'ALL', 'TICKET', 'FOOD'
  final String badge;

  const PromoModel({
    required this.code,
    required this.title,
    required this.description,
    this.discountPercent = 0,
    this.maxDiscount = 0,
    this.flatDiscount = 0,
    this.minPurchase = 0,
    this.category = 'ALL',
    this.badge = 'Promo',
  });

  /// Hitung besaran diskon yang didapat berdasarkan nominal transaksi
  double calculateDiscount(double totalAmount, String type) {
    if (totalAmount < minPurchase) return 0;
    if (category != 'ALL' && category != type) return 0;

    double discount = 0;
    if (flatDiscount > 0) {
      discount = flatDiscount;
    } else if (discountPercent > 0) {
      discount = totalAmount * discountPercent;
      if (maxDiscount > 0 && discount > maxDiscount) {
        discount = maxDiscount;
      }
    }
    return discount > totalAmount ? totalAmount : discount;
  }
}

class PromoService {
  static const List<PromoModel> availablePromos = [
    PromoModel(
      code: 'KENTICKET20',
      title: 'KENTICKET SPECIAL 20%',
      description: 'Diskon 20% tanpa minimal pembelian untuk semua tiket & makanan.',
      discountPercent: 0.20,
      minPurchase: 0,
      category: 'ALL',
      badge: '20% OFF',
    ),
    PromoModel(
      code: 'CINESTAR20',
      title: 'KENTICKET BONUS 20%',
      description: 'Diskon 20% tanpa minimal pembelian untuk semua tiket & makanan.',
      discountPercent: 0.20,
      minPurchase: 0,
      category: 'ALL',
      badge: '20% OFF',
    ),
    PromoModel(
      code: 'HEMAT50',
      title: 'MIDNIGHT MADNESS 50%',
      description: 'Diskon 50% maks. Rp 25.000 dengan min. transaksi Rp 40.000.',
      discountPercent: 0.50,
      maxDiscount: 25000,
      minPurchase: 40000,
      category: 'TICKET',
      badge: 'Diskon 50%',
    ),
    PromoModel(
      code: 'MAKANHEMAT',
      title: 'M.FOOD VOUCHER 15K',
      description: 'Potongan Rp 15.000 khusus pesanan m.food min. Rp 30.000.',
      flatDiscount: 15000,
      minPurchase: 30000,
      category: 'FOOD',
      badge: 'Potongan 15rb',
    ),
    PromoModel(
      code: 'BCA10K',
      title: 'PROMO BCA 10K',
      description: 'Potongan Rp 10.000 untuk transaksi dengan metode BCA.',
      flatDiscount: 10000,
      minPurchase: 30000,
      category: 'ALL',
      badge: 'BCA Special',
    ),
  ];

  static PromoModel? findByCode(String code) {
    try {
      return availablePromos.firstWhere(
        (p) => p.code.toUpperCase() == code.trim().toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
