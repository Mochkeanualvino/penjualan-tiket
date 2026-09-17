import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../models/transaksi_model.dart';
import '../utils/theme.dart';

class QrTicketWidget extends StatelessWidget {
  final TransaksiModel transaksi;
  final bool compact;

  const QrTicketWidget({
    super.key,
    required this.transaksi,
    this.compact = false,
  });

  String get qrData => 'KENTICKET:${transaksi.id}:${transaksi.userId}';

  @override
  Widget build(BuildContext context) {
    final isUsed = transaksi.isUsed;

    if (compact) {
      return InkWell(
        onTap: () => _showQrDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isUsed
                ? Colors.grey.shade900.withAlpha(150)
                : AppTheme.primaryGold.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUsed ? Colors.grey.shade700 : AppTheme.primaryGold.withAlpha(128),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUsed ? Icons.qr_code_scanner_outlined : Icons.qr_code_2,
                color: isUsed ? Colors.grey : AppTheme.primaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isUsed ? 'Tiket Expired' : 'Tampilkan QR Tiket',
                style: TextStyle(
                  color: isUsed ? Colors.grey : AppTheme.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUsed ? Colors.grey.shade800 : AppTheme.primaryGold.withAlpha(80),
        ),
        boxShadow: [
          BoxShadow(
            color: isUsed ? Colors.black26 : AppTheme.primaryGold.withAlpha(20),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isUsed
                  ? Colors.red.withAlpha(40)
                  : AppTheme.accentGreen.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUsed ? Colors.redAccent : AppTheme.accentGreen,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUsed ? Icons.cancel_outlined : Icons.check_circle_outline,
                  color: isUsed ? Colors.redAccent : AppTheme.accentGreen,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isUsed ? 'SUDAH DIGUNAKAN (HANGUS)' : 'TIKET AKTIF - SIAP DI-SCAN',
                  style: TextStyle(
                    color: isUsed ? Colors.redAccent : AppTheme.accentGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Barcode / QR Code Container
          GestureDetector(
            onTap: () => _showQrDialog(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 180.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF14171F),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF14171F),
                    ),
                  ),
                ),

                // Overlay watermark jika sudah di-scan/digunakan
                if (isUsed)
                  Container(
                    width: 204,
                    height: 204,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(190),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.do_not_disturb_on,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'SUDAH DI-SCAN',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                        if (transaksi.usedAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM HH:mm').format(transaksi.usedAt!),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ID Tiket
          Text(
            'KODE TIKET: ${transaksi.id.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUsed
                ? 'Tiket ini telah di-scan dan tidak dapat digunakan lagi.'
                : 'Tunjukkan Kode QR ini kepada petugas bioskop saat masuk.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      transaksi.filmJudul,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 240.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'KODE: ${transaksi.id.toUpperCase()}',
                style: const TextStyle(
                  color: AppTheme.primaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${transaksi.namaStudio} • Kursi: ${transaksi.daftarKursi.join(", ")}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
