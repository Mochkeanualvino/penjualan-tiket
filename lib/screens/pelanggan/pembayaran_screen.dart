import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaksi_model.dart';
import '../../providers/transaksi_provider.dart';
import '../../providers/kursi_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class PembayaranScreen extends StatefulWidget {
  final TransaksiModel transaksi;
  final List<String> kursiIdsToReserve;

  const PembayaranScreen({
    super.key,
    required this.transaksi,
    required this.kursiIdsToReserve,
  });

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  String _selectedMethod = 'QRIS'; // 'Transfer Bank', 'QRIS', 'E-Wallet'

  @override
  Widget build(BuildContext context) {
    final trxProvider = Provider.of<TransaksiProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PEMBAYARAN TIKET'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan Pesanan', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(color: Colors.white10, height: 24),
                    _buildRow('ID Transaksi', widget.transaksi.id),
                    _buildRow('Film', widget.transaksi.filmJudul),
                    _buildRow('Studio', widget.transaksi.namaStudio),
                    _buildRow('Tanggal', Formatters.formatShortDate(widget.transaksi.tanggalTayang)),
                    _buildRow('Jam', widget.transaksi.jamTayang),
                    _buildRow('Kursi', widget.transaksi.daftarKursi.join(', ')),
                    const Divider(color: Colors.white10, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          Formatters.currency(widget.transaksi.totalHarga),
                          style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Pilih Metode Pembayaran:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 12),

            // Payment Methods Selection
            _buildMethodOption('QRIS Instant', 'Scan via GoPay, OVO, Dana, ShopeePay, LinkAja & All Bank', Icons.qr_code_2),
            _buildMethodOption('DANA', 'Pembayaran Otomatis e-Wallet DANA', Icons.account_balance_wallet),
            _buildMethodOption('GoPay', 'Pembayaran Otomatis e-Wallet GoPay', Icons.account_balance_wallet),
            _buildMethodOption('SeaBank', 'Transfer Virtual Account SeaBank', Icons.account_balance),
            _buildMethodOption('BRI', 'Transfer Virtual Account BRI (BRIVA)', Icons.account_balance),
            _buildMethodOption('BNI', 'Transfer Virtual Account BNI', Icons.account_balance),
            _buildMethodOption('BCA', 'Transfer Virtual Account BCA', Icons.account_balance),
            _buildMethodOption('Mandiri', 'Transfer Virtual Account Mandiri (Livin)', Icons.account_balance),

            const SizedBox(height: 32),

            trxProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool success = await trxProvider.processPembayaran(
                          transaksiId: widget.transaksi.id,
                          metode: _selectedMethod,
                        );

                        if (success) {
                          // Reserve selected seats in state
                          Provider.of<KursiProvider>(context, listen: false)
                              .reserveSeats(widget.kursiIdsToReserve);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pembayaran Berhasil! Tiket Bioskop Telah Diterbitkan.'),
                                backgroundColor: AppTheme.accentGreen,
                              ),
                            );

                            // Pop back to Customer Dashboard main view
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        }
                      },
                      child: const Text('BAYAR SEKARANG'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMethodOption(String value, String subtitle, IconData icon) {
    final isSelected = _selectedMethod == value;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryGold : Colors.white10,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedMethod,
        activeColor: AppTheme.primaryGold,
        onChanged: (val) {
          if (val != null) setState(() => _selectedMethod = val);
        },
        title: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryGold : AppTheme.textMuted, size: 22),
            const SizedBox(width: 10),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ),
      ),
    );
  }
}
