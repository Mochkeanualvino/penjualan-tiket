import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/promo_model.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final promos = PromoService.availablePromos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promo & Voucher XXI',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gunakan kode promo saat pembayaran tiket atau makanan m.food!',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ...promos.map((promo) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold.withAlpha(30),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.local_offer, color: AppTheme.primaryGold, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      promo.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGold.withAlpha(30),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppTheme.primaryGold.withAlpha(80)),
                                    ),
                                    child: Text(
                                      promo.badge,
                                      style: const TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                promo.description,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                              if (promo.minPurchase > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Min. Pembelian: ${Formatters.currency(promo.minPurchase)}',
                                  style: const TextStyle(color: AppTheme.primaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primaryGold.withAlpha(100)),
                          ),
                          child: Text(
                            'KODE: ${promo.code}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGold, letterSpacing: 1),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: promo.code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('📋 Kode Promo "${promo.code}" disalin! Tempelkan di halaman pembayaran.'),
                                backgroundColor: AppTheme.accentGreen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16, color: AppTheme.primaryGold),
                          label: const Text('SALIN KODE', style: TextStyle(color: AppTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryGold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
