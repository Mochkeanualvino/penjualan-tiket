import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/film_provider.dart';
import '../../providers/studio_provider.dart';
import '../../models/jadwal_model.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../services/auto_save_service.dart';
import '../../widgets/auto_save_status_indicator.dart';

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
    final String draftKey = jadwal == null ? 'form_jadwal_tambah' : 'form_jadwal_edit_${jadwal.id}';

    // Muat draft yang tersimpan sebelumnya (auto-restore)
    if (jadwal == null) {
      final draft = AutoSaveService.loadDraft(draftKey);
      if (draft != null) {
        jamController.text = draft['jam'] ?? '14:00';
        hargaController.text = draft['harga'] ?? '50000';
        if (draft['filmId'] != null) selectedFilmId = draft['filmId'];
        if (draft['studioId'] != null) selectedStudioId = draft['studioId'];
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          void listener() => triggerAutoSave(setStateDialog);
          jamController.removeListener(listener);
          hargaController.removeListener(listener);
          jamController.addListener(listener);
          hargaController.addListener(listener);

          final isFriday = selectedDate.weekday == DateTime.friday;
          final isMonday = selectedDate.weekday == DateTime.monday;

          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(jadwal == null ? 'Tambah Jadwal Tayang' : 'Edit Jadwal Tayang'),
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
                    DropdownButtonFormField<String>(
                      value: selectedFilmId,
                      decoration: const InputDecoration(labelText: 'Pilih Film'),
                      dropdownColor: AppTheme.cardBgLight,
                      items: filmProvider.films.map((f) {
                        return DropdownMenuItem(value: f.id, child: Text(f.judul));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => selectedFilmId = val);
                          triggerAutoSave(setStateDialog);
                        }
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
                        if (val != null) {
                          setStateDialog(() => selectedStudioId = val);
                          triggerAutoSave(setStateDialog);
                        }
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
                          setStateDialog(() {
                            selectedDate = picked;
                            if (picked.weekday == DateTime.friday) {
                              hargaController.text = '12000'; // Set default promo Jumat Hemat Rp 12.000
                            }
                          });
                          triggerAutoSave(setStateDialog);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Banner Notifikasi Ketentuan Diskon Hari/Tanggal Spesial
                    if (isFriday)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentGreen),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars, color: AppTheme.accentGreen, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🎉 Promo Hari Jumat Hemat Terdeteksi!', style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                                  const Text('Sesuai ketentuan promo hari Jumat, harga tiket berlaku diskon Rp 12.000.', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () {
                                      setStateDialog(() {
                                        hargaController.text = '12000';
                                      });
                                      triggerAutoSave(setStateDialog);
                                    },
                                    child: const Text('👉 Terapkan Harga Diskon Rp 12.000', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.underline)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isMonday)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.lightBlue),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.discount, color: Colors.lightBlue, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🎈 Promo Senin Ceria Terdeteksi!', style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                                  const Text('Sesuai ketentuan promo hari Senin, rekomendasi harga tiket: Rp 35.000.', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () {
                                      setStateDialog(() {
                                        hargaController.text = '35000';
                                      });
                                      triggerAutoSave(setStateDialog);
                                    },
                                    child: const Text('👉 Terapkan Harga Promo Rp 35.000', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.underline)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

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
                        content: Text(jadwal == null ? 'Jadwal berhasil ditambahkan!' : 'Jadwal berhasil diperbarui!'),
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
                          DataColumn(label: Text('Promo Ketentuan')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: jadwalProvider.jadwalList.map((j) {
                          final isFriday = j.tanggal.weekday == DateTime.friday;
                          final isMonday = j.tanggal.weekday == DateTime.monday;

                          return DataRow(
                            cells: [
                              DataCell(Text(j.judulFilm, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(j.namaStudio)),
                              DataCell(Text(Formatters.formatShortDate(j.tanggal))),
                              DataCell(Text(j.jam, style: const TextStyle(color: AppTheme.primaryGold))),
                              DataCell(Text(Formatters.currency(j.hargaTiket))),
                              DataCell(
                                isFriday
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGreen.withAlpha(40),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppTheme.accentGreen),
                                        ),
                                        child: const Text('🎉 Promo Jumat', style: TextStyle(color: AppTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                                      )
                                    : (isMonday
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withAlpha(40),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.lightBlue),
                                            ),
                                            child: const Text('🎈 Promo Senin', style: TextStyle(color: Colors.lightBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                                          )
                                        : const Text('-', style: TextStyle(color: AppTheme.textMuted))),
                              ),
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
