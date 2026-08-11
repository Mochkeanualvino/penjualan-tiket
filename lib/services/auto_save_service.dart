import 'dart:async';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';
import 'api_service.dart';

enum AutoSaveStatus {
  idle,
  saving,
  saved,
  error,
}

/// Service yang mengelola simpan otomatis (Auto-Save) data yang di-input pengguna.
/// Bekerja secara real-time dengan debounce untuk mencegah spam save,
/// lalu menyimpan draft ke LocalStorage dan mensinkronkan ke Laravel API.
class AutoSaveService extends ChangeNotifier {
  static final Map<String, Timer> _debouncers = {};
  static final Map<String, AutoSaveStatus> _formStatuses = {};

  /// Dapatkan status auto-save terkini untuk suatu form
  static AutoSaveStatus getStatus(String formKey) {
    return _formStatuses[formKey] ?? AutoSaveStatus.idle;
  }

  /// Panggil fungsi ini setiap kali nilai pada input field / dropdown berubah (onChanged)
  static void onInputChanged({
    required String formKey,
    required Map<String, dynamic> data,
    VoidCallback? onStatusChanged,
    int debounceMs = 500,
  }) {
    _formStatuses[formKey] = AutoSaveStatus.saving;
    onStatusChanged?.call();

    // Cancel timer sebelumnya jika user masih mengetik
    if (_debouncers.containsKey(formKey)) {
      _debouncers[formKey]?.cancel();
    }

    _debouncers[formKey] = Timer(Duration(milliseconds: debounceMs), () async {
      try {
        // 1. Simpan ke Local Storage (SharedPreferences)
        await LocalStorageService.saveMap('draft_$formKey', data);

        // 2. Simpan/Sync ke Laravel REST API
        await ApiService.saveInputDraft(formKey, data);

        _formStatuses[formKey] = AutoSaveStatus.saved;
        onStatusChanged?.call();

        // Kembalikan ke idle setelah 3 detik
        Timer(const Duration(seconds: 3), () {
          if (_formStatuses[formKey] == AutoSaveStatus.saved) {
            _formStatuses[formKey] = AutoSaveStatus.idle;
            onStatusChanged?.call();
          }
        });
      } catch (e) {
        debugPrint('AutoSaveService error: $e');
        _formStatuses[formKey] = AutoSaveStatus.error;
        onStatusChanged?.call();
      }
    });
  }

  /// Muat draft input yang tersimpan sebelumnya untuk dipulihkan ke form
  static Map<String, dynamic>? loadDraft(String formKey) {
    return LocalStorageService.loadMap('draft_$formKey');
  }

  /// Hapus draft input (panggil saat form berhasil di-submit)
  static Future<void> clearDraft(String formKey) async {
    await LocalStorageService.remove('draft_$formKey');
    _formStatuses[formKey] = AutoSaveStatus.idle;
  }
}
