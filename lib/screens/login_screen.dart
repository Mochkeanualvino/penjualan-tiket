import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      bool success = await authProvider.login(email, password);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat Datang, ${authProvider.currentUser?.name}!'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    }
  }

  void _fillQuickCredentials(String email) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = '123456';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F12), Color(0xFF1E1E24), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: AppTheme.cardBg.withAlpha(230),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryGold.withAlpha(77), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withAlpha(25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryGold.withAlpha(38),
                        border: Border.all(color: AppTheme.primaryGold, width: 2),
                      ),
                      child: const Icon(
                        Icons.movie_filter_rounded,
                        size: 48,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CINESTAR XXI',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'Sistem Penjualan Tiket Bioskop',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email Field
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

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Password wajib diisi';
                        if (val.length < 4) return 'Password minimal 4 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Quick Login Demo
                    Text(
                      'Demo Quick Login:',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _fillQuickCredentials('admin@bioskop.com'),
                            icon: const Icon(Icons.admin_panel_settings, size: 16),
                            label: const Text('Admin', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _fillQuickCredentials('pelanggan@bioskop.com'),
                            icon: const Icon(Icons.person, size: 16),
                            label: const Text('Pelanggan', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Login Button
                    authProvider.isLoading
                        ? const CircularProgressIndicator(color: AppTheme.primaryGold)
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              child: const Text('MASUK SEKARANG'),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.textMuted.withAlpha(60))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('atau', style: TextStyle(color: AppTheme.textMuted.withAlpha(120), fontSize: 13)),
                        ),
                        Expanded(child: Divider(color: AppTheme.textMuted.withAlpha(60))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'BUAT AKUN BARU',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
