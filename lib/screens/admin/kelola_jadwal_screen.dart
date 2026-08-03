import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/film_provider.dart';
import '../../providers/studio_provider.dart';
import '../../models/jadwal_model.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class KelolaJadwalScreen extends StatelessWidget {
  const KelolaJadwalScreen({super.key});

  void _showFormDialog(BuildContext context, [JadwalModel? jadwal]) {
    final filmProvider = Provider.of<FilmProvider>(context, listen: false);
    final studioProvider = Provider.of<StudioProvider>(context, listen: false);

    if (filmProvider.films.isEmpty || studioProvider.studios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan Film dan Studio terlebih dahulu!')),
      );
      return;
    }

    String selectedFilmId = jadwal?.filmId ?? filmProvider.films.first.id;
    String selectedStudioId = jadwal?.studioId ?? studioProvider.studios.first.id;
    DateTime selectedDate = jadwal?.tanggal ?? DateTime.now();
    final jamController = TextEditingController(text: jadwal?.jam ?? '14:00');
    final hargaController = TextEditingController(text: jadwal != null ? jadwal.hargaTiket.toInt().toString() : '50000');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(jadwal == null ? 'Tambah Jadwal Tayang' : 'Edit Jadwal Tayang'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedFilmId,
                    decoration: const InputDecoration(labelText: 'Pilih Film'),
                    dropdownColor: AppTheme.cardBgLight,
                    items: filmProvider.films.map((f) {
                      return DropdownMenuItem(value: f.id, child: Text(f.judul));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => selectedFilmId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStudioId,
                    decoration: const InputDecoration(labelText: 'Pilih Studio'),
                    dropdownColor: AppTheme.cardBgLight,
                    items: studioProvider.studios.map((s) {
                      return DropdownMenuItem(value: s.id, child: Text(s.namaStudio));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => selectedStudioId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: AppTheme.cardBgLight,
                    title: const Text('Tanggal Tayang', style: TextStyle(fontSize: 12, color: AppTheme.primaryGold)),
                    subtitle: Text(Formatters.formatShortDate(selectedDate), style: const TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.calendar_today, color: AppTheme.primaryGold),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (picked != null) {
                        setStateDialog(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: jamController,
                    decoration: const InputDecoration(labelText: 'Jam Tayang (e.g. 14:30)'),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: hargaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga Tiket (Rp)'),
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final jadwalProvider = Provider.of<JadwalProvider>(context, listen: false);
                  final filmProvider = Provider.of<FilmProvider>(context, listen: false);
                  final studioProvider = Provider.of<StudioProvider>(context, listen: false);
                  final film = filmProvider.getFilmById(selectedFilmId);
                  final studio = studioProvider.getStudioById(selectedStudioId);

                  if (film != null && studio != null) {
                    if (jadwal == null) {
                      await jadwalProvider.addJadwal(
                        filmId: film.id,
                        judulFilm: film.judul,
                        posterUrl: film.posterUrl,
                        studioId: studio.id,
                        namaStudio: studio.namaStudio,
                        tanggal: selectedDate,
                        jam: jamController.text.trim(),
                        hargaTiket: double.parse(hargaController.text.trim()),
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
                        hargaTiket: double.parse(hargaController.text.trim()),
                      );
                    }
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(jadwal == null ? 'Jadwal berhasil ditambahkan!' : 'Jadwal berhasil diperbarui!'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String filmJudul) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Apakah Anda yakin ingin menghapus jadwal untuk "$filmJudul"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () async {
              await Provider.of<JadwalProvider>(context, listen: false).deleteJadwal(id);
              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jadwal berhasil dihapus'), backgroundColor: AppTheme.accentRed),
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
    final jadwalProvider = Provider.of<JadwalProvider>(context);

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
                  'Kelola Jadwal',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showFormDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Jadwal'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            jadwalProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Film')),
                          DataColumn(label: Text('Studio')),
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('Jam')),
                          DataColumn(label: Text('Harga Tiket')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: jadwalProvider.jadwalList.map((j) {
                          return DataRow(
                            cells: [
                              DataCell(Text(j.judulFilm, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(j.namaStudio)),
                              DataCell(Text(Formatters.formatShortDate(j.tanggal))),
                              DataCell(Text(j.jam, style: const TextStyle(color: AppTheme.primaryGold))),
                              DataCell(Text(Formatters.currency(j.hargaTiket))),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppTheme.primaryGold),
                                      onPressed: () => _showFormDialog(context, j),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppTheme.accentRed),
                                      onPressed: () => _confirmDelete(context, j.id, j.judulFilm),
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
