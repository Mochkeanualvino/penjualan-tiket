import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menyimpan dan memuat data secara otomatis ke penyimpanan lokal.
/// Setiap kali admin/pelanggan menambah, mengedit, atau menghapus data,
/// data langsung disimpan ke SharedPreferences dan tersedia kembali setelah restart.
class LocalStorageService {
  static SharedPreferences? _prefs;

  /// Inisialisasi SharedPreferences - dipanggil sekali di main.dart
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===== GENERIC SAVE/LOAD =====

  /// Simpan list of maps ke SharedPreferences
  static Future<void> saveList(String key, List<Map<String, dynamic>> data) async {
    if (_prefs == null) return;
    final jsonString = jsonEncode(data);
    await _prefs!.setString(key, jsonString);
  }

  /// Muat list of maps dari SharedPreferences
  static List<Map<String, dynamic>> loadList(String key) {
    if (_prefs == null) return [];
    final jsonString = _prefs!.getString(key);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Simpan single map
  static Future<void> saveMap(String key, Map<String, dynamic> data) async {
    if (_prefs == null) return;
    await _prefs!.setString(key, jsonEncode(data));
  }

  /// Muat single map
  static Map<String, dynamic>? loadMap(String key) {
    if (_prefs == null) return null;
    final jsonString = _prefs!.getString(key);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    } catch (_) {
      return null;
    }
  }

  /// Simpan string biasa
  static Future<void> saveString(String key, String value) async {
    if (_prefs == null) return;
    await _prefs!.setString(key, value);
  }

  /// Muat string biasa
  static String? loadString(String key) {
    if (_prefs == null) return null;
    return _prefs!.getString(key);
  }

  /// Cek apakah data pernah disimpan sebelumnya
  static bool hasData(String key) {
    if (_prefs == null) return false;
    return _prefs!.containsKey(key);
  }

  /// Hapus data berdasarkan key
  static Future<void> remove(String key) async {
    if (_prefs == null) return;
    await _prefs!.remove(key);
  }

  // ===== STORAGE KEYS =====
  static const String keyFilms = 'app_films';
  static const String keySegeraTayang = 'app_segera_tayang';
  static const String keyStudios = 'app_studios';
  static const String keyKursi = 'app_kursi';
  static const String keyJadwal = 'app_jadwal';
  static const String keyTransaksi = 'app_transaksi';
  static const String keyUsers = 'app_users';
  static const String keyCurrentUser = 'app_current_user';
  static const String keySelectedCity = 'app_selected_city';
}
