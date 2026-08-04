import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/jadwal_model.dart';
import '../services/local_storage_service.dart';

class JadwalProvider extends ChangeNotifier {
  final List<JadwalModel> _jadwalList = [];
  bool _isLoading = false;

  List<JadwalModel> get jadwalList => _jadwalList;
  bool get isLoading => _isLoading;

  JadwalProvider() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final saved = LocalStorageService.loadList(LocalStorageService.keyJadwal);
    if (saved.isNotEmpty) {
      _jadwalList.addAll(saved.map((m) => JadwalModel.fromMap(m, m['id'] ?? '')));
    } else {
      _seedInitialJadwal();
    }
  }

  Future<void> _autoSave() async {
    await LocalStorageService.saveList(
      LocalStorageService.keyJadwal,
      _jadwalList.map((j) => {'id': j.id, ...j.toMap()}).toList(),
    );
  }

  void _seedInitialJadwal() {
    final now = DateTime.now();
    _jadwalList.addAll([
      JadwalModel(
        id: 'jdw_1',
        filmId: 'film_1',
        judulFilm: 'Dune: Part Two',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
        studioId: 'std_1',
        namaStudio: 'Studio XXI 1',
        tanggal: now,
        jam: '14:30',
        hargaTiket: 50000,
      ),
      JadwalModel(
        id: 'jdw_2',
        filmId: 'film_1',
        judulFilm: 'Dune: Part Two',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
        studioId: 'std_3',
        namaStudio: 'IMAX Cinema',
        tanggal: now,
        jam: '19:00',
        hargaTiket: 75000,
      ),
      JadwalModel(
        id: 'jdw_3',
        filmId: 'film_2',
        judulFilm: 'Godzilla x Kong: The New Empire',
        posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
        studioId: 'std_2',
        namaStudio: 'Studio XXI 2',
        tanggal: now.add(const Duration(days: 1)),
        jam: '16:15',
        hargaTiket: 45000,
      ),
      JadwalModel(
        id: 'jdw_4',
        filmId: 'film_3',
        judulFilm: 'Oppenheimer',
        posterUrl: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?q=80&w=600&auto=format&fit=crop',
        studioId: 'std_4',
        namaStudio: 'Premiere Suite',
        tanggal: now,
        jam: '20:30',
        hargaTiket: 100000,
      ),
    ]);
  }

  List<JadwalModel> getJadwalByFilm(String filmId) {
    return _jadwalList.where((j) => j.filmId == filmId).toList();
  }

  JadwalModel? getJadwalById(String id) {
    try {
      return _jadwalList.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addJadwal({
    required String filmId,
    required String judulFilm,
    required String posterUrl,
    required String studioId,
    required String namaStudio,
    required DateTime tanggal,
    required String jam,
    required double hargaTiket,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final newJadwal = JadwalModel(
      id: const Uuid().v4(),
      filmId: filmId,
      judulFilm: judulFilm,
      posterUrl: posterUrl,
      studioId: studioId,
      namaStudio: namaStudio,
      tanggal: tanggal,
      jam: jam,
      hargaTiket: hargaTiket,
    );

    _jadwalList.add(newJadwal);
    _isLoading = false;
    notifyListeners();
    _autoSave();
  }

  Future<void> updateJadwal({
    required String id,
    required String filmId,
    required String judulFilm,
    required String posterUrl,
    required String studioId,
    required String namaStudio,
    required DateTime tanggal,
    required String jam,
    required double hargaTiket,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final index = _jadwalList.indexWhere((j) => j.id == id);
    if (index != -1) {
      _jadwalList[index] = JadwalModel(
        id: id,
        filmId: filmId,
        judulFilm: judulFilm,
        posterUrl: posterUrl,
        studioId: studioId,
        namaStudio: namaStudio,
        tanggal: tanggal,
        jam: jam,
        hargaTiket: hargaTiket,
      );
    }

    _isLoading = false;
    notifyListeners();
    _autoSave();
  }

  Future<void> deleteJadwal(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _jadwalList.removeWhere((j) => j.id == id);

    _isLoading = false;
    notifyListeners();
    _autoSave();
  }
}
