import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/kursi_model.dart';

class KursiProvider extends ChangeNotifier {
  final List<KursiModel> _kursiList = [];
  bool _isLoading = false;

  List<KursiModel> get kursiList => _kursiList;
  bool get isLoading => _isLoading;

  KursiProvider() {
    _seedInitialKursi();
  }

  void _seedInitialKursi() {
    // Generate sample seats for Studio XXI 1 (std_1)
    final rows = ['A', 'B', 'C', 'D', 'E'];
    for (var r in rows) {
      for (int i = 1; i <= 6; i++) {
        final seatNo = '$r$i';
        _kursiList.add(
          KursiModel(
            id: 'kursi_std1_$seatNo',
            studioId: 'std_1',
            namaStudio: 'Studio XXI 1',
            nomorKursi: seatNo,
            status: (seatNo == 'A3' || seatNo == 'B4') ? 'Dipesan' : 'Tersedia',
          ),
        );
      }
    }

    // Generate seats for Studio XXI 2 (std_2)
    for (var r in rows.take(4)) {
      for (int i = 1; i <= 5; i++) {
        final seatNo = '$r$i';
        _kursiList.add(
          KursiModel(
            id: 'kursi_std2_$seatNo',
            studioId: 'std_2',
            namaStudio: 'Studio XXI 2',
            nomorKursi: seatNo,
            status: seatNo == 'C2' ? 'Dipesan' : 'Tersedia',
          ),
        );
      }
    }
  }

  List<KursiModel> getKursiByStudio(String studioId) {
    return _kursiList.where((k) => k.studioId == studioId).toList();
  }

  Future<void> addKursi({
    required String studioId,
    required String namaStudio,
    required String nomorKursi,
    required String status,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final newKursi = KursiModel(
      id: const Uuid().v4(),
      studioId: studioId,
      namaStudio: namaStudio,
      nomorKursi: nomorKursi,
      status: status,
    );

    _kursiList.add(newKursi);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateKursi({
    required String id,
    required String studioId,
    required String namaStudio,
    required String nomorKursi,
    required String status,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final index = _kursiList.indexWhere((k) => k.id == id);
    if (index != -1) {
      _kursiList[index] = KursiModel(
        id: id,
        studioId: studioId,
        namaStudio: namaStudio,
        nomorKursi: nomorKursi,
        status: status,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteKursi(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _kursiList.removeWhere((k) => k.id == id);

    _isLoading = false;
    notifyListeners();
  }

  void reserveSeats(List<String> kursiIds) {
    for (var id in kursiIds) {
      final index = _kursiList.indexWhere((k) => k.id == id);
      if (index != -1) {
        final current = _kursiList[index];
        _kursiList[index] = KursiModel(
          id: current.id,
          studioId: current.studioId,
          namaStudio: current.namaStudio,
          nomorKursi: current.nomorKursi,
          status: 'Dipesan',
        );
      }
    }
    notifyListeners();
  }
}
