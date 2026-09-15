import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/film_model.dart';
import '../../utils/theme.dart';
import 'pilih_jadwal_screen.dart';

class DetailFilmScreen extends StatelessWidget {
  final FilmModel film;
  const DetailFilmScreen({super.key, required this.film});

  Future<void> _openTrailer(BuildContext context) async {
    final url = film.trailerUrl.isNotEmpty
        ? film.trailerUrl
        : 'https://www.youtube.com/results?search_query=trailer+official+${Uri.encodeComponent(film.judul)}';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse('https://www.youtube.com'), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka trailer: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultSinopsis = film.sinopsis.isNotEmpty
        ? film.sinopsis
        : 'Saksikan keseruan dan aksi mendebarkan dalam film "${film.judul}". Hadir dengan alur cerita memukau, efek visual spektakuler, dan pengalaman sinematik tanpa tanding hanya di Cinema XXI / CGV seluruh Indonesia.';

    final defaultSutradara = film.sutradara.isNotEmpty ? film.sutradara : 'Cinema Studios Producer';
    final defaultPemeran = film.pemeran.isNotEmpty ? film.pemeran : 'Aktor & Aktris Ternama Indonesia & Hollywood';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Poster Backdrop & Back Button
          SliverAppBar(
            expandedHeight: 380.0,
            floating: false,
            pinned: true,
            leading: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                film.judul,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 12)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    film.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      color: Colors.grey.shade900,
                      child: const Icon(Icons.movie, size: 80, color: AppTheme.primaryGold),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.bgBlack.withAlpha(150),
                          AppTheme.bgBlack,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Film Profile Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row (Age Rating, Duration, Genre, Formats)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge(film.ratingUsia, isPrimary: true),
                      _buildBadge('${film.durasi} Menit', icon: Icons.access_time),
                      _buildBadge(film.genre, icon: Icons.movie_filter),
                      _buildBadge('2D / 3D / IMAX', isGoldBorder: true),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Watch Trailer Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade900.withAlpha(80), AppTheme.cardBgLight],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.redAccent.withAlpha(100)),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                      ),
                      title: const Text('Tonton Video Trailer Resmi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                      subtitle: const Text('Klik untuk melihat cuplikan film di YouTube', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      trailing: const Icon(Icons.open_in_new, color: Colors.redAccent, size: 20),
                      onTap: () => _openTrailer(context),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sinopsis
                  Text(
                    'Sinopsis Film',
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      defaultSinopsis,
                      style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 13.5),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cast & Crew Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.person_pin, color: AppTheme.primaryGold, size: 16),
                                  SizedBox(width: 6),
                                  Text('Sutradara', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(defaultSutradara, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.category, color: AppTheme.primaryGold, size: 16),
                                  SizedBox(width: 6),
                                  Text('Status', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(film.isSegeraTayang ? 'Segera Tayang' : 'Sedang Tayang', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Pemeran Utama
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.people_alt_outlined, color: AppTheme.primaryGold, size: 16),
                            SizedBox(width: 6),
                            Text('Pemeran Utama (Cast)', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(defaultPemeran, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90), // Spacing for bottom floating button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppTheme.cardBg,
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.confirmation_number_outlined, color: Colors.black),
            label: const Text(
              'PILIH JADWAL & BELI TIKET',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PilihJadwalScreen(film: film),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, {bool isPrimary = false, bool isGoldBorder = false, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primaryGold : AppTheme.cardBgLight,
        borderRadius: BorderRadius.circular(8),
        border: isGoldBorder ? Border.all(color: AppTheme.primaryGold.withAlpha(120)) : (isPrimary ? null : Border.all(color: Colors.white24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: isPrimary ? Colors.black : Colors.white70),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: isPrimary ? Colors.black : (isGoldBorder ? AppTheme.primaryGold : Colors.white),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
