import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../services/midtrans_service.dart';
import '../../services/qris_service.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

enum MidtransPaymentStatus {
  success,
  pending,
  canceled,
  failed,
}

class MidtransSnapResult {
  final MidtransPaymentStatus status;
  final String? nomorPengirim;
  final String? nomorReferensi;

  const MidtransSnapResult({
    required this.status,
    this.nomorPengirim,
    this.nomorReferensi,
  });
}

class MidtransSnapScreen extends StatefulWidget {
  final String orderId;
  final double grossAmount;
  final String itemName;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String initialMethod;

  const MidtransSnapScreen({
    super.key,
    required this.orderId,
    required this.grossAmount,
    required this.itemName,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.initialMethod = 'DANA',
  });

  @override
  State<MidtransSnapScreen> createState() => _MidtransSnapScreenState();
}

class _MidtransSnapScreenState extends State<MidtransSnapScreen> {
  late String _selectedMethod;
  late TextEditingController _phoneController;
  int _remainingSeconds = 600; // 10 menit
  Timer? _countdownTimer;
  bool _isLoading = true;

  static const MethodChannel _galleryChannel = MethodChannel('com.bioskop.tiket_bioskop/gallery');

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod.toUpperCase();
    if (!['DANA', 'GOPAY', 'OVO', 'SHOPEEPAY', 'QRIS'].contains(_selectedMethod)) {
      _selectedMethod = 'DANA';
    }
    _phoneController = TextEditingController(text: widget.customerPhone.isNotEmpty ? widget.customerPhone : '085872254708');
    _initMidtransTransaction();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context, const MidtransSnapResult(status: MidtransPaymentStatus.canceled));
        }
      }
    });
  }

  Future<void> _initMidtransTransaction() async {
    await MidtransService.createSnapTransaction(
      orderId: widget.orderId,
      grossAmount: widget.grossAmount,
      customerName: widget.customerName,
      customerEmail: widget.customerEmail,
      customerPhone: widget.customerPhone,
      itemName: widget.itemName,
      itemQty: 1,
      preferredPaymentType: _selectedMethod.toLowerCase(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _finishPayment(MidtransPaymentStatus status, {String? nomorPengirim, String? nomorReferensi}) {
    _countdownTimer?.cancel();
    Navigator.pop(
      context,
      MidtransSnapResult(
        status: status,
        nomorPengirim: nomorPengirim ?? _phoneController.text.trim(),
        nomorReferensi: nomorReferensi,
      ),
    );
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

  String _getMethodDeeplink(String method) {
    switch (method) {
      case 'DANA':
        return 'dana://';
      case 'GOPAY':
        return 'gojek://gopay';
      case 'OVO':
        return 'ovo://';
      case 'SHOPEEPAY':
        return 'shopeeid://';
      case 'QRIS':
      default:
        return 'https://qris.id/';
    }
  }

  String _getMethodWebFallback(String method) {
    switch (method) {
      case 'DANA':
        return 'https://link.dana.id/';
      case 'GOPAY':
        return 'https://gopay.co.id/';
      case 'OVO':
        return 'https://www.ovo.id/';
      case 'SHOPEEPAY':
        return 'https://shopee.co.id/';
      case 'QRIS':
      default:
        return 'https://qris.id/';
    }
  }

  Future<void> _launchPaymentApp() async {
    final deeplink = _getMethodDeeplink(_selectedMethod);
    final webUrl = _getMethodWebFallback(_selectedMethod);

    try {
      final deepUri = Uri.parse(deeplink);
      if (await canLaunchUrl(deepUri)) {
        await launchUrl(deepUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    try {
      final webUri = Uri.parse(webUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _handlePayNow() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Silakan masukkan nomor HP / Akun ${_getMethodName(_selectedMethod)} Anda terlebih dahulu!'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    await _launchPaymentApp();

    if (!mounted) return;

    _showPaymentVerificationModal();
  }

  void _showPaymentVerificationModal() {
    bool isConfirmed = false;
    bool isVerifying = false;
    final refController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
            final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

            return Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getMethodColor(_selectedMethod).withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.account_balance_wallet, color: _getMethodColor(_selectedMethod), size: 28),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Konfirmasi Transfer ${_getMethodName(_selectedMethod)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Nomor Tujuan Penerima:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Row(
                              children: [
                                const Text(
                                  '085872254708',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 13),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(const ClipboardData(text: '085872254708'));
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      const SnackBar(content: Text('📋 Nomor tujuan disalin!'), duration: Duration(seconds: 1)),
                                    );
                                  },
                                  child: const Icon(Icons.copy, size: 14, color: AppTheme.primaryGold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Atas Nama Penerima:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('KENTICKET CINEMA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Nominal Pembayaran:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(
                              Formatters.currency(widget.grossAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentGreen, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Akun Pengirim:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(_phoneController.text.trim(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Input ID Referensi Transaksi
                  TextField(
                    controller: refController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Nomor ID Referensi Transaksi DANA (Opsional)',
                      labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                      hintText: 'Contoh: 202609151122... (dari struk DANA)',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      prefixIcon: const Icon(Icons.receipt_long, color: AppTheme.primaryGold, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryGold)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Box Alur Verifikasi Transparan
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withAlpha(80)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF60A5FA), size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Admin bioskop akan memeriksa mutasi saldo masuk di akun 085872254708. Tiket Anda berstatus "Menunggu Verifikasi Admin" dan otomatis aktif begitu saldo terkonfirmasi diterima.',
                            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    'Sisa Waktu: $minutes:$seconds',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 10),

                  // Checkbox konfirmasi wajib sebelum bisa klik kirim
                  Container(
                    decoration: BoxDecoration(
                      color: isConfirmed
                          ? AppTheme.accentGreen.withAlpha(20)
                          : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isConfirmed
                            ? AppTheme.accentGreen.withAlpha(120)
                            : Colors.white12,
                      ),
                    ),
                    child: CheckboxListTile(
                      value: isConfirmed,
                      onChanged: isVerifying
                          ? null
                          : (val) {
                              setModalState(() {
                                isConfirmed = val ?? false;
                              });
                            },
                      activeColor: AppTheme.accentGreen,
                      checkColor: Colors.black,
                      title: const Text(
                        'Saya menyatakan telah mentransfer saldo ke nomor tujuan penerima di atas.',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tombol kirim konfirmasi ke admin
                  if (isVerifying)
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primaryGold.withAlpha(60)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryGold,
                              strokeWidth: 2.5,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '📤 Mengirim konfirmasi ke Admin...',
                            style: TextStyle(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConfirmed
                              ? AppTheme.accentGreen
                              : Colors.grey.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: isConfirmed
                            ? () async {
                                setModalState(() {
                                  isVerifying = true;
                                });

                                await Future.delayed(const Duration(milliseconds: 1200));

                                if (mounted) {
                                  Navigator.pop(ctx);
                                  _finishPayment(
                                    MidtransPaymentStatus.pending,
                                    nomorPengirim: _phoneController.text.trim(),
                                    nomorReferensi: refController.text.trim().isNotEmpty
                                        ? refController.text.trim()
                                        : null,
                                  );
                                }
                              }
                            : () {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '❌ Harap lakukan transfer saldo terlebih dahulu dan centang konfirmasi!',
                                    ),
                                    backgroundColor: AppTheme.accentRed,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              },
                        icon: Icon(
                          isConfirmed ? Icons.send_rounded : Icons.block,
                          color: isConfirmed ? Colors.black : Colors.white54,
                          size: 18,
                        ),
                        label: Text(
                          isConfirmed
                              ? '📤 KIRIM KONFIRMASI KE ADMIN'
                              : '⚠️ CENTANG KONFIRMASI DULU',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isConfirmed ? Colors.black : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                  if (!isVerifying)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _getMethodColor(_selectedMethod)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _launchPaymentApp();
                              _showPaymentVerificationModal();
                            },
                            icon: Icon(Icons.refresh, size: 16, color: _getMethodColor(_selectedMethod)),
                            label: Text(
                              'Buka Ulang ${_getMethodName(_selectedMethod)}',
                              style: TextStyle(color: _getMethodColor(_selectedMethod), fontSize: 11),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => _finishPayment(MidtransPaymentStatus.canceled),
        ),
        title: const Text('Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withAlpha(120)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.redAccent, size: 14),
                  const SizedBox(width: 4),
                  Text('$minutes:$seconds', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF1E293B),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('Order ID: ${widget.orderId}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          Text(Formatters.currency(widget.grossAmount), style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryGold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: const Color(0xFF0F172A),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pilih Metode Pembayaran:', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMethodChip('DANA', '📱 DANA', const Color(0xFF118EEA)),
                            _buildMethodChip('GOPAY', '📱 GoPay', const Color(0xFF00AED6)),
                            _buildMethodChip('OVO', '📱 OVO', const Color(0xFF7A34EC)),
                            _buildMethodChip('SHOPEEPAY', '📱 ShopeePay', const Color(0xFFEE4D2D)),
                            _buildMethodChip('QRIS', '🔲 QRIS', AppTheme.primaryGold),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildQrAndInputContent(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    border: Border(top: BorderSide(color: Colors.white12)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getMethodColor(_selectedMethod),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _handlePayNow,
                      icon: const Icon(Icons.open_in_new, color: Colors.white, size: 20),
                      label: Text('BUKA APK ${_getMethodName(_selectedMethod).toUpperCase()} (BAYAR SEKARANG)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMethodChip(String methodKey, String label, Color color) {
    final isSelected = _selectedMethod == methodKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: color,
        backgroundColor: const Color(0xFF1E293B),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isSelected ? color : Colors.white12),
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedMethod = methodKey;
            });
          }
        },
      ),
    );
  }

  Widget _buildQrAndInputContent() {
    final qrisPayload = QrisService.generateValidQrisPayload(
      orderId: widget.orderId,
      grossAmount: widget.grossAmount,
      phone: '085872254708',
      merchantName: 'KENTICKET ${_getMethodName(_selectedMethod).toUpperCase()}',
    );
    final qrImageUrl = QrisService.getQrImageUrl(qrisPayload);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getMethodColor(_selectedMethod).withAlpha(120), width: 1.5),
          ),
          child: Column(
            children: [
              Text(
                'KODE QR PEMBAYARAN ${_getMethodName(_selectedMethod).toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _getMethodColor(_selectedMethod),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: 220,
                height: 220,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    qrImageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
                    },
                    errorBuilder: (ctx, error, stackTrace) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.qr_code_2, size: 130, color: Colors.black),
                        Text('QR Siap Digunakan', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Scan QR di atas menggunakan kamera smartphone atau aplikasi ${_getMethodName(_selectedMethod)}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _downloadQrCode(qrImageUrl),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('📥 UNDUH / SIMPAN KODE QR KE GALERI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.phone_android, color: _getMethodColor(_selectedMethod), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Nomor HP / Akun ${_getMethodName(_selectedMethod)} Anda:',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Masukkan nomor HP Anda (contoh: 081234567890)',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  prefixIcon: const Icon(Icons.account_circle, color: Colors.white54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _getMethodColor(_selectedMethod))),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '💡 Nomor ini akan digunakan untuk mencocokkan saldo masuk dan menerbitkan tiket secara resmi.',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _downloadQrCode(String imageUrl) async {
    try {
      if (kIsWeb) {
        final uri = Uri.parse(imageUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('📥 Membuka gambar QR di tab baru untuk disimpan...'),
                backgroundColor: AppTheme.accentGreen,
              ),
            );
          }
        }
        return;
      }

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        bool gallerySaved = false;

        try {
          if (Platform.isAndroid) {
            final fileName = 'QRIS_KENTICKET_${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}.png';
            final result = await _galleryChannel.invokeMethod<String>('saveImageToGallery', {
              'bytes': response.bodyBytes,
              'filename': fileName,
            });
            if (result != null && result.isNotEmpty) {
              gallerySaved = true;
            }
          }
        } catch (nativeErr) {
          debugPrint('Native gallery error: $nativeErr');
        }

        if (!gallerySaved) {
          Directory? dir;
          try {
            if (Platform.isAndroid) {
              final picturesDir = Directory('/storage/emulated/0/Pictures');
              if (await picturesDir.exists()) {
                dir = picturesDir;
              } else {
                dir = await getExternalStorageDirectory();
              }
            } else {
              dir = await getApplicationDocumentsDirectory();
            }
          } catch (_) {
            dir = await getApplicationDocumentsDirectory();
          }

          final fileName = 'QRIS_KENTICKET_${widget.orderId}.png';
          final filePath = '${dir?.path ?? ""}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🖼️ KODE QR BERHASIL DISIMPAN KE GALERI FOTO HP ANDA (Album Kenticket / Pictures)!'),
              backgroundColor: AppTheme.accentGreen,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception('Gagal menghubungi server QR (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error downloading QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Gagal menyimpan ke Galeri: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }
}
