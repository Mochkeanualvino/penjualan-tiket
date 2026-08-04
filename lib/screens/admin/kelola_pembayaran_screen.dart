import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class KelolaPembayaranScreen extends StatelessWidget {
  const KelolaPembayaranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transaksiProvider = Provider.of<TransaksiProvider>(context);
    final listPembayaran = transaksiProvider.transaksiList
        .where((t) => t.pembayaran != null)
        .map((t) => t.pembayaran!)
        .toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Pembayaran',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 20),
            listPembayaran.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'Belum ada data pembayaran terdaftar.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                  )
                : Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID Pembayaran')),
                          DataColumn(label: Text('ID Transaksi')),
                          DataColumn(label: Text('Metode')),
                          DataColumn(label: Text('Jumlah')),
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: listPembayaran.map((pay) {
                          Color statusColor = AppTheme.primaryGold;
                          if (pay.status == 'Berhasil') statusColor = AppTheme.accentGreen;
                          if (pay.status == 'Gagal') statusColor = AppTheme.accentRed;

                          return DataRow(
                            cells: [
                              DataCell(Text(pay.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold))),
                              DataCell(Text(pay.transaksiId)),
                              DataCell(Text(pay.metode)),
                              DataCell(Text(Formatters.currency(pay.jumlah))),
                              DataCell(Text(Formatters.formatShortDate(pay.tanggalPembayaran))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(51),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: statusColor, width: 0.8),
                                  ),
                                  child: Text(
                                    pay.status,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
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
