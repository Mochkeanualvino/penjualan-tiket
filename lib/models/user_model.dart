class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'Admin' or 'Pelanggan'
  final String phone;
  final String gender; // 'Pria' or 'Wanita'
  final DateTime? birthDate;
  final String selectedCity;
  final String password;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone = '',
    this.gender = 'Pria',
    this.birthDate,
    this.selectedCity = 'JAKARTA',
    this.password = '',
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      email: map['email'] ?? '',
      name: map['name'] ?? 'Pengguna',
      role: map['role'] ?? 'Pelanggan',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? 'Pria',
      birthDate: map['birthDate'] != null
          ? (map['birthDate'] is DateTime
              ? map['birthDate']
              : DateTime.tryParse(map['birthDate'].toString()))
          : null,
      selectedCity: map['selectedCity'] ?? 'JAKARTA',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'gender': gender,
      'birthDate': birthDate?.toIso8601String(),
      'selectedCity': selectedCity,
      'password': password,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? gender,
    DateTime? birthDate,
    String? selectedCity,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      selectedCity: selectedCity ?? this.selectedCity,
      password: password ?? this.password,
    );
  }
}
