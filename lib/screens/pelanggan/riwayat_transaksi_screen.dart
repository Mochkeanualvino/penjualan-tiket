import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class RiwayatTransaksiScreen extends StatelessWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final trxProvider = Provider.of<TransaksiProvider>(context);
    final myTransactions = trxProvider.getTransaksiByUser(auth.currentUser?.id ?? '');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Tiket Saya',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 16),

            myTransactions.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text(
                          'Anda belum memiliki riwayat pesanan tiket.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myTransactions.length,
                    itemBuilder: (ctx, index) {
                      final trx = myTransactions[index];
                      Color statusColor = AppTheme.primaryGold;
                      if (trx.status == 'Berhasil') statusColor = AppTheme.accentGreen;
                      if (trx.status == 'Dibatalkan') statusColor = AppTheme.accentRed;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    trx.id,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 13),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: statusColor, width: 0.8),
                                    ),
                                    child: Text(
                                      trx.status,
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 20),
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      trx.posterUrl,
                                      width: 60,
                                      height: 85,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, _, __) => Container(
                                        width: 60,
                                        height: 85,
                                        color: Colors.grey.shade900,
                                        child: const Icon(Icons.movie, color: AppTheme.primaryGold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(trx.filmJudul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                        const SizedBox(height: 4),
                                        Text('Studio: ${trx.namaStudio}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                        Text('Jam: ${trx.jamTayang}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                        Text('Kursi: ${trx.daftarKursi.join(", ")}', style: const TextStyle(color: AppTheme.primaryGold, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Metode: ${trx.pembayaran?.metode ?? "QRIS"}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                  Text(
                                    Formatters.currency(trx.totalHarga),
                                    style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
