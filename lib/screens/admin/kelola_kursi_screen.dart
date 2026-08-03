import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/kursi_provider.dart';
import '../../providers/studio_provider.dart';
import '../../models/kursi_model.dart';
import '../../utils/theme.dart';

class KelolaKursiScreen extends StatefulWidget {
  const KelolaKursiScreen({super.key});

  @override
  State<KelolaKursiScreen> createState() => _KelolaKursiScreenState();
}

class _KelolaKursiScreenState extends State<KelolaKursiScreen> {
  String? _selectedStudioFilter;

  void _showFormDialog(BuildContext context, [KursiModel? kursi]) {
    final studioProvider = Provider.of<StudioProvider>(context, listen: false);
    if (studioProvider.studios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan studio terlebih dahulu!')),
      );
      return;
    }

    String selectedStudioId = kursi?.studioId ?? studioProvider.studios.first.id;
    final nomorKursiController = TextEditingController(text: kursi?.nomorKursi ?? '');
    String status = kursi?.status ?? 'Tersedia';

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(kursi == null ? 'Tambah Kursi' : 'Edit Kursi'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                TextFormField(
                  controller: nomorKursiController,
                  decoration: const InputDecoration(labelText: 'Nomor Kursi (e.g. A1, B3)'),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status Kursi'),
                  dropdownColor: AppTheme.cardBgLight,
                  items: ['Tersedia', 'Dipesan'].map((st) {
                    return DropdownMenuItem(value: st, child: Text(st));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => status = val);
                  },
                ),
              ],
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
                  final kursiProvider = Provider.of<KursiProvider>(context, listen: false);
                  final studioProvider = Provider.of<StudioProvider>(context, listen: false);
                  final studio = studioProvider.getStudioById(selectedStudioId);
                  final namaStudio = studio?.namaStudio ?? '';

                  if (kursi == null) {
                    await kursiProvider.addKursi(
                      studioId: selectedStudioId,
                      namaStudio: namaStudio,
                      nomorKursi: nomorKursiController.text.trim().toUpperCase(),
                      status: status,
                    );
                  } else {
                    await kursiProvider.updateKursi(
                      id: kursi.id,
                      studioId: selectedStudioId,
                      namaStudio: namaStudio,
                      nomorKursi: nomorKursiController.text.trim().toUpperCase(),
                      status: status,
                    );
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(kursi == null ? 'Kursi berhasil ditambahkan!' : 'Kursi berhasil diperbarui!'),
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

  void _confirmDelete(BuildContext context, String kursiId, String nomor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kursi'),
        content: Text('Apakah Anda yakin ingin menghapus kursi "$nomor"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () async {
              await Provider.of<KursiProvider>(context, listen: false).deleteKursi(kursiId);
              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kursi berhasil dihapus'), backgroundColor: AppTheme.accentRed),
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
    final kursiProvider = Provider.of<KursiProvider>(context);
    final studioProvider = Provider.of<StudioProvider>(context);

    final filteredKursi = _selectedStudioFilter == null
        ? kursiProvider.kursiList
        : kursiProvider.kursiList.where((k) => k.studioId == _selectedStudioFilter).toList();

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
                  'Kelola Kursi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showFormDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Kursi'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Studio Filter Dropdown
            Row(
              children: [
                const Text('Filter Studio: ', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(width: 10),
                DropdownButton<String?>(
                  value: _selectedStudioFilter,
                  hint: const Text('Semua Studio', style: TextStyle(color: AppTheme.primaryGold)),
                  dropdownColor: AppTheme.cardBgLight,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Semua Studio')),
                    ...studioProvider.studios.map((s) => DropdownMenuItem<String?>(value: s.id, child: Text(s.namaStudio))),
                  ],
                  onChanged: (val) => setState(() => _selectedStudioFilter = val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            kursiProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Studio')),
                          DataColumn(label: Text('Nomor Kursi')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: filteredKursi.map((kursi) {
                          final isAvailable = kursi.isTersedia;
                          return DataRow(
                            cells: [
                              DataCell(Text(kursi.namaStudio)),
                              DataCell(Text(kursi.nomorKursi, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isAvailable ? AppTheme.accentGreen : AppTheme.accentRed).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isAvailable ? AppTheme.accentGreen : AppTheme.accentRed,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    kursi.status,
                                    style: TextStyle(
                                      color: isAvailable ? AppTheme.accentGreen : AppTheme.accentRed,
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
                                      onPressed: () => _showFormDialog(context, kursi),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppTheme.accentRed),
                                      onPressed: () => _confirmDelete(context, kursi.id, kursi.nomorKursi),
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
