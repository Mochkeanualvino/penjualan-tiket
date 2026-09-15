import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/film_provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/studio_provider.dart';
import '../../models/film_model.dart';
import '../../models/jadwal_model.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../services/auto_save_service.dart';
import '../../widgets/auto_save_status_indicator.dart';

class KelolaFilmScreen extends StatefulWidget {
  const KelolaFilmScreen({super.key});

  @override
  State<KelolaFilmScreen> createState() => _KelolaFilmScreenState();
}

class _KelolaFilmScreenState extends State<KelolaFilmScreen> {
  int _selectedCategoryIndex = 0; // 0 = Sedang Tayang, 1 = Segera Tayang, 2 = Jadwal Coming Soon

  Widget _buildPosterThumbnail(String posterUrl, {double width = 52, double height = 72}) {
    final placeholder = Container(
      color: AppTheme.cardBgLight,
      child: const Center(
        child: Icon(Icons.movie_outlined, size: 22, color: AppTheme.textMuted),
      ),
    );

    return Container(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: posterUrl.trim().isEmpty
            ? placeholder
            : Image.network(
                posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => placeholder,
              ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, [FilmModel? film]) {
    final judulController = TextEditingController(text: film?.judul ?? '');
    final genreController = TextEditingController(text: film?.genre ?? '');
    final durasiController = TextEditingController(text: film != null ? film.durasi.toString() : '');
    final ratingController = TextEditingController(text: film?.ratingUsia ?? '13+');
    final posterController = TextEditingController(text: film?.posterUrl ?? '');
    final sinopsisController = TextEditingController(text: film?.sinopsis ?? '');
    final sutradaraController = TextEditingController(text: film?.sutradara ?? '');
    final pemeranController = TextEditingController(text: film?.pemeran ?? '');
    final trailerController = TextEditingController(text: film?.trailerUrl ?? '');
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
        sinopsisController.text = draft['sinopsis'] ?? '';
        sutradaraController.text = draft['sutradara'] ?? '';
        pemeranController.text = draft['pemeran'] ?? '';
        trailerController.text = draft['trailerUrl'] ?? '';
        if (draft['isSegeraTayang'] != null) {
          isSegeraTayang = draft['isSegeraTayang'] == true;
        }
      }
    }

    AutoSaveStatus currentStatus = AutoSaveStatus.idle;

    // Fungsi auto-save yang dipanggil setiap input berubah
    void triggerAutoSave(StateSetter setStateDialog) {
      AutoSaveService.onInputChanged(
        formKey: draftKey,
        data: {
          'judul': judulController.text,
          'genre': genreController.text,
          'durasi': durasiController.text,
          'ratingUsia': ratingController.text,
          'posterUrl': posterController.text,
          'sinopsis': sinopsisController.text,
          'sutradara': sutradaraController.text,
          'pemeran': pemeranController.text,
          'trailerUrl': trailerController.text,
          'isSegeraTayang': isSegeraTayang,
        },
        onStatusChanged: () {
          setStateDialog(() {
            currentStatus = AutoSaveService.getStatus(draftKey);
          });
        },
      );
    }

    // Listener stabil yang disimpan sebagai variabel tetap
    // agar removeListener benar-benar bisa menghapusnya
    bool _listenersAttached = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          // Pasang listener HANYA SEKALI (bukan setiap rebuild)
          if (!_listenersAttached) {
            _listenersAttached = true;
            void stableListener() {
              AutoSaveService.onInputChanged(
                formKey: draftKey,
                data: {
                  'judul': judulController.text,
                  'genre': genreController.text,
                  'durasi': durasiController.text,
                  'ratingUsia': ratingController.text,
                  'posterUrl': posterController.text,
                  'sinopsis': sinopsisController.text,
                  'sutradara': sutradaraController.text,
                  'pemeran': pemeranController.text,
                  'trailerUrl': trailerController.text,
                  'isSegeraTayang': isSegeraTayang,
                },
                onStatusChanged: () {
                  setStateDialog(() {
                    currentStatus = AutoSaveService.getStatus(draftKey);
                  });
                },
              );
            }
            judulController.addListener(stableListener);
            genreController.addListener(stableListener);
            durasiController.addListener(stableListener);
            posterController.addListener(stableListener);
            sinopsisController.addListener(stableListener);
            sutradaraController.addListener(stableListener);
            pemeranController.addListener(stableListener);
            trailerController.addListener(stableListener);
          }

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
                      decoration: const InputDecoration(
                        labelText: 'Durasi (menit)',
                        hintText: 'Contoh: 120',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                        final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
                        if (clean.isEmpty || int.tryParse(clean) == null || int.parse(clean) <= 0) {
                          return 'Masukkan angka durasi yang valid (contoh: 120)';
                        }
                        return null;
                      },
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: sutradaraController,
                      decoration: const InputDecoration(
                        labelText: 'Sutradara / Produser',
                        hintText: 'Contoh: Christopher Nolan',
                        prefixIcon: Icon(Icons.person_pin, color: AppTheme.primaryGold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: pemeranController,
                      decoration: const InputDecoration(
                        labelText: 'Pemeran Utama (Cast)',
                        hintText: 'Contoh: Cillian Murphy, Robert Downey Jr.',
                        prefixIcon: Icon(Icons.people_alt_outlined, color: AppTheme.primaryGold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: trailerController,
                      decoration: const InputDecoration(
                        labelText: 'Link Video Trailer (YouTube/URL)',
                        hintText: 'https://www.youtube.com/watch?v=...',
                        prefixIcon: Icon(Icons.video_library_outlined, color: AppTheme.primaryGold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: sinopsisController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Sinopsis Lengkap Film',
                        hintText: 'Tuliskan alur dan sinopsis film...',
                        alignLabelWithHint: true,
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
                    try {
                      final filmProvider = Provider.of<FilmProvider>(context, listen: false);
                      final durasiClean = durasiController.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final parsedDurasi = int.tryParse(durasiClean) ?? 120;

                      if (film == null) {
                        await filmProvider.addFilm(
                          judul: judulController.text.trim(),
                          genre: genreController.text.trim(),
                          durasi: parsedDurasi,
                          ratingUsia: ratingController.text.trim(),
                          posterUrl: posterController.text.trim(),
                          isSegeraTayang: isSegeraTayang,
                          sinopsis: sinopsisController.text.trim(),
                          sutradara: sutradaraController.text.trim(),
                          pemeran: pemeranController.text.trim(),
                          trailerUrl: trailerController.text.trim(),
                        );
                      } else {
                        await filmProvider.updateFilm(
                          id: film.id,
                          judul: judulController.text.trim(),
                          genre: genreController.text.trim(),
                          durasi: parsedDurasi,
                          ratingUsia: ratingController.text.trim(),
                          posterUrl: posterController.text.trim(),
                          isSegeraTayang: isSegeraTayang,
                          sinopsis: sinopsisController.text.trim(),
                          sutradara: sutradaraController.text.trim(),
                          pemeran: pemeranController.text.trim(),
                          trailerUrl: trailerController.text.trim(),
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
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menyimpan: $e'),
                          backgroundColor: AppTheme.accentRed,
                        ),
                      );
                    }
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

  // ========== CRUD JADWAL COMING SOON ==========

  void _showJadwalFormDialog(BuildContext context, [JadwalModel? jadwal]) {
    final filmProvider = Provider.of<FilmProvider>(context, listen: false);
    final studioProvider = Provider.of<StudioProvider>(context, listen: false);

    if (filmProvider.segeraTayang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada film Coming Soon! Tambahkan film Segera Tayang terlebih dahulu.')),
      );
      return;
    }
    if (studioProvider.studios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada Studio! Tambahkan Studio terlebih dahulu.')),
      );
      return;
    }

    // Pastikan selectedFilmId valid (ada di list segera tayang)
    String selectedFilmId = jadwal?.filmId ?? filmProvider.segeraTayang.first.id;
    final isFilmValid = filmProvider.segeraTayang.any((f) => f.id == selectedFilmId);
    if (!isFilmValid) selectedFilmId = filmProvider.segeraTayang.first.id;

    String selectedStudioId = jadwal?.studioId ?? studioProvider.studios.first.id;
    final isStudioValid = studioProvider.studios.any((s) => s.id == selectedStudioId);
    if (!isStudioValid) selectedStudioId = studioProvider.studios.first.id;

    DateTime selectedDate = jadwal?.tanggal ?? DateTime.now().add(const Duration(days: 7));
    final jamController = TextEditingController(text: jadwal?.jam ?? '14:00');
    final hargaController = TextEditingController(text: jadwal != null ? jadwal.hargaTiket.toInt().toString() : '50000');

    final formKey = GlobalKey<FormState>();
    final String draftKey = jadwal == null ? 'form_jadwal_cs_tambah' : 'form_jadwal_cs_edit_${jadwal.id}';

    // Muat draft yang tersimpan sebelumnya (auto-restore)
    if (jadwal == null) {
      final draft = AutoSaveService.loadDraft(draftKey);
      if (draft != null) {
        jamController.text = draft['jam'] ?? '14:00';
        hargaController.text = draft['harga'] ?? '50000';
        if (draft['filmId'] != null) {
          final draftFilmValid = filmProvider.segeraTayang.any((f) => f.id == draft['filmId']);
          if (draftFilmValid) selectedFilmId = draft['filmId'];
        }
        if (draft['studioId'] != null) {
          final draftStudioValid = studioProvider.studios.any((s) => s.id == draft['studioId']);
          if (draftStudioValid) selectedStudioId = draft['studioId'];
        }
      }
    }

    AutoSaveStatus currentStatus = AutoSaveStatus.idle;

    void triggerAutoSave(StateSetter setStateDialog) {
      AutoSaveService.onInputChanged(
        formKey: draftKey,
        data: {
          'filmId': selectedFilmId,
          'studioId': selectedStudioId,
          'tanggal': selectedDate.toIso8601String(),
          'jam': jamController.text,
          'harga': hargaController.text,
        },
        onStatusChanged: () {
          setStateDialog(() {
            currentStatus = AutoSaveService.getStatus(draftKey);
          });
        },
      );
    }

    bool _jadwalListenersAttached = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          if (!_jadwalListenersAttached) {
            _jadwalListenersAttached = true;
            void stableListener() => triggerAutoSave(setStateDialog);
            jamController.addListener(stableListener);
            hargaController.addListener(stableListener);
          }

          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(jadwal == null ? 'Tambah Jadwal Coming Soon' : 'Edit Jadwal Coming Soon'),
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
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withAlpha(100)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Jadwal ini khusus untuk film Coming Soon / Segera Tayang.',
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Dropdown film segera tayang
                    DropdownButtonFormField<String>(
                      value: selectedFilmId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Film Coming Soon',
                        prefixIcon: Icon(Icons.movie_filter, color: Colors.orange),
                      ),
                      dropdownColor: AppTheme.cardBgLight,
                      items: filmProvider.segeraTayang.map((f) {
                        return DropdownMenuItem(value: f.id, child: Text('🗓️ ${f.judul}'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => selectedFilmId = val);
                          triggerAutoSave(setStateDialog);
                        }
                      },
                      validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 12),
                    // Dropdown studio
                    DropdownButtonFormField<String>(
                      value: selectedStudioId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Studio',
                        prefixIcon: Icon(Icons.meeting_room, color: AppTheme.accentBlue),
                      ),
                      dropdownColor: AppTheme.cardBgLight,
                      items: studioProvider.studios.map((s) {
                        return DropdownMenuItem(value: s.id, child: Text(s.namaStudio));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => selectedStudioId = val);
                          triggerAutoSave(setStateDialog);
                        }
                      },
                      validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 12),
                    // Tanggal tayang
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: AppTheme.cardBgLight,
                      title: const Text('Tanggal Tayang Perdana', style: TextStyle(fontSize: 12, color: Colors.orange)),
                      subtitle: Text(Formatters.formatShortDate(selectedDate), style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.calendar_today, color: Colors.orange),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setStateDialog(() => selectedDate = picked);
                          triggerAutoSave(setStateDialog);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Jam tayang
                    TextFormField(
                      controller: jamController,
                      decoration: const InputDecoration(
                        labelText: 'Jam Tayang (e.g. 14:30)',
                        prefixIcon: Icon(Icons.access_time, color: AppTheme.primaryGold),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    // Harga tiket
                    TextFormField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga Tiket (Rp)',
                        prefixIcon: Icon(Icons.attach_money, color: AppTheme.accentGreen),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final jadwalProvider = Provider.of<JadwalProvider>(context, listen: false);
                    final film = filmProvider.getFilmById(selectedFilmId);
                    final studio = studioProvider.getStudioById(selectedStudioId);

                    if (film != null && studio != null) {
                      final hargaClean = hargaController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                      final parsedHarga = double.tryParse(hargaClean) ?? 50000.0;

                      if (jadwal == null) {
                        await jadwalProvider.addJadwal(
                          filmId: film.id,
                          judulFilm: film.judul,
                          posterUrl: film.posterUrl,
                          studioId: studio.id,
                          namaStudio: studio.namaStudio,
                          tanggal: selectedDate,
                          jam: jamController.text.trim(),
                          hargaTiket: parsedHarga,
                        );
                      } else {
                        await jadwalProvider.updateJadwal(
                          id: jadwal.id,
                          filmId: film.id,
                          judulFilm: film.judul,
                          posterUrl: film.posterUrl,
                          studioId: studio.id,
                          namaStudio: studio.namaStudio,
                          tanggal: selectedDate,
                          jam: jamController.text.trim(),
                          hargaTiket: parsedHarga,
                        );
                      }
                    }
                    AutoSaveService.clearDraft(draftKey);
                    if (ctx.mounted) Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(jadwal == null
                            ? 'Jadwal Coming Soon berhasil ditambahkan!'
                            : 'Jadwal Coming Soon berhasil diperbarui!'),
                        backgroundColor: AppTheme.accentGreen,
                      ),
                    );
                  }
                },
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteJadwal(BuildContext context, String jadwalId, String filmJudul) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal Coming Soon'),
        content: Text('Apakah Anda yakin ingin menghapus jadwal Coming Soon untuk "$filmJudul"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () async {
              await Provider.of<JadwalProvider>(context, listen: false).deleteJadwal(jadwalId);
              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jadwal Coming Soon berhasil dihapus'), backgroundColor: AppTheme.accentRed),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan tabel jadwal coming soon
  Widget _buildJadwalComingSoonTable(BuildContext context) {
    final jadwalProvider = Provider.of<JadwalProvider>(context);
    final filmProvider = Provider.of<FilmProvider>(context);

    // Filter jadwal yang filmId-nya termasuk film segera tayang
    final segeraTayangIds = filmProvider.segeraTayang.map((f) => f.id).toSet();
    final jadwalComingSoon = jadwalProvider.jadwalList
        .where((j) => segeraTayangIds.contains(j.filmId))
        .toList();

    if (jadwalComingSoon.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.calendar_month_outlined, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            const Text(
              'Belum ada Jadwal Coming Soon',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Klik tombol "Tambah Jadwal CS" untuk menambahkan jadwal tayang perdana film Coming Soon.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Film')),
            DataColumn(label: Text('Studio')),
            DataColumn(label: Text('Tanggal Tayang')),
            DataColumn(label: Text('Jam')),
            DataColumn(label: Text('Harga Tiket')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: jadwalComingSoon.map((j) {
            final isUpcoming = j.tanggal.isAfter(DateTime.now());
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPosterThumbnail(j.posterUrl, width: 42, height: 58),
                      const SizedBox(width: 8),
                      Text(j.judulFilm, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                DataCell(Text(j.namaStudio)),
                DataCell(Text(Formatters.formatShortDate(j.tanggal))),
                DataCell(Text(j.jam, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                DataCell(Text(Formatters.currency(j.hargaTiket))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUpcoming
                          ? Colors.orange.withAlpha(50)
                          : AppTheme.accentGreen.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUpcoming ? Colors.orange : AppTheme.accentGreen,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isUpcoming ? '🗓️ Mendatang' : '✅ Sudah Lewat',
                      style: TextStyle(
                        color: isUpcoming ? Colors.orange : AppTheme.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit Jadwal',
                        onPressed: () => _showJadwalFormDialog(context, j),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.accentRed),
                        tooltip: 'Hapus Jadwal',
                        onPressed: () => _confirmDeleteJadwal(context, j.id, j.judulFilm),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
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
                Row(
                  children: [
                    if (_selectedCategoryIndex == 2)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        onPressed: () => _showJadwalFormDialog(context),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Tambah Jadwal CS', style: TextStyle(color: Colors.white)),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _showFormDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Film'),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tab Switcher antara Sedang Tayang, Segera Tayang & Jadwal Coming Soon
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildCategoryChip(
                  label: '🎬 Sedang Tayang (${filmProvider.films.length})',
                  isSelected: _selectedCategoryIndex == 0,
                  onTap: () => setState(() => _selectedCategoryIndex = 0),
                ),
                _buildCategoryChip(
                  label: '🗓️ Segera Tayang (${filmProvider.segeraTayang.length})',
                  isSelected: _selectedCategoryIndex == 1,
                  onTap: () => setState(() => _selectedCategoryIndex = 1),
                ),
                _buildCategoryChip(
                  label: '📅 Jadwal Coming Soon',
                  isSelected: _selectedCategoryIndex == 2,
                  onTap: () => setState(() => _selectedCategoryIndex = 2),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Konten berdasarkan tab yang dipilih
            if (_selectedCategoryIndex == 2)
              // === TAB JADWAL COMING SOON ===
              _buildJadwalComingSoonTable(context)
            else if (filmProvider.isLoading)
              const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
            else if (displayedFilms.isEmpty)
              Container(
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
            else
              Card(
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
                          DataCell(_buildPosterThumbnail(film.posterUrl)),
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
