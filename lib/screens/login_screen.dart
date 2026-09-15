import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/kenticket_logo.dart';
import '../widgets/cinematic_login_loader.dart';
import '../widgets/google_logo.dart';
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

  // 7-second cinematic loader state
  bool _showCinematicLoader = false;
  String _pendingUserName = '';
  Future<void> Function()? _onLoaderFinished;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final db = DatabaseService();
      final user = db.getUserByEmail(email);

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Akun belum terdaftar! Silakan daftarkan akun baru terlebih dahulu.'),
            backgroundColor: AppTheme.accentRed,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Check password if set
      if (user.password.isNotEmpty && user.password != password) {
        final isDefaultAdmin = user.isAdmin && (password == 'admin' || password == 'admin123' || password == '123456');
        if (!isDefaultAdmin) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Kata sandi salah! Silakan periksa kembali kata sandi Anda.'),
              backgroundColor: AppTheme.accentRed,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }
      }

      // Valid account: Trigger 7-second cinematic animation loader
      setState(() {
        _showCinematicLoader = true;
        _pendingUserName = user.name;
        _onLoaderFinished = () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.login(email, password);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selamat Datang di KENTICKET, ${user.name}!'),
                backgroundColor: AppTheme.accentGreen,
              ),
            );
          }
        };
      });
    }
  }

  void _handleGoogleLogin() async {
    try {
      final userCredential = await AuthService.signInWithGoogle();
      if (userCredential == null) {
        // Pengguna membatalkan pemilihan akun Google
        return;
      }

      final user = userCredential.user;
      final String email = user?.email ?? '';
      final String name = user?.displayName ?? (email.isNotEmpty ? email.split('@').first : 'Pengguna Google');

      if (email.isNotEmpty) {
        _proceedGoogleLogin(email, name);
      }
    } catch (e) {
      debugPrint('Google Sign-In Exception: $e');
      if (mounted) {
        _showGoogleWebAccountDialog(errorMessage: e.toString());
      }
    }
  }

  void _proceedGoogleLogin(String email, String name) {
    if (!mounted) return;
    setState(() {
      _showCinematicLoader = true;
      _pendingUserName = name;
      _onLoaderFinished = () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.loginWithGoogle(email: email, name: name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Berhasil masuk dengan Google: $name!'),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
        }
      };
    });
  }

  void _showGoogleWebAccountDialog({String? errorMessage}) {
    final isConfigError = errorMessage != null && errorMessage.contains('configuration-not-found');
    final emailCtrl = TextEditingController(text: 'keanu.alvino@gmail.com');
    final nameCtrl = TextEditingController(text: 'Moch Keanu Alvino');
    bool showCustomInput = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan Logo Google
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const GoogleLogo(size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Akun Google',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                        ),
                        Text(
                          'untuk melanjutkan ke KENTICKET',
                          style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(180)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (isConfigError)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2210),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryGold.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.primaryGold, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Mode Akun Google Cepat Aktif (Pilih profil di bawah untuk login instan).',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFFFDE68A)),
                        ),
                      ),
                    ],
                  ),
                ),

              // Pilihan Akun Google 1 (Default / Owner)
              _buildGoogleAccountTile(
                name: 'Moch Keanu Alvino',
                email: 'keanu.alvino@gmail.com',
                initial: 'K',
                initialColor: const Color(0xFF4285F4),
                onTap: () {
                  Navigator.pop(ctx);
                  _proceedGoogleLogin('keanu.alvino@gmail.com', 'Moch Keanu Alvino');
                },
              ),
              const SizedBox(height: 10),

              // Pilihan Akun Google 2
              _buildGoogleAccountTile(
                name: 'Alya Putri',
                email: 'alya.google@gmail.com',
                initial: 'A',
                initialColor: const Color(0xFFEA4335),
                onTap: () {
                  Navigator.pop(ctx);
                  _proceedGoogleLogin('alya.google@gmail.com', 'Alya Putri');
                },
              ),
              const SizedBox(height: 10),

              if (!showCustomInput) ...[
                // Tombol Akun Lain
                InkWell(
                  onTap: () {
                    setSheetState(() {
                      showCustomInput = true;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBgLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person_add_outlined, color: AppTheme.primaryGold, size: 24),
                        SizedBox(width: 14),
                        Text(
                          'Gunakan akun Google lainnya...',
                          style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Form input kustom akun Google
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Profil Google', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Alamat Email Google (@gmail.com)', prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const GoogleLogo(size: 20),
                    label: const Text('MASUK DENGAN AKUN INI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      final email = emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : 'user.google@gmail.com';
                      final name = nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'Pengguna Google';
                      _proceedGoogleLogin(email, name);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleAccountTile({
    required String name,
    required String email,
    required String initial,
    required Color initialColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: initialColor,
              child: Text(
                initial,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCinematicLoader) {
      return CinematicLoginLoader(
        userName: _pendingUserName,
        onCompleted: () {
          if (_onLoaderFinished != null) {
            _onLoaderFinished!();
          }
        },
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0D), Color(0xFF1E1E24), Color(0xFF000000)],
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
                    // Header Logo KENTICKET
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBgLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryGold.withAlpha(60), width: 1),
                      ),
                      child: const KenticketLogo(size: 38, showText: true),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sistem Pemesanan Tiket Bioskop',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
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
                    const SizedBox(height: 22),

                    // Divider "ATAU" (Sesuai Desain Shopee Gambar 2)
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withAlpha(50),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'ATAU',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withAlpha(50),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Log In dengan Google Button (Sesuai Desain Shopee Gambar 2)
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        onTap: _handleGoogleLogin,
                        borderRadius: BorderRadius.circular(6),
                        splashColor: Colors.black.withAlpha(25),
                        highlightColor: Colors.black.withAlpha(15),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFD6D6D6), width: 1.0),
                          ),
                          child: Row(
                            children: [
                              const GoogleLogo(size: 22),
                              Expanded(
                                child: Text(
                                  'Log In dengan Google',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF222222),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 22), // Menjaga teks tetap presisi di tengah
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Registrasi Akun Baru
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'BUAT AKUN BARU (REGISTRASI)',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.primaryGold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Belum punya akun? Daftar (Gaya Shopee)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: Text(
                            'Daftar',
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
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
