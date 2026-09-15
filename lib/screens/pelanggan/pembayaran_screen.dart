import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaksi_model.dart';
import '../../models/promo_model.dart';
import '../../providers/transaksi_provider.dart';
import '../../providers/kursi_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import 'notifikasi_screen.dart';
import 'midtrans_snap_screen.dart';

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
  String _selectedMethod = 'DANA';
  final _accountNumberController = TextEditingController(text: '085872254708');
  final _promoCodeController = TextEditingController();

  PromoModel? _appliedPromo;
  double _discountAmount = 0;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) return;

    final promo = PromoService.findByCode(code);
    if (promo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Kode promo tidak ditemukan / tidak valid.'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final discount = promo.calculateDiscount(widget.transaksi.totalHarga, 'TICKET');
    if (discount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Promo "${promo.title}" membutuhkan minimal transaksi ${Formatters.currency(promo.minPurchase)}'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    setState(() {
      _appliedPromo = promo;
      _discountAmount = discount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Promo "${promo.title}" berhasil digunakan! Diskon: ${Formatters.currency(discount)}'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  double get _finalTotal {
    final total = widget.transaksi.totalHarga - _discountAmount;
    return total < 0 ? 0 : total;
  }

  String _getMethodName(String method) {
    switch (method) {
      case 'DANA':
        return 'DANA';
      case 'GOPAY':
        return 'GoPay';
      case 'OVO':
        return 'OVO';
      case 'SHOPEEPAY':
        return 'ShopeePay';
      case 'QRIS':
      default:
        return 'QRIS';
    }
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'DANA':
        return const Color(0xFF118EEA);
      case 'GOPAY':
        return const Color(0xFF00AED6);
      case 'OVO':
        return const Color(0xFF7A34EC);
      case 'SHOPEEPAY':
        return const Color(0xFFEE4D2D);
      case 'QRIS':
      default:
        return AppTheme.primaryGold;
    }
  }

  void _processPayment() async {
    final totalToPay = _finalTotal;
    final phone = _accountNumberController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Silakan masukkan nomor HP / Akun E-Wallet Anda!'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final result = await Navigator.push<MidtransPaymentStatus>(
      context,
      MaterialPageRoute(
        builder: (_) => MidtransSnapScreen(
          orderId: widget.transaksi.id,
          grossAmount: totalToPay,
          itemName: 'Tiket Bioskop ${widget.transaksi.filmJudul} (${widget.transaksi.daftarKursi.join(", ")})',
          customerName: widget.transaksi.userEmail.split('@').first,
          customerEmail: widget.transaksi.userEmail,
          customerPhone: phone,
          initialMethod: _selectedMethod,
        ),
      ),
    );

    if (result == MidtransPaymentStatus.success && mounted) {
      final trxProvider = Provider.of<TransaksiProvider>(context, listen: false);
      bool success = await trxProvider.processPembayaran(
        transaksiId: widget.transaksi.id,
        metode: 'Midtrans (${_getMethodName(_selectedMethod)})',
      );

      if (success && mounted) {
        Provider.of<KursiProvider>(context, listen: false).reserveSeats(widget.kursiIdsToReserve);

        NotificationService().addNotification(
          userId: widget.transaksi.userId,
          title: '🎉 Pembayaran ${_getMethodName(_selectedMethod)} Berhasil!',
          message: 'Tiket bioskop ${widget.transaksi.filmJudul} (${widget.transaksi.daftarKursi.join(", ")}) berhasil diterbitkan melalui Midtrans.',
          icon: Icons.check_circle,
          color: AppTheme.accentGreen,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Pembayaran Berhasil! Tiket Anda telah aktif.'),
            backgroundColor: AppTheme.accentGreen,
            duration: Duration(seconds: 4),
          ),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else if (result == MidtransPaymentStatus.canceled && mounted) {
      NotificationService().addNotification(
        userId: widget.transaksi.userId,
        title: '❌ Pembayaran Dibatalkan',
        message: 'Pembayaran tiket film ${widget.transaksi.filmJudul} dibatalkan.',
        icon: Icons.cancel,
        color: AppTheme.accentRed,
      );
    }
  }

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
                    _buildRow('Subtotal', Formatters.currency(widget.transaksi.totalHarga)),
                    if (_appliedPromo != null) ...[
                      _buildRow('Promo (${_appliedPromo!.code})', '- ${Formatters.currency(_discountAmount)}', valueColor: AppTheme.accentGreen),
                    ],
                    const Divider(color: Colors.white10, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          Formatters.currency(_finalTotal),
                          style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gunakan Kode Promo / Voucher', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoCodeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan kode promo (ex: CINESTAR20)',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _applyPromo,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                          child: const Text('Gunakan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Metode Pembayaran:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0070BA),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'midtrans',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih salah satu metode pembayaran di bawah ini:',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 14),

            _buildPaymentOptionCard(
              methodKey: 'DANA',
              title: 'DANA E-Wallet',
              subtitle: 'Bayar otomatis via Saldo DANA & QR DANA',
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF118EEA),
            ),
            const SizedBox(height: 10),

            _buildPaymentOptionCard(
              methodKey: 'GOPAY',
              title: 'GoPay',
              subtitle: 'Bayar via Saldo GoPay & aplikasi Gojek',
              icon: Icons.phone_android,
              color: const Color(0xFF00AED6),
            ),
            const SizedBox(height: 10),

            _buildPaymentOptionCard(
              methodKey: 'OVO',
              title: 'OVO',
              subtitle: 'Bayar via Saldo OVO',
              icon: Icons.wallet,
              color: const Color(0xFF7A34EC),
            ),
            const SizedBox(height: 10),

            _buildPaymentOptionCard(
              methodKey: 'SHOPEEPAY',
              title: 'ShopeePay',
              subtitle: 'Bayar via Saldo ShopeePay',
              icon: Icons.shopping_bag,
              color: const Color(0xFFEE4D2D),
            ),
            const SizedBox(height: 10),

            _buildPaymentOptionCard(
              methodKey: 'QRIS',
              title: 'QRIS All Payment',
              subtitle: 'Scan QRIS via BCA Mobile, Mandiri, BRI, BNI & Semua Bank',
              icon: Icons.qr_code_scanner,
              color: AppTheme.primaryGold,
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone_android, color: _getMethodColor(_selectedMethod), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Nomor HP / Akun ${_getMethodName(_selectedMethod)} Anda:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _accountNumberController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Contoh: 081234567890',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _getMethodColor(_selectedMethod))),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '💡 Nomor ini digunakan untuk mencocokkan saldo masuk di akun bioskop.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            trxProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getMethodColor(_selectedMethod),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: Text(
                        'BAYAR DENGAN ${_getMethodName(_selectedMethod).toUpperCase()} • ${Formatters.currency(_finalTotal)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                      ),
                      onPressed: _processPayment,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionCard({
    required String methodKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMethod == methodKey;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = methodKey),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(25) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? color : Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: valueColor ?? Colors.white)),
        ],
      ),
    );
  }
}
