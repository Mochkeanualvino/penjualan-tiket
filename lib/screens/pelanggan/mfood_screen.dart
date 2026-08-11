import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

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
      if (_cart.containsKey(name) && _cart[name]! > 0) {
        _cart[name] = _cart[name]! - 1;
        if (_cart[name] == 0) {
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

    int totalItems = _cart.values.fold(0, (sum, count) => sum + count);
    double totalBayar = 0;
    _cart.forEach((name, count) {
      try {
        final item = foodProvider.foods.firstWhere((element) => element.nama == name);
        totalBayar += item.hargaSetelahDiskon * count;
      } catch (_) {}
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('m.food XXI', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGold,
          labelColor: AppTheme.primaryGold,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: [
            const Tab(icon: Icon(Icons.fastfood), text: 'Menu Makanan'),
            Tab(icon: const Icon(Icons.history), text: 'Riwayat (${myOrders.length})'),
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
                child: foodProvider.foods.isEmpty
                    ? const Center(
                        child: Text('Belum ada menu makanan tersedia.', style: TextStyle(color: AppTheme.textMuted)),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: foodProvider.foods.length,
                        itemBuilder: (ctx, index) {
                          final item = foodProvider.foods[index];
                          final count = _cart[item.nama] ?? 0;
                          final hasDiskon = item.diskonPersen > 0;

                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: SizedBox(
                                        height: 110,
                                        width: double.infinity,
                                        child: Image.network(
                                          item.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, _, __) => Container(
                                            color: AppTheme.cardBgLight,
                                            child: const Icon(Icons.fastfood, color: AppTheme.primaryGold, size: 40),
                                          ),
                                        ),
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
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'PROMO ${item.diskonPersen}%',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
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
                          onPressed: () async {
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

                            await foodProvider.createFoodOrder(
                              userId: currentUser?.id ?? 'user_1',
                              userEmail: currentUser?.email ?? 'pelanggan@bioskop.com',
                              items: orderItems,
                              totalHarga: totalBayar,
                            );

                            setState(() {
                              _cart.clear();
                              _tabController.animateTo(1); // Swtich ke Tab Riwayat
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🎉 Pesanan m.food berhasil disimpan ke Riwayat! Silakan ambil di kasir.'),
                                  backgroundColor: AppTheme.accentGreen,
                                ),
                              );
                            }
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
                                  child: Text(
                                    order.status,
                                    style: const TextStyle(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.bold),
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
}
