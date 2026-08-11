import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/film_provider.dart';
import '../../models/film_model.dart';
import '../../utils/theme.dart';
import '../../services/auto_save_service.dart';
import '../../widgets/auto_save_status_indicator.dart';

class KelolaFilmScreen extends StatefulWidget {
  const KelolaFilmScreen({super.key});

  @override
  State<KelolaFilmScreen> createState() => _KelolaFilmScreenState();
}

class _KelolaFilmScreenState extends State<KelolaFilmScreen> {
  int _selectedCategoryIndex = 0; // 0 = Sedang Tayang, 1 = Segera Tayang

  void _showFormDialog(BuildContext context, [FilmModel? film]) {
    final judulController = TextEditingController(text: film?.judul ?? '');
    final genreController = TextEditingController(text: film?.genre ?? '');
    final durasiController = TextEditingController(text: film != null ? film.durasi.toString() : '');
    final ratingController = TextEditingController(text: film?.ratingUsia ?? '13+');
    final posterController = TextEditingController(text: film?.posterUrl ?? '');
    bool isSegeraTayang = film?.isSegeraTayang ?? (_selectedCategoryIndex == 1);

    final formKey = GlobalKey<FormState>();
    final String draftKey = film == null ? 'form_film_tambah' : 'form_film_edit_${film.id}';

    // Muat draft yang tersimpan sebelumnya (auto-restore)
    if (film == null) {
      final draft = AutoSaveService.loadDraft(draftKey);
      if (draft != null) {
        judulController.text = draft['judul'] ?? '';
        genreController.text = draft['genre'] ?? '';
        durasiController.text = draft['durasi'] ?? '';
        ratingController.text = draft['ratingUsia'] ?? '13+';
        posterController.text = draft['posterUrl'] ?? '';
        if (draft['isSegeraTayang'] != null) {
          isSegeraTayang = draft['isSegeraTayang'] == true;
        }
      }
    }

    AutoSaveStatus currentStatus = AutoSaveStatus.idle;

    // Fungsi auto-save yang dipanggil setiap input berubah
    void triggerAutoSave(VoidCallback setStateDialog) {
      AutoSaveService.onInputChanged(
        formKey: draftKey,
        data: {
          'judul': judulController.text,
          'genre': genreController.text,
          'durasi': durasiController.text,
          'ratingUsia': ratingController.text,
          'posterUrl': posterController.text,
          'isSegeraTayang': isSegeraTayang,
        },
        onStatusChanged: () {
          setStateDialog(() {
            currentStatus = AutoSaveService.getStatus(draftKey);
          });
        },
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          // Pasang listener auto-save ke semua controller
          void addAutoSaveListeners() {
            void listener() => triggerAutoSave(setStateDialog);
            judulController.removeListener(listener);
            genreController.removeListener(listener);
            durasiController.removeListener(listener);
            posterController.removeListener(listener);
            judulController.addListener(listener);
            genreController.addListener(listener);
            durasiController.addListener(listener);
            posterController.addListener(listener);
          }
          addAutoSaveListeners();

          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(film == null ? 'Tambah Film Baru' : 'Edit Film'),
                const SizedBox(height: 8),
                AutoSaveStatusIndicator(status: currentStatus),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Kategori Status Tayang
                    DropdownButtonFormField<bool>(
                      value: isSegeraTayang,
                      decoration: const InputDecoration(
                        labelText: 'Kategori / Status Penayangan',
                        prefixIcon: Icon(Icons.movie_filter, color: AppTheme.primaryGold),
                      ),
                      dropdownColor: AppTheme.cardBgLight,
                      items: const [
                        DropdownMenuItem(
                          value: false,
                          child: Text('🎬 Sedang Tayang (Now Showing)'),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text('🗓️ Segera Tayang (Coming Soon)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            isSegeraTayang = val;
                          });
                          triggerAutoSave(setStateDialog);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
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
                        if (val != null) {
                          ratingController.text = val;
                          triggerAutoSave(setStateDialog);
                        }
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
                        isSegeraTayang: isSegeraTayang,
                      );
                    } else {
                      await filmProvider.updateFilm(
                        id: film.id,
                        judul: judulController.text.trim(),
                        genre: genreController.text.trim(),
                        durasi: int.parse(durasiController.text.trim()),
                        ratingUsia: ratingController.text.trim(),
                        posterUrl: posterController.text.trim(),
                        isSegeraTayang: isSegeraTayang,
                      );
                    }
                    AutoSaveService.clearDraft(draftKey);
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
          );
        },
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
    final displayedFilms = _selectedCategoryIndex == 0 ? filmProvider.films : filmProvider.segeraTayang;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Bar
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

            // Tab Switcher antara Sedang Tayang & Segera Tayang
            Row(
              children: [
                _buildCategoryChip(
                  label: '🎬 Sedang Tayang (${filmProvider.films.length})',
                  isSelected: _selectedCategoryIndex == 0,
                  onTap: () => setState(() => _selectedCategoryIndex = 0),
                ),
                const SizedBox(width: 12),
                _buildCategoryChip(
                  label: '🗓️ Segera Tayang (${filmProvider.segeraTayang.length})',
                  isSelected: _selectedCategoryIndex == 1,
                  onTap: () => setState(() => _selectedCategoryIndex = 1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            filmProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : displayedFilms.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.movie_filter_outlined, size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              _selectedCategoryIndex == 0 ? 'Belum ada film Sedang Tayang' : 'Belum ada film Segera Tayang',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
                            ),
                          ],
                        ),
                      )
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
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Aksi')),
                            ],
                            rows: displayedFilms.map((film) {
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: film.isSegeraTayang
                                            ? Colors.orange.withAlpha(50)
                                            : AppTheme.accentGreen.withAlpha(50),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: film.isSegeraTayang ? Colors.orange : AppTheme.accentGreen,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        film.isSegeraTayang ? 'Segera Tayang' : 'Sedang Tayang',
                                        style: TextStyle(
                                          color: film.isSegeraTayang ? Colors.orange : AppTheme.accentGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryGold,
      backgroundColor: AppTheme.cardBgLight,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : AppTheme.textWhite,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryGold : Colors.white12,
        ),
      ),
    );
  }
}
