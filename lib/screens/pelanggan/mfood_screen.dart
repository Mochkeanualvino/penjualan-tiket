import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/theme.dart';

class MFoodScreen extends StatefulWidget {
  const MFoodScreen({super.key});

  @override
  State<MFoodScreen> createState() => _MFoodScreenState();
}

class _MFoodScreenState extends State<MFoodScreen> {
  final List<Map<String, dynamic>> _foodItems = [
    {
      'name': 'Popcorn Salt Medium',
      'price': 35000,
      'category': 'Popcorn',
      'img': 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=200&auto=format&fit=crop'
    },
    {
      'name': 'Popcorn Caramel Large',
      'price': 55000,
      'category': 'Popcorn',
      'img': 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=200&auto=format&fit=crop'
    },
    {
      'name': 'Coca Cola / Fanta / Sprite',
      'price': 25000,
      'category': 'Minuman',
      'img': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=200&auto=format&fit=crop'
    },
    {
      'name': 'Hotdog Beef Signature',
      'price': 40000,
      'category': 'Makanan',
      'img': 'https://images.unsplash.com/photo-1619740455993-9e612b1af08a?q=80&w=200&auto=format&fit=crop'
    },
    {
      'name': 'French Fries Crispy',
      'price': 30000,
      'category': 'Camilan',
      'img': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?q=80&w=200&auto=format&fit=crop'
    },
    {
      'name': 'Combopack (Popcorn + Drink)',
      'price': 70000,
      'category': 'Paket',
      'img': 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=200&auto=format&fit=crop'
    },
  ];

  final Map<String, int> _cart = {};

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
    int totalItems = _cart.values.fold(0, (sum, count) => sum + count);
    int totalBayar = 0;
    _cart.forEach((name, count) {
      final item = _foodItems.firstWhere((element) => element['name'] == name);
      totalBayar += (item['price'] as int) * count;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('m.food XXI', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _foodItems.length,
              itemBuilder: (ctx, index) {
                final item = _foodItems[index];
                final name = item['name'] as String;
                final count = _cart[name] ?? 0;

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            item['img'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, _, __) => Container(
                              color: AppTheme.cardBgLight,
                              child: const Icon(Icons.fastfood, color: AppTheme.primaryGold),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${item['price']}',
                              style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
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
                                      onPressed: () => _addToCart(name),
                                      child: const Text('Tambah', style: TextStyle(fontSize: 12)),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryGold, size: 24),
                                        onPressed: () => _removeFromCart(name),
                                      ),
                                      Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGold, size: 24),
                                        onPressed: () => _addToCart(name),
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
                        Text('Rp $totalBayar', style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _cart.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pesanan m.food sukses dibuat! Silakan ambil di kasir bioskop.'),
                            backgroundColor: AppTheme.accentGreen,
                          ),
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
    );
  }
}
