import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/film_provider.dart';
import '../../utils/theme.dart';
import 'detail_film_screen.dart';

class SearchFilmDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Cari film bioskop...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return AppTheme.darkTheme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.cardBg,
        iconTheme: IconThemeData(color: AppTheme.primaryGold),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppTheme.textMuted),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: AppTheme.primaryGold),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGold),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filmProvider = Provider.of<FilmProvider>(context);
    final allFilms = [...filmProvider.films, ...filmProvider.segeraTayang];
    final results = allFilms.where((f) {
      return f.judul.toLowerCase().contains(query.toLowerCase()) ||
          f.genre.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Container(
        color: AppTheme.bgBlack,
        child: const Center(
          child: Text('Film tidak ditemukan.', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }

    return Container(
      color: AppTheme.bgBlack,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (ctx, index) {
          final film = results[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                film.posterUrl,
                width: 40,
                height: 55,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 40,
                  height: 55,
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.movie, color: AppTheme.primaryGold),
                ),
              ),
            ),
            title: Text(film.judul, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('${film.genre} • ${film.durasi} Min', style: const TextStyle(color: AppTheme.textMuted)),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryGold),
            onTap: () {
              close(context, film.judul);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailFilmScreen(film: film)),
              );
            },
          );
        },
      ),
    );
  }
}
