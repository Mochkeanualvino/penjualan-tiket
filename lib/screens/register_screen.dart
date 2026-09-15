import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _gender = 'Pria';
  DateTime _birthDate = DateTime(2000, 1, 1);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryGold,
              onPrimary: Colors.black,
              surface: AppTheme.cardBg,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _gender,
        birthDate: _birthDate,
      );

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Registrasi berhasil! Silakan masuk dengan email dan kata sandi baru Anda.'),
            backgroundColor: AppTheme.accentGreen,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context); // Langsung kembali ke halaman login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buat Akun KENTICKET',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryGold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F12), Color(0xFF1E1E24), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Panjang
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama panjang',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Nama wajib diisi';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Nomor Telepon
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Nomor telepon',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Nomor telepon wajib diisi';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Email wajib diisi';
                          if (!val.contains('@')) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Password wajib diisi';
                          if (val.length < 4) return 'Password minimal 4 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Jenis Kelamin
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBgLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jenis kelamin',
                              style: TextStyle(color: AppTheme.primaryGold, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildGenderOption('Pria'),
                                const SizedBox(width: 24),
                                _buildGenderOption('Wanita'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tanggal Lahir
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBgLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tanggal lahir',
                                    style: TextStyle(color: AppTheme.primaryGold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    Formatters.formatDate(_birthDate),
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                ],
                              ),
                              const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryGold),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                border: Border(top: BorderSide(color: AppTheme.primaryGold.withAlpha(40))),
              ),
              child: SafeArea(
                child: authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                    : SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleRegister,
                          child: const Text('LANJUT'),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String value) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () => setState(() => _gender = value),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.primaryGold : AppTheme.textMuted,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textMuted,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
