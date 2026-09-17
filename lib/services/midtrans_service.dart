import 'dart:math';
import 'api_service.dart';

class MidtransTransactionResult {
  final bool isSuccess;
  final String orderId;
  final String? snapToken;
  final String? redirectUrl;
  final String paymentType; // 'gopay', 'qris', 'bca_va', 'bri_va', 'bni_va', 'mandiri_va', 'credit_card'
  final String? vaNumber;
  final String? qrCodeUrl;
  final double grossAmount;
  final String message;

  MidtransTransactionResult({
    required this.isSuccess,
    required this.orderId,
    this.snapToken,
    this.redirectUrl,
    required this.paymentType,
    this.vaNumber,
    this.qrCodeUrl,
    required this.grossAmount,
    required this.message,
  });
}

class MidtransService {
  /// Menghasilkan Order ID unik untuk Midtrans
  static String generateOrderId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomDigits = Random().nextInt(900) + 100;
    return '$prefix-$timestamp-$randomDigits';
  }

  /// Meminta backend Laravel membuat transaksi Snap di Midtrans.
  static Future<MidtransTransactionResult> createSnapTransaction({
    required String orderId,
    required double grossAmount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String itemName,
    required int itemQty,
    String preferredPaymentType = 'qris',
  }) async {
    final payload = {
      'order_id': orderId,
      'gross_amount': grossAmount,
      'customer_name': customerName,
      'customer_email': customerEmail.isNotEmpty ? customerEmail : 'customer@cinema.id',
      'customer_phone': customerPhone.isNotEmpty ? customerPhone : '081234567890',
      'item_name': itemName.length > 50 ? itemName.substring(0, 50) : itemName,
      'item_qty': itemQty,
    };

    final result = await ApiService.post('/payments/midtrans', payload);
    final data = result?['data'];
    if (result?['status'] != 'success' || data is! Map<String, dynamic> || data['token'] == null) {
      throw StateError(result?['message']?.toString() ?? 'Backend Midtrans tidak mengembalikan token pembayaran.');
    }

    return MidtransTransactionResult(
      isSuccess: true,
      orderId: orderId,
      snapToken: data['token'].toString(),
      redirectUrl: data['redirect_url']?.toString(),
      paymentType: preferredPaymentType,
      vaNumber: null,
      grossAmount: grossAmount,
      message: 'Transaksi Midtrans Snap berhasil dibuat.',
    );
  }

  /// Membuat nomor Virtual Account realistis berdasarkan bank
  /// Cek status transaksi ke Midtrans Core API
  static Future<Map<String, dynamic>?> checkTransactionStatus(String orderId) async {
    final result = await ApiService.get('/payments/midtrans/$orderId/status');
    return result?['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(result!['data'] as Map)
        : null;
  }
}
