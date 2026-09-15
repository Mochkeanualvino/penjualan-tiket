import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/promo_model.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import 'notifikasi_screen.dart';
import 'midtrans_snap_screen.dart';

class MFoodScreen extends StatefulWidget {
  const MFoodScreen({super.key});

  @override
  State<MFoodScreen> createState() => _MFoodScreenState();
}

class _MFoodScreenState extends State<MFoodScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addToCart(String name) {
    setState(() {
      _cart[name] = (_cart[name] ?? 0) + 1;
    });
  }

  void _removeFromCart(String name) {
    setState(() {
      if (_cart.containsKey(name)) {
        if (_cart[name]! > 1) {
          _cart[name] = _cart[name]! - 1;
        } else {
          _cart.remove(name);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final myOrders = foodProvider.getOrdersByUser(currentUser?.id ?? 'user_1');

    int totalItems = 0;
    double totalBayar = 0;
    _cart.forEach((name, count) {
      totalItems += count;
      try {
        final item = foodProvider.foods.firstWhere((element) => element.nama == name);
        totalBayar += item.hargaSetelahDiskon * count;
      } catch (_) {}
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'm.food',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGold,
          labelColor: AppTheme.primaryGold,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu Makanan'),
            Tab(icon: Icon(Icons.history), text: 'Riwayat Pesanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: MENU MAKANAN
          Column(
            children: [
              Expanded(
                child: foodProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: foodProvider.foods.length,
                        itemBuilder: (ctx, index) {
                          final item = foodProvider.foods[index];
                          final count = _cart[item.nama] ?? 0;
                          final hasDiskon = item.diskonPersen > 0;

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        item.imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, __) => Container(
                                          color: Colors.grey.shade900,
                                          child: const Icon(Icons.fastfood, size: 48, color: AppTheme.primaryGold),
                                        ),
                                      ),
                                      if (hasDiskon)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accentRed,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${item.diskonPersen}% OFF',
                                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.nama,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            Formatters.currency(item.hargaSetelahDiskon),
                                            style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          if (hasDiskon) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              Formatters.currency(item.harga),
                                              style: const TextStyle(
                                                color: AppTheme.textMuted,
                                                fontSize: 10,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      count == 0
                                          ? SizedBox(
                                              width: double.infinity,
                                              height: 32,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                onPressed: () => _addToCart(item.nama),
                                                child: const Text('Tambah', style: TextStyle(fontSize: 12)),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryGold, size: 24),
                                                  onPressed: () => _removeFromCart(item.nama),
                                                ),
                                                Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                IconButton(
                                                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGold, size: 24),
                                                  onPressed: () => _addToCart(item.nama),
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (totalItems > 0)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    border: Border(top: BorderSide(color: AppTheme.primaryGold.withAlpha(40))),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$totalItems Item Terpilih', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            Text(Formatters.currency(totalBayar), style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final List<Map<String, dynamic>> orderItems = [];
                            _cart.forEach((name, count) {
                              try {
                                final item = foodProvider.foods.firstWhere((element) => element.nama == name);
                                orderItems.add({
                                  'nama': name,
                                  'count': count,
                                  'harga': item.hargaSetelahDiskon,
                                  'subtotal': item.hargaSetelahDiskon * count,
                                });
                              } catch (_) {}
                            });

                            _showFoodPaymentModal(
                              context,
                              foodProvider,
                              currentUser,
                              orderItems,
                              totalBayar,
                            );
                          },
                          child: const Text('PESAN SEKARANG'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // TAB 2: RIWAYAT PESANAN MFOOD
          myOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.history, size: 64, color: AppTheme.textMuted),
                      SizedBox(height: 12),
                      Text('Belum ada riwayat pesanan makanan.', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: myOrders.length,
                  itemBuilder: (ctx, index) {
                    final order = myOrders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGreen.withAlpha(40),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.accentGreen),
                                  ),
                                  child: const Text(
                                    'Berhasil',
                                    style: TextStyle(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Formatters.formatDateTime(order.tanggal),
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                            const Divider(height: 16, color: Colors.white10),
                            ...order.items.map((i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${i['count']}x ${i['nama']}', style: const TextStyle(fontSize: 13)),
                                    Text(Formatters.currency((i['subtotal'] ?? 0).toDouble()), style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 16, color: Colors.white10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  Formatters.currency(order.totalHarga),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _showFoodPaymentModal(
    BuildContext context,
    FoodProvider foodProvider,
    UserModel? currentUser,
    List<Map<String, dynamic>> orderItems,
    double initialTotal,
  ) {
    final promoCtrl = TextEditingController();

    PromoModel? appliedPromo;
    double discountAmount = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateModal) {
            final double finalTotal = (initialTotal - discountAmount) < 0 ? 0 : (initialTotal - discountAmount);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pembayaran m.food', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(color: Colors.white10),

                    // Ringkasan Pesanan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${orderItems.length} Jenis Menu Makanan', style: const TextStyle(color: AppTheme.textMuted)),
                        Text(Formatters.currency(initialTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (appliedPromo != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Promo (${appliedPromo!.code})', style: const TextStyle(color: AppTheme.accentGreen)),
                          Text('- ${Formatters.currency(discountAmount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentGreen)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Bayar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(Formatters.currency(finalTotal), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Input Promo
                    const Text('Kode Promo / Voucher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: promoCtrl,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(hintText: 'Kode promo (ex: MAKANHEMAT)', isDense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final code = promoCtrl.text.trim();
                            final promo = PromoService.findByCode(code);
                            if (promo == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('⚠️ Kode promo tidak valid.'), backgroundColor: AppTheme.accentRed),
                              );
                              return;
                            }
                            final disc = promo.calculateDiscount(initialTotal, 'FOOD');
                            if (disc <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('⚠️ Minimal pembelian ${Formatters.currency(promo.minPurchase)}'), backgroundColor: AppTheme.accentRed),
                              );
                              return;
                            }
                            setStateModal(() {
                              appliedPromo = promo;
                              discountAmount = disc;
                            });
                          },
                          child: const Text('Gunakan'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Midtrans Snap Exclusive Gateway Card
                    const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGold.withOpacity(0.15),
                            Colors.blueAccent.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.bolt, color: Colors.black, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Midtrans Payment Gateway',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'QRIS Scannable • GoPay • DANA • ShopeePay • VA Semua Bank',
                                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.verified, color: AppTheme.accentGreen, size: 20),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.qr_code_scanner, size: 16, color: AppTheme.primaryGold),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'QRIS dapat langsung di-scan oleh BCA, GoPay, OVO, DANA, dll.',
                                    style: TextStyle(fontSize: 11, color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Bayar via Midtrans
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payment, color: Colors.black),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final foodOrderId = 'MF-${DateTime.now().millisecondsSinceEpoch}';

                          Navigator.pop(ctx); // Close Bottom Sheet

                          final result = await Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MidtransSnapScreen(
                                orderId: foodOrderId,
                                grossAmount: finalTotal,
                                itemName: 'm.food - ${orderItems.map((e) => "${e['nama']} x${e['qty']}").join(", ")}',
                                customerName: currentUser?.name ?? 'Pelanggan',
                                customerEmail: currentUser?.email ?? 'customer@cinema.id',
                                customerPhone: currentUser?.phone ?? '081234567890',
                              ),
                            ),
                          );

                          final status = result is MidtransSnapResult ? result.status : (result as MidtransPaymentStatus?);

                          if ((status == MidtransPaymentStatus.success || status == MidtransPaymentStatus.pending) && mounted) {
                            await foodProvider.createFoodOrder(
                              userId: currentUser?.id ?? 'user_1',
                              userEmail: currentUser?.email ?? 'pelanggan@bioskop.com',
                              items: orderItems,
                              totalHarga: finalTotal,
                            );

                            setState(() {
                              _cart.clear();
                            });

                            NotificationService().addNotification(
                              userId: currentUser?.id ?? 'all',
                              title: '🍔 Pesanan m.food Berhasil!',
                              message: 'Pesanan m.food Anda ($foodOrderId) sebesar ${Formatters.currency(finalTotal)} telah berhasil dibayar via Midtrans Snap.',
                              icon: Icons.fastfood,
                              color: AppTheme.accentGreen,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Pesanan m.food berhasil dibayar via Midtrans!'),
                                backgroundColor: AppTheme.accentGreen,
                              ),
                            );

                            _tabController.animateTo(1); // Switch to Order History
                          }
                        },
                        label: Text(
                          'BAYAR VIA MIDTRANS - ${Formatters.currency(finalTotal)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
