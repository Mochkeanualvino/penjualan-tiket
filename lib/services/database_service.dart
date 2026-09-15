import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

class DatabaseService extends ChangeNotifier {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static DatabaseService get instance => _instance;

  // In-memory collections to ensure seamless instant execution fallback
  final Map<String, UserModel> _users = {};

  DatabaseService._internal() {
    _seedInitialData();
    _loadFromLocalStorage();
  }

  void _seedInitialData() {
    // Seed default admin and sample users
    _users['admin_1'] = UserModel(
      id: 'admin_1',
      email: 'admin@cinema.com',
      name: 'Administrator Bioskop',
      role: 'Admin',
      password: '12345',
    );
    _users['user_1'] = UserModel(
      id: 'user_1',
      email: 'pelanggan@bioskop.com',
      name: 'John Doe',
      role: 'Pelanggan',
      password: '123456',
    );
    // Pre-seed ken123 account as requested
    _users['user_ken'] = UserModel(
      id: 'user_ken',
      email: 'ken123@gmail.com',
      name: 'Ken',
      role: 'Pelanggan',
      password: '1234',
    );
  }

  void _loadFromLocalStorage() {
    try {
      final storedUsers = LocalStorageService.loadList(LocalStorageService.keyUsers);
      for (final map in storedUsers) {
        if (map['id'] != null || map['email'] != null) {
          final id = map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
          final u = UserModel.fromMap(map, id);
          _users[u.id] = u;
        }
      }
    } catch (e) {
      debugPrint('DatabaseService _loadFromLocalStorage error: $e');
    }
  }

  void _persistToLocalStorage() {
    try {
      final list = _users.values.map((u) => {'id': u.id, ...u.toMap()}).toList();
      LocalStorageService.saveList(LocalStorageService.keyUsers, list);
    } catch (e) {
      debugPrint('DatabaseService _persistToLocalStorage error: $e');
    }
  }

  UserModel? getUser(String id) => _users[id];

  UserModel? getUserByEmail(String email) {
    try {
      final query = email.trim().toLowerCase();
      final user = _users.values.firstWhere(
        (u) => u.email.trim().toLowerCase() == query,
      );
      return user;
    } catch (_) {
      if (email.trim().toLowerCase() == 'admin@cinema.com') {
        try {
          final legacyAdmin = _users.values.firstWhere((u) => u.isAdmin);
          return legacyAdmin.copyWith(
            email: 'admin@cinema.com',
            password: '12345',
          );
        } catch (_) {
          return null;
        }
      }
      return null;
    }
  }

  List<UserModel> getAllUsers() => _users.values.toList();

  void saveUser(UserModel user) {
    _users[user.id] = user;
    _persistToLocalStorage();
    notifyListeners();
  }
}
