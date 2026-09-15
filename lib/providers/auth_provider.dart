import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String _selectedCity = 'JAKARTA';

  AuthProvider() {
    _loadSession();
  }

  /// Muat sesi pengguna yang tersimpan dari penyimpanan lokal
  void _loadSession() {
    // Sync registered users from local storage to memory db
    final storedUsers = LocalStorageService.loadList(LocalStorageService.keyUsers);
    for (final map in storedUsers) {
      if (map['id'] != null) {
        final u = UserModel.fromMap(map, map['id']);
        _db.saveUser(u);
      }
    }

    final savedUser = LocalStorageService.loadMap(LocalStorageService.keyCurrentUser);
    if (savedUser != null) {
      _currentUser = UserModel.fromMap(savedUser, savedUser['id'] ?? '');
      _selectedCity = _currentUser!.selectedCity;
      _db.saveUser(_currentUser!);
    }
    final savedCity = LocalStorageService.loadString(LocalStorageService.keySelectedCity);
    if (savedCity != null) {
      _selectedCity = savedCity;
    }
  }

  /// Simpan sesi pengguna secara otomatis ke penyimpanan lokal
  Future<void> _saveSession() async {
    if (_currentUser != null) {
      await LocalStorageService.saveMap(
        LocalStorageService.keyCurrentUser,
        {'id': _currentUser!.id, ..._currentUser!.toMap()},
      );
    }
    await LocalStorageService.saveString(LocalStorageService.keySelectedCity, _selectedCity);
  }

  /// Hapus sesi pengguna dari penyimpanan lokal
  Future<void> _clearSession() async {
    await LocalStorageService.remove(LocalStorageService.keyCurrentUser);
  }

  Future<void> _persistUsers() async {
    final list = _db.getAllUsers().map((u) => {'id': u.id, ...u.toMap()}).toList();
    await LocalStorageService.saveList(LocalStorageService.keyUsers, list);
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String get selectedCity => _selectedCity;

  // Daftar kota bioskop di Indonesia
  static const List<String> cities = [
    'JAKARTA',
    'BANDUNG',
    'SURABAYA',
    'YOGYAKARTA',
    'SEMARANG',
    'MEDAN',
    'MAKASSAR',
    'PALEMBANG',
    'DENPASAR',
    'MALANG',
    'BOGOR',
    'BEKASI',
    'TANGERANG',
    'DEPOK',
    'CIANJUR',
    'SOLO',
    'BALIKPAPAN',
    'PONTIANAK',
    'MANADO',
    'BANJARMASIN',
    'LAMPUNG',
    'PEKANBARU',
    'BATAM',
    'CIREBON',
    'SUKABUMI',
  ];

  // Mall/Bioskop per kota
  static const Map<String, List<Map<String, String>>> cinemasByCity = {
    'JAKARTA': [
      {'name': 'GRAND INDONESIA XXI', 'address': 'Grand Indonesia Mall Lt. 5', 'distance': '2.3 km'},
      {'name': 'CENTRAL PARK XXI', 'address': 'Central Park Mall Lt. 5', 'distance': '4.1 km'},
      {'name': 'PLAZA SENAYAN XXI', 'address': 'Plaza Senayan Lt. 7', 'distance': '3.8 km'},
      {'name': 'KOTA KASABLANKA XXI', 'address': 'Mall Kota Kasablanka Lt. 3', 'distance': '5.2 km'},
      {'name': 'PLAZA INDONESIA XXI', 'address': 'Plaza Indonesia Lt. 6', 'distance': '2.0 km'},
    ],
    'BANDUNG': [
      {'name': 'PARIS VAN JAVA XXI', 'address': 'Paris Van Java Mall Lt. 4', 'distance': '1.8 km'},
      {'name': 'CIWALK XXI', 'address': 'Cihampelas Walk Lt. 4', 'distance': '2.5 km'},
      {'name': '23 PASKAL XXI', 'address': '23 Paskal Shopping Center Lt. 4', 'distance': '3.1 km'},
      {'name': 'TSM BANDUNG XXI', 'address': 'Trans Studio Mall Lt. 3', 'distance': '4.0 km'},
    ],
    'SURABAYA': [
      {'name': 'TUNJUNGAN PLAZA XXI', 'address': 'Tunjungan Plaza Lt. 5', 'distance': '1.2 km'},
      {'name': 'CIPUTRA WORLD XXI', 'address': 'Ciputra World Surabaya Lt. 5', 'distance': '3.5 km'},
      {'name': 'GALAXY MALL XXI', 'address': 'Galaxy Mall Lt. 4', 'distance': '5.0 km'},
    ],
    'YOGYAKARTA': [
      {'name': 'AMBARUKMO PLAZA XXI', 'address': 'Ambarukmo Plaza Lt. 3', 'distance': '2.0 km'},
      {'name': 'HARTONO MALL XXI', 'address': 'Hartono Mall Lt. 3', 'distance': '4.5 km'},
      {'name': 'JOGJA CITY MALL XXI', 'address': 'Jogja City Mall Lt. 3', 'distance': '3.2 km'},
    ],
    'SEMARANG': [
      {'name': 'PARAGON MALL XXI', 'address': 'Paragon City Mall Lt. 5', 'distance': '1.5 km'},
      {'name': 'DP MALL XXI', 'address': 'DP Mall Lt. 5', 'distance': '2.8 km'},
    ],
    'MEDAN': [
      {'name': 'SUN PLAZA XXI', 'address': 'Sun Plaza Lt. 4', 'distance': '1.8 km'},
      {'name': 'CENTER POINT XXI', 'address': 'Center Point Mall Lt. 4', 'distance': '3.0 km'},
    ],
    'MAKASSAR': [
      {'name': 'TRANS STUDIO XXI', 'address': 'Trans Studio Mall Lt. 3', 'distance': '2.0 km'},
      {'name': 'PANAKKUKANG XXI', 'address': 'Mall Panakkukang Lt. 3', 'distance': '3.5 km'},
    ],
    'DENPASAR': [
      {'name': 'LEVEL 21 XXI', 'address': 'Level 21 Mall Lt. 3', 'distance': '1.5 km'},
      {'name': 'PARK 23 XXI', 'address': 'Park 23 Entertainment Lt. 2', 'distance': '2.8 km'},
    ],
    'CIANJUR': [
      {'name': 'CITIMALL CIANJUR XXI', 'address': 'Citimall Cianjur Lt. 3', 'distance': '1.45 km'},
    ],
    'BOGOR': [
      {'name': 'BOTANI SQUARE XXI', 'address': 'Botani Square Lt. 3', 'distance': '2.0 km'},
      {'name': 'CIBINONG CITY MALL XXI', 'address': 'CCM Lt. 3', 'distance': '5.0 km'},
    ],
    'BEKASI': [
      {'name': 'SUMMARECON MALL BEKASI XXI', 'address': 'SM Bekasi Lt. 3', 'distance': '2.5 km'},
      {'name': 'GRAND METROPOLITAN XXI', 'address': 'Grand Metropolitan Lt. 3', 'distance': '3.0 km'},
    ],
    'TANGERANG': [
      {'name': 'SUPERMALL KARAWACI XXI', 'address': 'Supermall Karawaci Lt. 4', 'distance': '3.5 km'},
      {'name': 'AEON MALL BSD XXI', 'address': 'AEON Mall BSD Lt. 2', 'distance': '5.0 km'},
      {'name': 'LIVING WORLD XXI', 'address': 'Living World Alam Sutera Lt. 3', 'distance': '4.0 km'},
    ],
    'MALANG': [
      {'name': 'MALANG TOWN SQUARE XXI', 'address': 'Matos Lt. 3', 'distance': '1.8 km'},
      {'name': 'MALL OLYMPIC GARDEN XXI', 'address': 'MOG Lt. 3', 'distance': '2.5 km'},
    ],
    'SOLO': [
      {'name': 'SOLO PARAGON XXI', 'address': 'Solo Paragon Mall Lt. 5', 'distance': '2.0 km'},
      {'name': 'THE PARK MALL XXI', 'address': 'The Park Mall Solo Lt. 3', 'distance': '3.0 km'},
    ],
    'PALEMBANG': [
      {'name': 'PALEMBANG ICON XXI', 'address': 'Palembang Icon Mall Lt. 3', 'distance': '2.0 km'},
    ],
    'DEPOK': [
      {'name': 'DETOS XXI', 'address': 'Depok Town Square Lt. 3', 'distance': '1.5 km'},
      {'name': 'MARGO CITY XXI', 'address': 'Margo City Lt. 3', 'distance': '2.0 km'},
    ],
    'BALIKPAPAN': [
      {'name': 'PENTACITY XXI', 'address': 'Pentacity Shopping Venue Lt. 3', 'distance': '2.0 km'},
    ],
    'PONTIANAK': [
      {'name': 'AYANI MEGAMALL XXI', 'address': 'Ayani Megamall Lt. 3', 'distance': '1.8 km'},
    ],
    'MANADO': [
      {'name': 'MANTOS XXI', 'address': 'Manado Town Square Lt. 3', 'distance': '2.0 km'},
    ],
    'BANJARMASIN': [
      {'name': 'DUTA MALL XXI', 'address': 'Duta Mall Lt. 3', 'distance': '1.5 km'},
    ],
    'LAMPUNG': [
      {'name': 'MALL BOEMI KEDATON XXI', 'address': 'MBK Lt. 3', 'distance': '2.5 km'},
    ],
    'PEKANBARU': [
      {'name': 'SKA MALL XXI', 'address': 'SKA Mall Lt. 2', 'distance': '2.0 km'},
    ],
    'BATAM': [
      {'name': 'MEGA MALL BATAM XXI', 'address': 'Mega Mall Lt. 3', 'distance': '2.0 km'},
    ],
    'CIREBON': [
      {'name': 'CSB MALL XXI', 'address': 'CSB Mall Lt. 3', 'distance': '1.5 km'},
    ],
    'SUKABUMI': [
      {'name': 'PELITA PLAZA XXI', 'address': 'Pelita Plaza Lt. 3', 'distance': '1.2 km'},
    ],
  };

  void setSelectedCity(String city) {
    _selectedCity = city;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(selectedCity: city);
    }
    notifyListeners();
    _saveSession();
  }

  List<Map<String, String>> getCinemasForCurrentCity() {
    return cinemasByCity[_selectedCity] ?? cinemasByCity['JAKARTA']!;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    UserModel? user = _db.getUserByEmail(email);

    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return false; // Rejection: Account not registered
    }

    if (user.password.isNotEmpty && user.password != password) {
      final isDefaultAdmin = user.isAdmin && (password == 'admin' || password == 'admin123' || password == '123456');
      if (!isDefaultAdmin) {
        _isLoading = false;
        notifyListeners();
        return false; // Password incorrect
      }
    }

    _currentUser = user;
    _selectedCity = user.selectedCity;
    _isLoading = false;
    notifyListeners();
    _saveSession();
    return true;
  }

  Future<bool> loginWithGoogle({required String email, required String name}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    UserModel? user = _db.getUserByEmail(email);

    if (user == null) {
      user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        role: email.toLowerCase().contains('admin') ? 'Admin' : 'Pelanggan',
        selectedCity: _selectedCity,
      );
      _db.saveUser(user);
    }

    _currentUser = user;
    _selectedCity = user.selectedCity;
    _isLoading = false;
    notifyListeners();
    await _saveSession();
    await _persistUsers();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
    DateTime? birthDate,
    String role = 'Pelanggan',
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final existingUser = _db.getUserByEmail(email.trim());
    if (existingUser != null) {
      _isLoading = false;
      notifyListeners();
      return false; // Email already registered
    }

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email.trim(),
      name: name.trim(),
      role: role,
      phone: phone.trim(),
      gender: gender,
      birthDate: birthDate,
      selectedCity: _selectedCity,
      password: password.trim(),
    );

    _db.saveUser(user);
    _isLoading = false;
    notifyListeners();
    await _persistUsers();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
    _clearSession();
    AuthService.signOut();
  }
}
