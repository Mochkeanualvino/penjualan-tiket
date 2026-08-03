import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class KelolaTransaksiScreen extends StatelessWidget {
  const KelolaTransaksiScreen({super.key});

  void _showStatusDialog(BuildContext context, String transaksiId, String currentStatus) {
    String selectedStatus = currentStatus;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Ubah Status Transaksi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Pending', 'Berhasil', 'Dibatalkan'].map((st) {
              return RadioListTile<String>(
                title: Text(st),
                value: st,
                groupValue: selectedStatus,
                activeColor: AppTheme.primaryGold,
                onChanged: (val) {
                  if (val != null) setStateDialog(() => selectedStatus = val);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<TransaksiProvider>(context, listen: false)
                    .updateStatusTransaksi(transaksiId, selectedStatus);
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Status transaksi diperbarui ke $selectedStatus'),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transaksiProvider = Provider.of<TransaksiProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Transaksi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 20),
            transaksiProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID Transaksi')),
                          DataColumn(label: Text('Pelanggan')),
                          DataColumn(label: Text('Film')),
                          DataColumn(label: Text('Kursi')),
                          DataColumn(label: Text('Total Harga')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: transaksiProvider.transaksiList.map((trx) {
                          Color statusColor = AppTheme.primaryGold;
                          if (trx.status == 'Berhasil') statusColor = AppTheme.accentGreen;
                          if (trx.status == 'Dibatalkan') statusColor = AppTheme.accentRed;

                          return DataRow(
                            cells: [
                              DataCell(Text(trx.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold))),
                              DataCell(Text(trx.userEmail)),
                              DataCell(Text(trx.filmJudul)),
                              DataCell(Text(trx.daftarKursi.join(', '))),
                              DataCell(Text(Formatters.currency(trx.totalHarga))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: statusColor, width: 0.8),
                                  ),
                                  child: Text(
                                    trx.status,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.edit_note, color: AppTheme.primaryGold),
                                  onPressed: () => _showStatusDialog(context, trx.id, trx.status),
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
