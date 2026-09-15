import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../models/food_model.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../services/auto_save_service.dart';
import '../../widgets/auto_save_status_indicator.dart';

class KelolaMakananScreen extends StatelessWidget {
  const KelolaMakananScreen({super.key});

  void _showFormDialog(BuildContext context, [FoodModel? food]) {
    final namaController = TextEditingController(text: food?.nama ?? '');
    final hargaController = TextEditingController(text: food != null ? food.harga.toInt().toString() : '');
    final kategoriController = TextEditingController(text: food?.kategori ?? 'Makanan');
    final imageController = TextEditingController(text: food?.imageUrl ?? '');
    final diskonHariController = TextEditingController(text: food?.diskonHari ?? '');
    final diskonPersenController = TextEditingController(text: food != null ? food.diskonPersen.toString() : '0');

    final formKey = GlobalKey<FormState>();
    final String draftKey = food == null ? 'form_food_tambah' : 'form_food_edit_${food.id}';

    // Auto-restore draft
    if (food == null) {
      final draft = AutoSaveService.loadDraft(draftKey);
      if (draft != null) {
        namaController.text = draft['nama'] ?? '';
        hargaController.text = draft['harga'] ?? '';
        kategoriController.text = draft['kategori'] ?? 'Makanan';
        imageController.text = draft['imageUrl'] ?? '';
        diskonHariController.text = draft['diskonHari'] ?? '';
        diskonPersenController.text = draft['diskonPersen'] ?? '0';
      }
    }

    AutoSaveStatus currentStatus = AutoSaveStatus.idle;

    void triggerAutoSave(StateSetter setStateDialog) {
      AutoSaveService.onInputChanged(
        formKey: draftKey,
        data: {
          'nama': namaController.text,
          'harga': hargaController.text,
          'kategori': kategoriController.text,
          'imageUrl': imageController.text,
          'diskonHari': diskonHariController.text,
          'diskonPersen': diskonPersenController.text,
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
          void addAutoSaveListeners() {
            void listener() => triggerAutoSave(setStateDialog);
            namaController.removeListener(listener);
            hargaController.removeListener(listener);
            imageController.removeListener(listener);
            diskonPersenController.removeListener(listener);
            namaController.addListener(listener);
            hargaController.addListener(listener);
            imageController.addListener(listener);
            diskonPersenController.addListener(listener);
          }
          addAutoSaveListeners();

          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food == null ? 'Tambah Menu Makanan' : 'Edit Menu Makanan'),
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
                    TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(labelText: 'Nama Makanan / Minuman'),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: ['Makanan', 'Minuman', 'Popcorn', 'Camilan', 'Paket'].contains(kategoriController.text)
                          ? kategoriController.text
                          : 'Makanan',
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      dropdownColor: AppTheme.cardBgLight,
                      items: ['Makanan', 'Minuman', 'Popcorn', 'Camilan', 'Paket'].map((k) {
                        return DropdownMenuItem(value: k, child: Text(k));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          kategoriController.text = val;
                          triggerAutoSave(setStateDialog);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'].contains(diskonHariController.text)
                          ? diskonHariController.text
                          : '',
                      decoration: const InputDecoration(
                        labelText: 'Ketentuan Promo Diskon Hari',
                        hintText: 'Pilih hari khusus promo',
                      ),
                      dropdownColor: AppTheme.cardBgLight,
                      items: [
                        const DropdownMenuItem(value: '', child: Text('Tidak ada diskon hari')),
                        const DropdownMenuItem(value: 'Jumat', child: Text('🎉 Promo Jumat Hemat')),
                        const DropdownMenuItem(value: 'Senin', child: Text('🎈 Promo Senin Ceria')),
                        const DropdownMenuItem(value: 'Rabu', child: Text('🍿 Promo Rabu Hemat')),
                        const DropdownMenuItem(value: 'Sabtu', child: Text('⭐ Promo Weekend Sabtu')),
                        const DropdownMenuItem(value: 'Minggu', child: Text('⭐ Promo Weekend Minggu')),
                      ].toList(),
                      onChanged: (val) {
                        if (val != null) {
                          diskonHariController.text = val;
                          triggerAutoSave(setStateDialog);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: diskonPersenController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Diskon (%)',
                        hintText: 'Misal: 15 untuk diskon 15%',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: 'URL Gambar',
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
                    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
                    final nama = namaController.text.trim();
                    final hargaClean = hargaController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                    final harga = double.tryParse(hargaClean) ?? 0.0;
                    final kategori = kategoriController.text.trim();
                    final img = imageController.text.trim();
                    final diskonHari = diskonHariController.text.trim();
                    final diskonClean = diskonPersenController.text.replaceAll(RegExp(r'[^0-9]'), '');
                    final diskonPersen = int.tryParse(diskonClean) ?? 0;

                    if (food == null) {
                      await foodProvider.addFood(
                        nama: nama,
                        harga: harga,
                        kategori: kategori,
                        imageUrl: img,
                        diskonHari: diskonHari,
                        diskonPersen: diskonPersen,
                      );
                    } else {
                      await foodProvider.updateFood(
                        id: food.id,
                        nama: nama,
                        harga: harga,
                        kategori: kategori,
                        imageUrl: img,
                        diskonHari: diskonHari,
                        diskonPersen: diskonPersen,
                      );
                    }
                    AutoSaveService.clearDraft(draftKey);
                    if (ctx.mounted) Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(food == null ? 'Menu makanan berhasil ditambahkan!' : 'Menu makanan berhasil diperbarui!'),
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

  void _confirmDelete(BuildContext context, String foodId, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Menu Makanan'),
        content: Text('Apakah Anda yakin ingin menghapus "$nama"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () async {
              await Provider.of<FoodProvider>(context, listen: false).deleteFood(foodId);
              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu makanan dihapus'), backgroundColor: AppTheme.accentRed),
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
    final foodProvider = Provider.of<FoodProvider>(context);

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
                  'Kelola Menu Makanan (m.food)',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showFormDialog(context),
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Tambah Menu'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            foodProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Foto')),
                          DataColumn(label: Text('Nama Makanan')),
                          DataColumn(label: Text('Kategori')),
                          DataColumn(label: Text('Harga Normal')),
                          DataColumn(label: Text('Ketentuan Diskon')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: foodProvider.foods.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, _, __) => Container(
                                      width: 45,
                                      height: 45,
                                      color: Colors.grey.shade800,
                                      child: const Icon(Icons.fastfood, size: 20, color: Colors.white54),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(item.kategori)),
                              DataCell(Text(Formatters.currency(item.harga))),
                              DataCell(
                                item.diskonPersen > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withAlpha(40),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.redAccent),
                                        ),
                                        child: Text(
                                          '🎉 ${item.diskonHari}: Diskon ${item.diskonPersen}% (${Formatters.currency(item.hargaSetelahDiskon)})',
                                          style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : const Text('-', style: TextStyle(color: AppTheme.textMuted)),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppTheme.primaryGold),
                                      onPressed: () => _showFormDialog(context, item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppTheme.accentRed),
                                      onPressed: () => _confirmDelete(context, item.id, item.nama),
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
