import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/theme.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final promos = [
      {
        'title': 'TUESDATE PROMO',
        'desc': 'Diskon 50% untuk tiket kedua setiap hari Selasa! Ajak pasangan atau sahabatmu nonton bareng.',
        'badge': 'Setiap Selasa',
        'icon': Icons.local_offer,
        'color': AppTheme.primaryGold,
      },
      {
        'title': 'MIDNIGHT MADNESS',
        'desc': 'Nonton film horor tengah malam hanya Rp25.000! Berlaku setiap Jumat & Sabtu.',
        'badge': 'Weekend Only',
        'icon': Icons.nightlight_round,
        'color': Colors.purpleAccent,
      },
      {
        'title': 'STUDENT DEAL',
        'desc': 'Tunjukkan kartu pelajar/mahasiswa dan dapatkan diskon 30% tiket Regular 2D!',
        'badge': 'Weekday',
        'icon': Icons.school,
        'color': AppTheme.accentBlue,
      },
      {
        'title': 'BCA CARD PROMO',
        'desc': 'Buy 1 Get 1 Free untuk pemegang kartu BCA. Berlaku di semua Cinema XXI.',
        'badge': 'Limited',
        'icon': Icons.credit_card,
        'color': AppTheme.accentGreen,
      },
      {
        'title': 'M.TIX POINTS DOUBLE',
        'desc': 'Dapatkan poin 2x lipat setiap transaksi melalui m.tix! Tukarkan poin dengan hadiah menarik.',
        'badge': 'Juli 2026',
        'icon': Icons.card_giftcard,
        'color': Colors.orangeAccent,
      },
      {
        'title': 'PREMIERE NIGHT',
        'desc': 'Nonton perdana film blockbuster di Studio IMAX, lengkap dengan snack box eksklusif.',
        'badge': 'Pre-order',
        'icon': Icons.star,
        'color': Colors.amberAccent,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promo & Penawaran',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Jangan lewatkan promo terbaik dari Cinema XXI!',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ...promos.map((promo) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (promo['color'] as Color).withAlpha(30),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(promo['icon'] as IconData, color: promo['color'] as Color, size: 28),
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
                                  promo['title'] as String,
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
                                  promo['badge'] as String,
                                  style: const TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            promo['desc'] as String,
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
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
