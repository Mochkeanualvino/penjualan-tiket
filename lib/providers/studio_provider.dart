import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/studio_model.dart';
import '../services/local_storage_service.dart';

class StudioProvider extends ChangeNotifier {
  final List<StudioModel> _studios = [];
  bool _isLoading = false;

  List<StudioModel> get studios => _studios;
  bool get isLoading => _isLoading;

  StudioProvider() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final saved = LocalStorageService.loadList(LocalStorageService.keyStudios);
    if (saved.isNotEmpty) {
      _studios.addAll(saved.map((m) => StudioModel.fromMap(m, m['id'] ?? '')));
    } else {
      _seedInitialStudios();
    }
  }

  Future<void> _autoSave() async {
    await LocalStorageService.saveList(
      LocalStorageService.keyStudios,
      _studios.map((s) => {'id': s.id, ...s.toMap()}).toList(),
    );
  }

  void _seedInitialStudios() {
    _studios.addAll([
      StudioModel(id: 'std_1', namaStudio: 'Studio XXI 1', kapasitas: 30),
      StudioModel(id: 'std_2', namaStudio: 'Studio XXI 2', kapasitas: 25),
      StudioModel(id: 'std_3', namaStudio: 'IMAX Cinema', kapasitas: 40),
      StudioModel(id: 'std_4', namaStudio: 'Premiere Suite', kapasitas: 15),
    ]);
  }

  StudioModel? getStudioById(String id) {
    try {
      return _studios.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addStudio({
    required String namaStudio,
    required int kapasitas,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final newStudio = StudioModel(
      id: const Uuid().v4(),
      namaStudio: namaStudio,
      kapasitas: kapasitas,
    );

    _studios.add(newStudio);
    _isLoading = false;
    notifyListeners();
    _autoSave();
  }

  Future<void> updateStudio({
    required String id,
    required String namaStudio,
    required int kapasitas,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _studios.indexWhere((s) => s.id == id);
    if (index != -1) {
      _studios[index] = StudioModel(id: id, namaStudio: namaStudio, kapasitas: kapasitas);
    }
    _isLoading = false;
    notifyListeners();
    _autoSave();
  }

  Future<void> deleteStudio(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _studios.removeWhere((s) => s.id == id);
    _isLoading = false;
    notifyListeners();
    _autoSave();
  }
}
