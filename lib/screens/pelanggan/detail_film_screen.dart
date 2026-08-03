import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/film_model.dart';
import '../../providers/jadwal_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import 'pilih_jadwal_screen.dart';

class DetailFilmScreen extends StatelessWidget {
  final FilmModel film;
  const DetailFilmScreen({super.key, required this.film});

  @override
  Widget build(BuildContext context) {
    final jadwalProvider = Provider.of<JadwalProvider>(context);
    final jadwalList = jadwalProvider.getJadwalByFilm(film.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Poster Image
          SliverAppBar(
            expandedHeight: 320.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                film.judul,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
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
                          AppTheme.bgBlack.withOpacity(0.8),
                          AppTheme.bgBlack,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Film Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          film.ratingUsia,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBgLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          '${film.durasi} Menit',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBgLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          film.genre,
                          style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Sinopsis Film',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saksikan keseruan dan aksi mendebarkan dalam film "${film.judul}". Hadir dengan pengalaman sinematik memukau hanya di Cinema XXI / CGV seluruh Indonesia.',
                    style: const TextStyle(color: AppTheme.textMuted, height: 1.5, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Jadwal Tayang Bioskop',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                  ),
                  const SizedBox(height: 12),

                  jadwalList.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'Belum ada jadwal tayang tersedia untuk film ini.',
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: jadwalList.map((j) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const Icon(Icons.meeting_room, color: AppTheme.primaryGold),
                                title: Text(j.namaStudio, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${Formatters.formatShortDate(j.tanggal)} - Jam ${j.jam}'),
                                trailing: Text(
                                  Formatters.currency(j.hargaTiket),
                                  style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.cardBg,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PilihJadwalScreen(film: film),
                ),
              );
            },
            child: const Text('BELI TIKET SEKARANG', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
