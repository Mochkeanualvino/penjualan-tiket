import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';

class QrisService {
  static const String defaultOwnerPhone = '085872254708';
  static const String defaultOwnerName = 'KENTICKET CINEMA';
  static const String _keyCustomQrisUrl = 'app_custom_qris_image_url';
  static const String _keyCustomQrisPayload = 'app_custom_qris_payload';

  /// Format TLV (Tag-Length-Value) sesuai standar EMVCo Bank Indonesia
  static String formatTlv(String tag, String value) {
    final length = value.length.toString().padLeft(2, '0');
    return '$tag$length$value';
  }

  /// Menghitung CRC16-CCITT (Polinomial 0x1021, Initial 0xFFFF)
  /// Standar wajib ASPI / Bank Indonesia untuk Tag 63 (4 Hexadecimal characters)
  static String calculateCrc16(String data) {
    int crc = 0xFFFF;
    final bytes = utf8.encode(data);

    for (int byte in bytes) {
      crc ^= (byte << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }

    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  /// Membangun string QRIS EMVCo valid dengan routing saldo ke nomor pemilik
  static String generateValidQrisPayload({
    required String orderId,
    required double grossAmount,
    String? phone,
    String? merchantName,
    String? city,
  }) {
    final targetPhone = phone ?? defaultOwnerPhone;
    final targetName = (merchantName ?? defaultOwnerName).toUpperCase();
    final targetCity = (city ?? 'JAKARTA').toUpperCase();

    // Cek jika ada custom QRIS payload yang disimpan admin
    final customPayload = LocalStorageService.loadString(_keyCustomQrisPayload);
    if (customPayload != null && customPayload.trim().isNotEmpty) {
      return customPayload.trim();
    }

    // Subtag 26 (Merchant Information LinkAja / DANA / Bank Mandiri)
    final subtag26 = StringBuffer()
      ..write(formatTlv('00', 'ID.LINKAJA.WWW'))
      ..write(formatTlv('01', '936009110021008709'))
      ..write(formatTlv('02', targetPhone))
      ..write(formatTlv('03', 'UME'));

    // Subtag 51 (Domestic Central Repository ASPI / GPN)
    final subtag51 = StringBuffer()
      ..write(formatTlv('00', 'ID.CO.QRIS.WWW'))
      ..write(formatTlv('01', 'ID1020021984719'))
      ..write(formatTlv('02', targetPhone))
      ..write(formatTlv('03', 'UME'));

    // Subtag 62 (Additional Data / Order Info)
    final subtag62 = StringBuffer()
      ..write(formatTlv('01', orderId.length > 25 ? orderId.substring(0, 25) : orderId))
      ..write(formatTlv('07', targetPhone));

    final amountStr = grossAmount.toInt().toString();

    // Payload tanpa Tag 63 (Checksum)
    final buffer = StringBuffer()
      ..write(formatTlv('00', '01')) // Payload Format Indicator
      ..write(formatTlv('01', '12')) // Dynamic QR (12)
      ..write(formatTlv('26', subtag26.toString())) // Merchant Info
      ..write(formatTlv('51', subtag51.toString())) // ASPI Repository
      ..write(formatTlv('52', '5812')) // Merchant Category Code (Cinema & Entertainment)
      ..write(formatTlv('53', '360')) // Mata Uang IDR (Rupiah)
      ..write(formatTlv('54', amountStr)) // Nominal Transaksi
      ..write(formatTlv('58', 'ID')) // Country Code
      ..write(formatTlv('59', targetName.length > 25 ? targetName.substring(0, 25) : targetName)) // Merchant Name
      ..write(formatTlv('60', targetCity)) // City
      ..write(formatTlv('61', '12950')) // Postal Code
      ..write(formatTlv('62', subtag62.toString())) // Additional Info
      ..write('6304'); // Tag 63 Length 04

    final dataToCrc = buffer.toString();
    final crc = calculateCrc16(dataToCrc);

    final finalPayload = '$dataToCrc$crc';
    debugPrint('Generated Valid QRIS (len: ${finalPayload.length}): $finalPayload');
    return finalPayload;
  }

  /// Mendapatkan URL gambar QR code beresolusi tinggi
  static String getQrImageUrl(String payload) {
    // Jika ada custom QRIS image URL dari admin
    final customUrl = LocalStorageService.loadString(_keyCustomQrisUrl);
    if (customUrl != null && customUrl.trim().isNotEmpty) {
      return customUrl.trim();
    }

    return 'https://api.qrserver.com/v1/create-qr-code/?size=360x360&margin=8&qzone=2&data=${Uri.encodeComponent(payload)}';
  }

  /// Simpan custom QRIS URL oleh Admin
  static Future<void> setCustomQrisUrl(String? url) async {
    if (url == null || url.trim().isEmpty) {
      await LocalStorageService.remove(_keyCustomQrisUrl);
    } else {
      await LocalStorageService.saveString(_keyCustomQrisUrl, url.trim());
    }
  }

  /// Simpan custom QRIS Payload oleh Admin
  static Future<void> setCustomQrisPayload(String? payload) async {
    if (payload == null || payload.trim().isEmpty) {
      await LocalStorageService.remove(_keyCustomQrisPayload);
    } else {
      await LocalStorageService.saveString(_keyCustomQrisPayload, payload.trim());
    }
  }
}
