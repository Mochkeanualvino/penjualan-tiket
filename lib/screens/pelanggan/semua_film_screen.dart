import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/film_provider.dart';
import '../../models/film_model.dart';
import '../../utils/theme.dart';
import 'detail_film_screen.dart';

class SemuaFilmScreen extends StatelessWidget {
  final String title;
  final List<FilmModel> films;

  const SemuaFilmScreen({
    super.key,
    required this.title,
    required this.films,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: films.isEmpty
          ? const Center(
              child: Text('Belum ada daftar film.', style: TextStyle(color: AppTheme.textMuted)),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: films.length,
              itemBuilder: (ctx, index) {
                final film = films[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
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
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                film.posterUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, _, __) => Container(
                                  color: Colors.grey.shade900,
                                  child: const Icon(Icons.movie, size: 50, color: AppTheme.primaryGold),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGold,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    film.ratingUsia,
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                film.judul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                film.genre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
