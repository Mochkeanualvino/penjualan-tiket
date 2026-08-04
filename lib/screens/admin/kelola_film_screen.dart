import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/film_provider.dart';
import '../../models/film_model.dart';
import '../../utils/theme.dart';

class KelolaFilmScreen extends StatelessWidget {
  const KelolaFilmScreen({super.key});

  void _showFormDialog(BuildContext context, [FilmModel? film]) {
    final judulController = TextEditingController(text: film?.judul ?? '');
    final genreController = TextEditingController(text: film?.genre ?? '');
    final durasiController = TextEditingController(text: film != null ? film.durasi.toString() : '');
    final ratingController = TextEditingController(text: film?.ratingUsia ?? '13+');
    final posterController = TextEditingController(text: film?.posterUrl ?? '');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(film == null ? 'Tambah Film Baru' : 'Edit Film'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: judulController,
                  decoration: const InputDecoration(labelText: 'Judul Film'),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: genreController,
                  decoration: const InputDecoration(labelText: 'Genre (e.g. Action, Drama)'),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: durasiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Durasi (menit)'),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: ['SU', '13+', '17+', '21+'].contains(ratingController.text) 
                      ? ratingController.text 
                      : '13+',
                  decoration: const InputDecoration(labelText: 'Rating Usia'),
                  dropdownColor: AppTheme.cardBgLight,
                  items: ['SU', '13+', '17+', '21+'].map((rating) {
                    return DropdownMenuItem(value: rating, child: Text(rating));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) ratingController.text = val;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: posterController,
                  decoration: const InputDecoration(
                    labelText: 'URL Poster Gambar',
                    hintText: 'https://...',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final filmProvider = Provider.of<FilmProvider>(context, listen: false);
                if (film == null) {
                  await filmProvider.addFilm(
                    judul: judulController.text.trim(),
                    genre: genreController.text.trim(),
                    durasi: int.parse(durasiController.text.trim()),
                    ratingUsia: ratingController.text.trim(),
                    posterUrl: posterController.text.trim(),
                  );
                } else {
                  await filmProvider.updateFilm(
                    id: film.id,
                    judul: judulController.text.trim(),
                    genre: genreController.text.trim(),
                    durasi: int.parse(durasiController.text.trim()),
                    ratingUsia: ratingController.text.trim(),
                    posterUrl: posterController.text.trim(),
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(film == null ? 'Film berhasil ditambahkan!' : 'Film berhasil diperbarui!'),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String filmId, String judul) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Film'),
        content: Text('Apakah Anda yakin ingin menghapus film "$judul"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () async {
              await Provider.of<FilmProvider>(context, listen: false).deleteFilm(filmId);
              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Film berhasil dihapus'), backgroundColor: AppTheme.accentRed),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filmProvider = Provider.of<FilmProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kelola Film',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showFormDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Film'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            filmProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Poster')),
                          DataColumn(label: Text('Judul Film')),
                          DataColumn(label: Text('Genre')),
                          DataColumn(label: Text('Durasi')),
                          DataColumn(label: Text('Rating Usia')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: filmProvider.films.map((film) {
                          return DataRow(
                            cells: [
                              DataCell(
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    film.posterUrl,
                                    width: 40,
                                    height: 55,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, _, __) => Container(
                                      width: 40,
                                      height: 55,
                                      color: Colors.grey.shade800,
                                      child: const Icon(Icons.movie, size: 20, color: Colors.white54),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(film.judul, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(film.genre)),
                              DataCell(Text('${film.durasi} menit')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGold.withAlpha(51),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.primaryGold, width: 0.5),
                                  ),
                                  child: Text(film.ratingUsia, style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12)),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppTheme.primaryGold),
                                      onPressed: () => _showFormDialog(context, film),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppTheme.accentRed),
                                      onPressed: () => _confirmDelete(context, film.id, film.judul),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
