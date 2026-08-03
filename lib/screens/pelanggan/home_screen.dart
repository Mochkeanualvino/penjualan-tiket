import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/film_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/film_model.dart';
import '../../utils/theme.dart';
import 'pilih_jadwal_screen.dart';
import 'bioskop_screen.dart';
import 'mfood_screen.dart';
import 'sewa_tempat_screen.dart';
import 'semua_film_screen.dart';
import 'detail_film_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filmProvider = Provider.of<FilmProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== BANNER PROMO =====
          Container(
            height: 180,
            margin: const EdgeInsets.all(16),
            child: PageView(
              children: [
                _buildBanner('PROMO SPESIAL', 'Diskon 50% untuk pembelian tiket kedua setiap hari Selasa!', Icons.local_offer),
                _buildBanner('PREMIERE NIGHT', 'Nonton perdana film terbaru di IMAX hanya di Cinema XXI', Icons.star),
                _buildBanner('M.TIX REWARDS', 'Kumpulkan poin setiap pembelian dan tukar dengan hadiah menarik', Icons.card_giftcard),
              ],
            ),
          ),

          // ===== QUICK MENU ICONS =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickMenu(context, Icons.movie_creation_outlined, 'Bioskop', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BioskopScreen()));
                }),
                _buildQuickMenu(context, Icons.theaters, 'Film', () {
                  // Already on home, scroll to film section
                }),
                _buildQuickMenu(context, Icons.fastfood_outlined, 'm.food', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MFoodScreen()));
                }),
                _buildQuickMenu(context, Icons.weekend_outlined, 'Sewa\nTempat', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SewaTempatScreen()));
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ===== LAGI TAYANG / NOW PLAYING =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lagi tayang',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SemuaFilmScreen(
                          title: 'Lagi Tayang di Bioskop',
                          films: filmProvider.films,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.grid_view_rounded, color: AppTheme.primaryGold, size: 18),
                  label: const Text('Lihat semua', style: TextStyle(color: AppTheme.primaryGold, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Film List - Lagi Tayang
          SizedBox(
            height: 310,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filmProvider.films.length,
              itemBuilder: (ctx, index) {
                final film = filmProvider.films[index];
                return _buildFilmCard(context, film, isAdvance: index < 2);
              },
            ),
          ),
          const SizedBox(height: 24),

          // ===== SEGERA TAYANG / COMING SOON =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Segera tayang',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SemuaFilmScreen(
                          title: 'Segera Tayang',
                          films: filmProvider.segeraTayang,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.grid_view_rounded, color: AppTheme.primaryGold, size: 18),
                  label: const Text('Lihat semua', style: TextStyle(color: AppTheme.primaryGold, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Film List - Segera Tayang
          SizedBox(
            height: 310,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filmProvider.segeraTayang.length,
              itemBuilder: (ctx, index) {
                final film = filmProvider.segeraTayang[index];
                return _buildFilmCard(context, film, isComingSoon: true);
              },
            ),
          ),
          const SizedBox(height: 24),

          // ===== INFO BIOSKOP SECTION =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Bioskop di ${authProvider.selectedCity}',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          ...authProvider.getCinemasForCurrentCity().take(3).map((cinema) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on, color: AppTheme.primaryGold),
                  ),
                  title: Text(cinema['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(cinema['address']!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  trailing: Text(cinema['distance']!, style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BioskopScreen()));
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBanner(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGold.withAlpha(50), AppTheme.cardBgLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGold.withAlpha(60)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGold.withAlpha(30),
            ),
            child: Icon(icon, color: AppTheme.primaryGold, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.cardBgLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryGold.withAlpha(50)),
            ),
            child: Icon(icon, color: AppTheme.primaryGold, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildFilmCard(BuildContext context, FilmModel film, {bool isAdvance = false, bool isComingSoon = false}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.primaryGold.withAlpha(40)),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailFilmScreen(film: film)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        film.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => Container(
                          color: Colors.grey.shade900,
                          child: const Center(child: Icon(Icons.movie, size: 40, color: AppTheme.primaryGold)),
                        ),
                      ),
                    ),
                    // Advance Ticket Sales badge
                    if (isAdvance)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Advance ticket sales',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if (isComingSoon)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Coming Soon',
                            style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info row
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      film.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildChip('${film.durasi ~/ 60}h ${film.durasi % 60}m'),
                        const SizedBox(width: 4),
                        _buildChip(film.ratingUsia, isRating: true),
                        const SizedBox(width: 4),
                        _buildChip('2D'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, {bool isRating = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isRating ? AppTheme.primaryGold : AppTheme.cardBgLight,
        borderRadius: BorderRadius.circular(6),
        border: isRating ? null : Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isRating ? Colors.black : AppTheme.textMuted,
          fontSize: 10,
          fontWeight: isRating ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
