import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/film_model.dart';
import '../../providers/jadwal_provider.dart';
import '../../utils/theme.dart';
import 'pilih_jadwal_screen.dart';
import 'detail_film_screen.dart';

class LihatFilmScreen extends StatelessWidget {
  final List<FilmModel> films;
  const LihatFilmScreen({super.key, required this.films});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner XXI / CGV Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B2B36), Color(0xFF0F0F12)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'SEDANG TAYANG DI BIOSKOP',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryGold, letterSpacing: 1.5),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Pilih film favorit Anda & pesan kursi terbaik sekarang!',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.local_activity, color: AppTheme.primaryGold, size: 40),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Film List Grid
          films.isEmpty
              ? const Center(child: Text('Belum ada film tersedia.', style: TextStyle(color: AppTheme.textMuted)))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: films.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (ctx, index) {
                        final film = films[index];
                        return _buildFilmCard(context, film);
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildFilmCard(BuildContext context, FilmModel film) {
    final jadwalProvider = Provider.of<JadwalProvider>(context, listen: false);
    final isAvailable = jadwalProvider.getJadwalByFilm(film.id).isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primaryGold.withOpacity(0.2), width: 1),
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
            // Poster Image
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      film.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(child: Icon(Icons.movie, size: 50, color: AppTheme.primaryGold)),
                      ),
                    ),
                  ),
                  // Rating Usia Badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.primaryGold, width: 1),
                      ),
                      child: Text(
                        film.ratingUsia,
                        style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Film Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    film.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    film.genre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppTheme.primaryGold),
                      const SizedBox(width: 4),
                      Text(
                        '${film.durasi} Min',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Booking Button
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PilihJadwalScreen(film: film),
                          ),
                        );
                      },
                      child: const Text('PESAN TIKET', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
