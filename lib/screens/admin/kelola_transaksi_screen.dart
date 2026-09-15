import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../providers/kursi_provider.dart';
import '../../models/transaksi_model.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class KelolaTransaksiScreen extends StatelessWidget {
  const KelolaTransaksiScreen({super.key});

  void _showDetailDialog(BuildContext context, TransaksiModel trx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: AppTheme.primaryGold, size: 22),
            const SizedBox(width: 8),
            Text('Rincian Transaksi ${trx.id}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Pelanggan:', trx.userEmail),
            _buildDetailRow('Film:', trx.filmJudul),
            _buildDetailRow('Studio & Kursi:', '${trx.namaStudio} (${trx.daftarKursi.join(", ")})'),
            _buildDetailRow('Total Harga:', Formatters.currency(trx.totalHarga), isHighlight: true),
            _buildDetailRow('Metode:', trx.pembayaran?.metode ?? 'Transfer E-Wallet'),
            _buildDetailRow('Rekening Penerima:', '085872254708 (KENTICKET)'),
            _buildDetailRow('Akun Pengirim:', trx.pembayaran?.nomorPengirim ?? '-'),
            _buildDetailRow('ID Referensi:', trx.pembayaran?.nomorReferensi ?? '-'),
            _buildDetailRow('Waktu Transaksi:', Formatters.formatShortDate(trx.tanggalTransaksi)),
            _buildDetailRow('Status Saat Ini:', trx.status, isStatus: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value, {bool isHighlight = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isHighlight ? AppTheme.accentGreen : (isStatus ? AppTheme.primaryGold : Colors.white),
                fontWeight: isHighlight || isStatus ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiTerimaSaldo(BuildContext context, TransaksiModel trx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 24),
            SizedBox(width: 8),
            Text('Konfirmasi Saldo Masuk', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pastikan Anda telah memeriksa mutasi saldo di akun DANA/Penerima:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Nominal Masuk:', Formatters.currency(trx.totalHarga), isHighlight: true),
                  _buildDetailRow('Akun Pengirim:', trx.pembayaran?.nomorPengirim ?? '-'),
                  _buildDetailRow('ID Referensi:', trx.pembayaran?.nomorReferensi ?? '-'),
                  _buildDetailRow('Akun Tujuan:', '085872254708'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Setelah dikonfirmasi, status transaksi akan berubah menjadi "Berhasil" dan tiket pelanggan akan langsung aktif.',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
            onPressed: () async {
              await Provider.of<TransaksiProvider>(context, listen: false)
                  .konfirmasiPembayaranAdmin(trx.id);
              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Pembayaran ${trx.id} berhasil dikonfirmasi! Tiket pelanggan telah aktif.'),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            },
            child: const Text('Ya, Saldo Sudah Masuk', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _konfirmasiTolakSaldo(BuildContext context, TransaksiModel trx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: AppTheme.accentRed, size: 24),
            SizedBox(width: 8),
            Text('Tolak Pembayaran', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tolak transaksi ini karena saldo belum diterima di mutasi rekening penerima (085872254708)?',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              'ID Transaksi: ${trx.id}\nPelanggan: ${trx.userEmail}\nNominal: ${Formatters.currency(trx.totalHarga)}',
              style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 10),
            const Text(
              '⚠️ Kursi yang telah dipesan akan dilepas kembali ke status "Tersedia".',
              style: TextStyle(color: Colors.amber, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () async {
              // Lepas kursi kembali
              Provider.of<KursiProvider>(context, listen: false).releaseSeats(trx.daftarKursi);

              // Update status transaksi ke Ditolak
              await Provider.of<TransaksiProvider>(context, listen: false)
                  .tolakPembayaranAdmin(trx.id);

              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Transaksi ${trx.id} ditolak. Kursi telah dilepas kembali.'),
                  backgroundColor: AppTheme.accentRed,
                ),
              );
            },
            child: const Text('Ya, Tolak (Saldo Belum Masuk)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(BuildContext context, String transaksiId, String currentStatus) {
    String selectedStatus = currentStatus;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ubah Status Transaksi', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Menunggu Verifikasi', 'Berhasil', 'Ditolak', 'Dibatalkan'].map((st) {
              return RadioListTile<String>(
                title: Text(st, style: const TextStyle(color: Colors.white, fontSize: 13)),
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
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
              child: const Text('Simpan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transaksiProvider = Provider.of<TransaksiProvider>(context);
    final pendingTransactions = transaksiProvider.transaksiList
        .where((t) => t.status == 'Menunggu Verifikasi' || t.status == 'Pending')
        .toList();

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
                  'Kelola Transaksi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                ),
                Text(
                  'Total: ${transaksiProvider.transaksiList.length} Transaksi',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Banner Alert jika ada pembayaran Menunggu Verifikasi Saldo
            if (pendingTransactions.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withAlpha(120), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.amber, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🔔 Ada ${pendingTransactions.length} Transaksi Menunggu Verifikasi Saldo Masuk!',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Periksa mutasi rekening penerima (085872254708). Klik tombol [Terima] jika saldo sudah masuk, atau [Tolak] jika saldo belum ada.',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            transaksiProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 16,
                        columns: const [
                          DataColumn(label: Text('ID Transaksi')),
                          DataColumn(label: Text('Pelanggan')),
                          DataColumn(label: Text('Film')),
                          DataColumn(label: Text('Kursi')),
                          DataColumn(label: Text('Total Harga')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Aksi & Verifikasi')),
                        ],
                        rows: transaksiProvider.transaksiList.map((trx) {
                          Color statusColor = AppTheme.primaryGold;
                          if (trx.status == 'Berhasil') statusColor = AppTheme.accentGreen;
                          if (trx.status == 'Ditolak' || trx.status == 'Dibatalkan') statusColor = AppTheme.accentRed;
                          if (trx.status == 'Menunggu Verifikasi' || trx.status == 'Pending') statusColor = Colors.amber;

                          final isPending = trx.status == 'Menunggu Verifikasi' || trx.status == 'Pending';

                          return DataRow(
                            cells: [
                              DataCell(
                                InkWell(
                                  onTap: () => _showDetailDialog(context, trx),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(trx.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.info_outline, size: 14, color: AppTheme.primaryGold),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(Text(trx.userEmail)),
                              DataCell(Text(trx.filmJudul)),
                              DataCell(Text(trx.daftarKursi.join(', '))),
                              DataCell(Text(Formatters.currency(trx.totalHarga))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(51),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: statusColor, width: 0.8),
                                  ),
                                  child: Text(
                                    trx.status,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isPending) ...[
                                      // Tombol Terima Saldo
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.accentGreen,
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        icon: const Icon(Icons.check, size: 14),
                                        label: const Text('Terima', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                        onPressed: () => _konfirmasiTerimaSaldo(context, trx),
                                      ),
                                      const SizedBox(width: 6),
                                      // Tombol Tolak Saldo
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.accentRed,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        icon: const Icon(Icons.close, size: 14),
                                        label: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                        onPressed: () => _konfirmasiTolakSaldo(context, trx),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    // Tombol Edit Status / Detail
                                    IconButton(
                                      icon: const Icon(Icons.edit_note, color: AppTheme.primaryGold),
                                      tooltip: 'Ubah Status',
                                      onPressed: () => _showStatusDialog(context, trx.id, trx.status),
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

