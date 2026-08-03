import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String _selectedCity = 'JAKARTA';

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
      String role = 'Pelanggan';
      if (email.toLowerCase().contains('admin')) {
        role = 'Admin';
      }
      user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: email.split('@').first,
        role: role,
        selectedCity: _selectedCity,
      );
      _db.saveUser(user);
    }

    _currentUser = user;
    _selectedCity = user.selectedCity;
    _isLoading = false;
    notifyListeners();
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

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: role,
      phone: phone,
      gender: gender,
      birthDate: birthDate,
      selectedCity: _selectedCity,
    );

    _db.saveUser(user);
    _currentUser = user;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
