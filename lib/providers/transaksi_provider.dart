import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaksi_model.dart';
import '../models/pembayaran_model.dart';
import '../models/jadwal_model.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

class TransaksiProvider extends ChangeNotifier {
  final List<TransaksiModel> _transaksiList = [];
  bool _isLoading = false;

  List<TransaksiModel> get transaksiList => _transaksiList;
  bool get isLoading => _isLoading;

  TransaksiProvider() {
    _loadFromStorage();
    _syncFromApi(); // Sinkronisasi dari API Laravel
  }

  void _loadFromStorage() {
    final saved = LocalStorageService.loadList(LocalStorageService.keyTransaksi);
    if (saved.isNotEmpty) {
      _transaksiList.addAll(saved.map((m) => TransaksiModel.fromMap(m, m['id'] ?? '')));
    } else {
      _seedInitialTransaksi();
    }
  }

  /// Sinkronisasi data dari Laravel REST API (jika backend aktif)
  Future<void> _syncFromApi() async {
    try {
      final result = await ApiService.get('/transaksi');
      if (result != null && result['status'] == 'success' && result['data'] != null) {
        final List apiData = result['data'];
        if (apiData.isNotEmpty) {
          debugPrint('TransaksiProvider: ${apiData.length} transaksi dari API');
        }
      }
    } catch (e) {
      debugPrint('TransaksiProvider: API sync gagal (mode offline): $e');
    }
  }

  Future<void> _autoSave() async {
    await LocalStorageService.saveList(
      LocalStorageService.keyTransaksi,
      _transaksiList.map((t) => {'id': t.id, ...t.toMap()}).toList(),
    );
  }

  void _seedInitialTransaksi() {
    _transaksiList.add(
      TransaksiModel(
        id: 'trx_1001',
        userId: 'user_1',
        userEmail: 'pelanggan@bioskop.com',
        filmJudul: 'Dune: Part Two',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
        namaStudio: 'Studio XXI 1',
        tanggalTayang: DateTime.now(),
        jamTayang: '14:30',
        daftarKursi: ['A3', 'A4'],
        totalHarga: 100000,
        status: 'Berhasil',
        tanggalTransaksi: DateTime.now().subtract(const Duration(hours: 3)),
        pembayaran: PembayaranModel(
          id: 'pay_1001',
          transaksiId: 'trx_1001',
          metode: 'QRIS',
          status: 'Berhasil',
          jumlah: 100000,
          tanggalPembayaran: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ),
    );
  }

  List<TransaksiModel> getTransaksiByUser(String userId) {
    return _transaksiList.where((t) => t.userId == userId).toList();
  }

  Future<TransaksiModel> createTransaksi({
    required String userId,
    required String userEmail,
    required JadwalModel jadwal,
    required List<String> daftarKursi,
    required double totalHarga,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final newTrx = TransaksiModel(
      id: 'trx_${const Uuid().v4().substring(0, 8)}',
      userId: userId,
      userEmail: userEmail,
      filmJudul: jadwal.judulFilm,
      posterUrl: jadwal.posterUrl,
      namaStudio: jadwal.namaStudio,
      tanggalTayang: jadwal.tanggal,
      jamTayang: jadwal.jam,
      daftarKursi: daftarKursi,
      totalHarga: totalHarga,
      status: 'Pending',
      tanggalTransaksi: DateTime.now(),
      pembayaran: null,
    );

    _transaksiList.insert(0, newTrx);
    _isLoading = false;
    notifyListeners();
    _autoSave();

    // Sync ke API Laravel
    ApiService.post('/transaksi', {
      'user_id': userId,
      'jadwal_id': jadwal.id,
      'kursi_list': daftarKursi,
      'total_harga': totalHarga,
      'metode_pembayaran': 'Pending',
    });

    return newTrx;
  }

  Future<bool> processPembayaran({
    required String transaksiId,
    required String metode,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final index = _transaksiList.indexWhere((t) => t.id == transaksiId);
    if (index != -1) {
      final currentTrx = _transaksiList[index];
      final newPembayaran = PembayaranModel(
        id: 'pay_${const Uuid().v4().substring(0, 8)}',
        transaksiId: transaksiId,
        metode: metode,
        status: 'Berhasil',
        jumlah: currentTrx.totalHarga,
        tanggalPembayaran: DateTime.now(),
      );

      _transaksiList[index] = TransaksiModel(
        id: currentTrx.id,
        userId: currentTrx.userId,
        userEmail: currentTrx.userEmail,
        filmJudul: currentTrx.filmJudul,
        posterUrl: currentTrx.posterUrl,
        namaStudio: currentTrx.namaStudio,
        tanggalTayang: currentTrx.tanggalTayang,
        jamTayang: currentTrx.jamTayang,
        daftarKursi: currentTrx.daftarKursi,
        totalHarga: currentTrx.totalHarga,
        status: 'Berhasil',
        tanggalTransaksi: currentTrx.tanggalTransaksi,
        pembayaran: newPembayaran,
      );

      _isLoading = false;
      notifyListeners();
      _autoSave();

      // Sync status ke API Laravel
      ApiService.put('/transaksi/$transaksiId/status', {'status': 'Berhasil'});

      return true;
    }

    _isLoading = false;
    notifyListeners();
    _autoSave();
    return false;
  }

  Future<void> updateStatusTransaksi(String transaksiId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final index = _transaksiList.indexWhere((t) => t.id == transaksiId);
    if (index != -1) {
      final current = _transaksiList[index];
      _transaksiList[index] = TransaksiModel(
        id: current.id,
        userId: current.userId,
        userEmail: current.userEmail,
        filmJudul: current.filmJudul,
        posterUrl: current.posterUrl,
        namaStudio: current.namaStudio,
        tanggalTayang: current.tanggalTayang,
        jamTayang: current.jamTayang,
        daftarKursi: current.daftarKursi,
        totalHarga: current.totalHarga,
        status: newStatus,
        tanggalTransaksi: current.tanggalTransaksi,
        pembayaran: current.pembayaran != null
            ? PembayaranModel(
                id: current.pembayaran!.id,
                transaksiId: current.pembayaran!.transaksiId,
                metode: current.pembayaran!.metode,
                status: newStatus == 'Berhasil' ? 'Berhasil' : (newStatus == 'Dibatalkan' ? 'Gagal' : 'Pending'),
                jumlah: current.pembayaran!.jumlah,
                tanggalPembayaran: current.pembayaran!.tanggalPembayaran,
              )
            : null,
      );
    }

    _isLoading = false;
    notifyListeners();
    _autoSave();

    // Sync status ke API Laravel
    ApiService.put('/transaksi/$transaksiId/status', {'status': newStatus});
  }
}
