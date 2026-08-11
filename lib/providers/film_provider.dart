import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/film_model.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

class FilmProvider extends ChangeNotifier {
  final List<FilmModel> _films = [];
  final List<FilmModel> _segeraTayang = [];
  bool _isLoading = false;

  List<FilmModel> get films => _films;
  List<FilmModel> get segeraTayang => _segeraTayang;
  bool get isLoading => _isLoading;

  FilmProvider() {
    _loadFromStorage();
    _syncFromApi(); // Sinkronisasi dari API Laravel
  }

  /// Muat data dari penyimpanan lokal, jika kosong gunakan seed data
  void _loadFromStorage() {
    final savedFilms = LocalStorageService.loadList(LocalStorageService.keyFilms);
    final savedSegera = LocalStorageService.loadList(LocalStorageService.keySegeraTayang);

    if (savedFilms.isNotEmpty) {
      _films.addAll(savedFilms.map((m) => FilmModel.fromMap(m, m['id'] ?? '')));
    } else {
      _seedFilms();
    }

    if (savedSegera.isNotEmpty) {
      _segeraTayang.addAll(savedSegera.map((m) => FilmModel.fromMap(m, m['id'] ?? '')));
    } else {
      _seedSegeraTayang();
    }
  }

  /// Sinkronisasi data dari Laravel REST API (jika backend aktif)
  Future<void> _syncFromApi() async {
    try {
      final result = await ApiService.get('/films');
      if (result != null && result['status'] == 'success' && result['data'] != null) {
        final List apiFilms = result['data'];
        if (apiFilms.isNotEmpty) {
          _films.clear();
          _segeraTayang.clear();
          for (var f in apiFilms) {
            final film = FilmModel(
              id: f['id'] ?? '',
              judul: f['judul'] ?? '',
              genre: f['genre'] ?? '',
              durasi: f['durasi'] ?? 0,
              ratingUsia: f['rating_usia'] ?? 'SU',
              posterUrl: f['poster_url'] ?? '',
              isSegeraTayang: f['is_segera_tayang'] == true || f['is_segera_tayang'] == 1,
            );
            if (film.isSegeraTayang) {
              _segeraTayang.add(film);
            } else {
              _films.add(film);
            }
          }
          notifyListeners();
          _autoSave(); // Sync ke local storage juga
        }
      }
    } catch (e) {
      debugPrint('FilmProvider: API sync gagal (mode offline): $e');
    }
  }

  /// Simpan otomatis ke penyimpanan lokal
  Future<void> _autoSave() async {
    await LocalStorageService.saveList(
      LocalStorageService.keyFilms,
      _films.map((f) => {'id': f.id, ...f.toMap()}).toList(),
    );
    await LocalStorageService.saveList(
      LocalStorageService.keySegeraTayang,
      _segeraTayang.map((f) => {'id': f.id, ...f.toMap()}).toList(),
    );
  }

