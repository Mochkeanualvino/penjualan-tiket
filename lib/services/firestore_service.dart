import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/film_model.dart';

/// Service untuk sinkronisasi data film ke Cloud Firestore.
/// Firestore digunakan sebagai database terpusat sehingga data
/// yang ditambahkan di Laptop/Admin otomatis tampil di HP/Pelanggan
/// dan sebaliknya (real-time sync).
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== COLLECTION REFERENCES =====
  static CollectionReference<Map<String, dynamic>> get _filmsCollection =>
      _db.collection('films');

  // ===== FILM CRUD =====

  /// Tambah film baru ke Firestore
  static Future<void> addFilm(FilmModel film) async {
    try {
      await _filmsCollection.doc(film.id).set({
        ...film.toMap(),
        'id': film.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('FirestoreService: Film "${film.judul}" berhasil disimpan ke Firestore');
    } catch (e) {
      debugPrint('FirestoreService addFilm error: $e');
      rethrow;
    }
  }

  /// Update film di Firestore
  static Future<void> updateFilm(FilmModel film) async {
    try {
      await _filmsCollection.doc(film.id).update({
        ...film.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('FirestoreService: Film "${film.judul}" berhasil diupdate di Firestore');
    } catch (e) {
      debugPrint('FirestoreService updateFilm error: $e');
      rethrow;
    }
  }

  /// Hapus film dari Firestore
  static Future<void> deleteFilm(String filmId) async {
    try {
      await _filmsCollection.doc(filmId).delete();
      debugPrint('FirestoreService: Film $filmId berhasil dihapus dari Firestore');
    } catch (e) {
      debugPrint('FirestoreService deleteFilm error: $e');
      rethrow;
    }
  }

  /// Ambil semua film sekali (one-time fetch)
  static Future<List<FilmModel>> getAllFilms() async {
    try {
      final snapshot = await _filmsCollection.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FilmModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('FirestoreService getAllFilms error: $e');
      return [];
    }
  }

  /// Stream real-time untuk semua film (auto-update saat ada perubahan)
  static Stream<List<FilmModel>> streamFilms() {
    return _filmsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FilmModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// Stream film yang sedang tayang saja
  static Stream<List<FilmModel>> streamSedangTayang() {
    return _filmsCollection
        .where('isSegeraTayang', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FilmModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// Stream film yang segera tayang saja
  static Stream<List<FilmModel>> streamSegeraTayang() {
    return _filmsCollection
        .where('isSegeraTayang', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FilmModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// Cek apakah Firestore bisa diakses (koneksi aktif)
  static Future<bool> isAvailable() async {
    try {
      await _filmsCollection.limit(1).get().timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Firestore tidak tersedia (offline mode): $e');
      return false;
    }
  }
}
