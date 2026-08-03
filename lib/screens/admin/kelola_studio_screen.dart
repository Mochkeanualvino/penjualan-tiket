import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/studio_provider.dart';
import '../../models/studio_model.dart';
import '../../utils/theme.dart';

class KelolaStudioScreen extends StatelessWidget {
  const KelolaStudioScreen({super.key});

  void _showFormDialog(BuildContext context, [StudioModel? studio]) {
    final namaController = TextEditingController(text: studio?.namaStudio ?? '');
    final kapasitasController = TextEditingController(text: studio != null ? studio.kapasitas.toString() : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(studio == null ? 'Tambah Studio' : 'Edit Studio'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Studio'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kapasitasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kapasitas Kursi'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
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
                final studioProvider = Provider.of<StudioProvider>(context, listen: false);
                if (studio == null) {
                  await studioProvider.addStudio(
                    namaStudio: namaController.text.trim(),
                    kapasitas: int.parse(kapasitasController.text.trim()),
                  );
                } else {
                  await studioProvider.updateStudio(
                    id: studio.id,
                    namaStudio: namaController.text.trim(),
                    kapasitas: int.parse(kapasitasController.text.trim()),
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(studio == null ? 'Studio berhasil ditambahkan!' : 'Studio berhasil diperbarui!'),
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

  void _confirmDelete(BuildContext context, String studioId, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Studio'),
        content: Text('Apakah Anda yakin ingin menghapus studio "$nama"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () async {
              await Provider.of<StudioProvider>(context, listen: false).deleteStudio(studioId);
              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Studio berhasil dihapus'), backgroundColor: AppTheme.accentRed),
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
    final studioProvider = Provider.of<StudioProvider>(context);

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
                  'Kelola Studio',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showFormDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Studio'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            studioProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID Studio')),
                          DataColumn(label: Text('Nama Studio')),
                          DataColumn(label: Text('Kapasitas Kursi')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: studioProvider.studios.map((studio) {
                          return DataRow(
                            cells: [
                              DataCell(Text(studio.id, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
                              DataCell(Text(studio.namaStudio, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text('${studio.kapasitas} Kursi')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppTheme.primaryGold),
                                      onPressed: () => _showFormDialog(context, studio),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppTheme.accentRed),
                                      onPressed: () => _confirmDelete(context, studio.id, studio.namaStudio),
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
