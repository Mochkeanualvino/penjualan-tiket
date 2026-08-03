import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class DatabaseService extends ChangeNotifier {
  // In-memory collections to ensure seamless instant execution fallback
  final Map<String, UserModel> _users = {};

  DatabaseService() {
    _seedInitialData();
  }

  void _seedInitialData() {
    // Seed default admin and sample users
    _users['admin_1'] = UserModel(
      id: 'admin_1',
      email: 'admin@bioskop.com',
      name: 'Administrator Bioskop',
      role: 'Admin',
    );
    _users['user_1'] = UserModel(
      id: 'user_1',
      email: 'pelanggan@bioskop.com',
      name: 'John Doe',
      role: 'Pelanggan',
    );
  }

  UserModel? getUser(String id) => _users[id];
  
  UserModel? getUserByEmail(String email) {
    try {
      return _users.values.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  void saveUser(UserModel user) {
    _users[user.id] = user;
    notifyListeners();
  }
}