  void _seedFilms() {
    _films.addAll([
      FilmModel(id: 'film_1', judul: 'Kado Untuk Ibu', genre: 'Drama, Family', durasi: 92, ratingUsia: 'SU', posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=600&auto=format&fit=crop', isSegeraTayang: false),
      FilmModel(id: 'film_2', judul: 'IP Man: Kungfu Legend', genre: 'Action, Martial Arts', durasi: 172, ratingUsia: '13+', posterUrl: 'https://images.unsplash.com/photo-1509347528160-9a9e33742cdb?q=80&w=600&auto=format&fit=crop', isSegeraTayang: false),
      FilmModel(id: 'film_3', judul: 'Thunderbolts*', genre: 'Action, Superhero', durasi: 127, ratingUsia: '13+', posterUrl: 'https://images.unsplash.com/photo-1635805737707-575885ab0820?q=80&w=600&auto=format&fit=crop', isSegeraTayang: false),
      FilmModel(id: 'film_4', judul: 'Mission: Impossible - The Final Reckoning', genre: 'Action, Thriller', durasi: 169, ratingUsia: '13+', posterUrl: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?q=80&w=600&auto=format&fit=crop', isSegeraTayang: false),
      FilmModel(id: 'film_5', judul: 'Lilo & Stitch', genre: 'Animation, Comedy, Family', durasi: 108, ratingUsia: 'SU', posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop', isSegeraTayang: false),
      FilmModel(id: 'film_6', judul: 'Ballerina', genre: 'Action, Thriller', durasi: 114, ratingUsia: '17+', posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop', isSegeraTayang: false),
      FilmModel(id: 'film_7', judul: 'Ejen Ali The Movie 2', genre: 'Animation, Action', durasi: 110, ratingUsia: 'SU', posterUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=600&auto=format&fit=crop', isSegeraTayang: false),
      FilmModel(id: 'film_8', judul: 'Final Destination: Bloodlines', genre: 'Horror, Thriller', durasi: 110, ratingUsia: '17+', posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop', isSegeraTayang: false),
    ]);
  }

  void _seedSegeraTayang() {
    _segeraTayang.addAll([
      FilmModel(id: 'film_cs_1', judul: 'Superman', genre: 'Action, Superhero', durasi: 150, ratingUsia: '13+', posterUrl: 'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?q=80&w=600&auto=format&fit=crop', isSegeraTayang: true),
      FilmModel(id: 'film_cs_2', judul: 'Jurassic World Rebirth', genre: 'Action, Sci-Fi', durasi: 140, ratingUsia: '13+', posterUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?q=80&w=600&auto=format&fit=crop', isSegeraTayang: true),
      FilmModel(id: 'film_cs_3', judul: 'Avatar 3: Fire and Ash', genre: 'Action, Sci-Fi, Fantasy', durasi: 180, ratingUsia: '13+', posterUrl: 'https://images.unsplash.com/photo-1533613220915-609f661697d4?q=80&w=600&auto=format&fit=crop', isSegeraTayang: true),
      FilmModel(id: 'film_cs_4', judul: 'The Fantastic Four: First Steps', genre: 'Action, Superhero', durasi: 135, ratingUsia: '13+', posterUrl: 'https://images.unsplash.com/photo-1626278664285-f796b9ee7806?q=80&w=600&auto=format&fit=crop', isSegeraTayang: true),
      FilmModel(id: 'film_cs_5', judul: 'How to Train Your Dragon', genre: 'Animation, Fantasy', durasi: 120, ratingUsia: 'SU', posterUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?q=80&w=600&auto=format&fit=crop', isSegeraTayang: true),
    ]);
  }

  FilmModel? getFilmById(String id) {
    try {
      return _films.firstWhere((f) => f.id == id);
    } catch (_) {
      try {
        return _segeraTayang.firstWhere((f) => f.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> addFilm({
    required String judul,
    required String genre,
    required int durasi,
    required String ratingUsia,
    required String posterUrl,
    bool isSegeraTayang = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));

    final newFilm = FilmModel(
      id: const Uuid().v4(),
      judul: judul,
      genre: genre,
      durasi: durasi,
      ratingUsia: ratingUsia,
      posterUrl: posterUrl.isNotEmpty
          ? posterUrl
          : 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=600&auto=format&fit=crop',
      isSegeraTayang: isSegeraTayang,
    );

    if (isSegeraTayang) {
      _segeraTayang.add(newFilm);
    } else {
      _films.add(newFilm);
    }

    _isLoading = false;
    notifyListeners();
    _autoSave(); // AUTO SAVE LOCAL

    // Sync ke API Laravel
    ApiService.post('/films', {
      'judul': judul,
      'genre': genre,
      'durasi': durasi,
      'rating_usia': ratingUsia,
      'poster_url': posterUrl,
      'is_segera_tayang': isSegeraTayang,
    });
  }

  Future<void> updateFilm({
    required String id,
    required String judul,
    required String genre,
    required int durasi,
    required String ratingUsia,
    required String posterUrl,
    required bool isSegeraTayang,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));

    // Remove from both lists first
    _films.removeWhere((f) => f.id == id);
    _segeraTayang.removeWhere((f) => f.id == id);

    final updatedFilm = FilmModel(
      id: id,
      judul: judul,
      genre: genre,
      durasi: durasi,
      ratingUsia: ratingUsia,
      posterUrl: posterUrl,
      isSegeraTayang: isSegeraTayang,
    );

    if (isSegeraTayang) {
      _segeraTayang.add(updatedFilm);
    } else {
      _films.add(updatedFilm);
    }

    _isLoading = false;
    notifyListeners();
    _autoSave(); // AUTO SAVE LOCAL

    // Sync ke API Laravel
    ApiService.put('/films/$id', {
      'judul': judul,
      'genre': genre,
      'durasi': durasi,
      'rating_usia': ratingUsia,
      'poster_url': posterUrl,
      'is_segera_tayang': isSegeraTayang,
    });
  }

  Future<void> deleteFilm(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _films.removeWhere((f) => f.id == id);
    _segeraTayang.removeWhere((f) => f.id == id);
    _isLoading = false;
    notifyListeners();
    _autoSave(); // AUTO SAVE LOCAL

    // Sync ke API Laravel
    ApiService.delete('/films/$id');
  }
}
