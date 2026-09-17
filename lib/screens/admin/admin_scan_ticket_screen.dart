import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../models/transaksi_model.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class AdminScanTicketScreen extends StatefulWidget {
  const AdminScanTicketScreen({super.key});

  @override
  State<AdminScanTicketScreen> createState() => _AdminScanTicketScreenState();
}

class _AdminScanTicketScreenState extends State<AdminScanTicketScreen> {
  final TextEditingController _codeController = TextEditingController();
  Map<String, dynamic>? _scanResult;
  bool _isProcessing = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _processScan(String code) async {
    if (code.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _scanResult = null;
    });

    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final result = await transaksiProvider.scanDanValidasiTiket(code);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _scanResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaksiProvider = Provider.of<TransaksiProvider>(context);
    final allTrx = transaksiProvider.transaksiList;
    final validTrxList = allTrx.where((t) => t.status == 'Berhasil').toList();
    final usedTrxCount = validTrxList.where((t) => t.isUsed).length;
    final activeTrxCount = validTrxList.where((t) => !t.isUsed).length;

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, color: AppTheme.primaryGold),
            SizedBox(width: 8),
            Text('Scan & Validasi Tiket', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: AppTheme.bgBlack,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stat Header Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'TIKET AKTIF',
                    count: '$activeTrxCount',
                    icon: Icons.confirmation_number_outlined,
                    color: AppTheme.accentGreen,
                    subtext: 'Siap Masuk Studio',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'SUDAH DI-SCAN',
                    count: '$usedTrxCount',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.primaryGold,
                    subtext: 'Maks 1x Per User',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Input Scanner Section Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryGold.withAlpha(80)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PEMINDAIAN TIKET PELANGGAN',
                    style: TextStyle(
                      color: AppTheme.primaryGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Masukkan Kode Tiket atau Tempelkan Hasil Scan QR (Contoh: trx_1001 atau KENTICKET:trx_1001)',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Input Box & Action Button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Ketik Kode / ID Tiket...',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            prefixIcon: const Icon(Icons.qr_code, color: AppTheme.primaryGold),
                            filled: true,
                            fillColor: const Color(0xFF1A1F2C),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppTheme.primaryGold, width: 2),
                            ),
                          ),
                          onSubmitted: (val) => _processScan(val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isProcessing
                            ? null
                            : () => _processScan(_codeController.text),
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Icon(Icons.search_sharp),
                        label: const Text('SCAN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Scan Result Feedback Display
            if (_scanResult != null) _buildScanResultCard(_scanResult!),

            const SizedBox(height: 28),

            // Daftar Tiket Resmi Siap Scan (Quick Action for Admin)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DAFTAR TIKET TERBARU',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${validTrxList.length} Tiket Resmi',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            validTrxList.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Belum ada tiket pembayaran berhasil untuk di-scan.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: validTrxList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final trx = validTrxList[index];
                      return _buildTicketQuickRow(trx);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildScanResultCard(Map<String, dynamic> result) {
    final bool success = result['success'] == true;
    final bool alreadyUsed = result['alreadyUsed'] == true;
    final TransaksiModel? trx = result['transaksi'];
    final String message = result['message'] ?? '';

    Color bgBorderColor;
    IconData statusIcon;

    if (success) {
      bgBorderColor = AppTheme.accentGreen;
      statusIcon = Icons.check_circle_rounded;
    } else if (alreadyUsed) {
      bgBorderColor = Colors.orangeAccent;
      statusIcon = Icons.warning_amber_rounded;
    } else {
      bgBorderColor = AppTheme.accentRed;
      statusIcon = Icons.error_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgBorderColor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgBorderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: bgBorderColor.withAlpha(50),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: bgBorderColor, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success
                      ? 'TIKET RESMI & BERHASIL DI-SCAN!'
                      : (alreadyUsed ? 'TIKET PENERIMAAN PENONTON DITOLAK' : 'Gagal Memverifikasi Tiket'),
                  style: TextStyle(
                    color: bgBorderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),

          if (trx != null) ...[
            const Divider(color: Colors.white24, height: 24),
            Text(
              'INFORMASI TIKET:',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            _infoRow('Judul Film', trx.filmJudul, isBold: true),
            _infoRow('Nama Studio', trx.namaStudio),
            _infoRow('Jam & Tanggal', '${trx.jamTayang} • ${Formatters.formatShortDate(trx.tanggalTayang)}'),
            _infoRow('Nomor Kursi', trx.daftarKursi.join(', '), isHighlight: true),
            _infoRow('Email Pemesan', trx.userEmail),
            _infoRow('ID Transaksi', trx.id),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? AppTheme.primaryGold : Colors.white,
              fontWeight: (isBold || isHighlight) ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketQuickRow(TransaksiModel trx) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: trx.isUsed ? Colors.grey.shade800 : AppTheme.primaryGold.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: trx.isUsed ? Colors.grey.shade800 : AppTheme.primaryGold.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              trx.isUsed ? Icons.check_circle : Icons.qr_code_2,
              color: trx.isUsed ? Colors.grey : AppTheme.primaryGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trx.filmJudul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trx.namaStudio} • Kursi: ${trx.daftarKursi.join(", ")}',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                Text(
                  'ID: ${trx.id} • ${trx.userEmail}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: trx.isUsed ? Colors.grey.shade800 : AppTheme.primaryGold,
              foregroundColor: trx.isUsed ? Colors.grey.shade400 : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onPressed: () {
              _codeController.text = trx.id;
              _processScan(trx.id);
            },
            child: Text(
              trx.isUsed ? 'Ulang Scan' : 'Scan Tiket',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
