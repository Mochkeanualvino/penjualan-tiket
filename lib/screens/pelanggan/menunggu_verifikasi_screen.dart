import 'package:flutter/material.dart';
import '../../models/transaksi_model.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class MenungguVerifikasiScreen extends StatelessWidget {
  final TransaksiModel transaksi;
  final String metode;
  final String? nomorPengirim;
  final String? nomorReferensi;

  const MenungguVerifikasiScreen({
    super.key,
    required this.transaksi,
    required this.metode,
    this.nomorPengirim,
    this.nomorReferensi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text('Status Verifikasi Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Icon Status Animasi
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(30),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withAlpha(50),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 48),
            ),

            const SizedBox(height: 20),

            const Text(
              'Menunggu Verifikasi Saldo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bukti pembayaran Anda telah dikirimkan ke Admin bioskop untuk diverifikasi mutasi saldo masuk.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),

            const SizedBox(height: 24),

            // Card Rincian Transaksi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ID Transaksi:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(transaksi.id, style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Film:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Flexible(
                        child: Text(
                          transaksi.filmJudul,
                          textAlign: TextAlign.end,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Studio & Kursi:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(
                        '${transaksi.namaStudio} (${transaksi.daftarKursi.join(", ")})',
                        style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Metode Pembayaran:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(metode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nomor Tujuan Penerima:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const Text('085872254708 (KENTICKET)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                  if (nomorPengirim != null && nomorPengirim!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Akun Pengirim:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text(nomorPengirim!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ],
                  if (nomorReferensi != null && nomorReferensi!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ID Referensi:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text(nomorReferensi!, style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12)),
                      ],
                    ),
                  ],
                  const Divider(color: Colors.white10, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(
                        Formatters.currency(transaksi.totalHarga),
                        style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Box Informasi Verifikasi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withAlpha(80)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kursi bioskop Anda telah dicadangkan sementara. Begitu Admin memeriksa mutasi dan memastikan saldo masuk ke rekening penerima, tiket Anda akan langsung aktif secara otomatis.',
                      style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Navigasi
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                label: const Text('LIHAT STATUS DI TIKET SAYA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('KEMBALI KE BERANDA', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
