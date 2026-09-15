import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../utils/theme.dart';
import '../widgets/kenticket_logo.dart';
import '../widgets/cinematic_login_loader.dart';
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
    if (kIsWeb) {
      _showGoogleWebAccountDialog();
      return;
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // Pengguna membatalkan pemilihan akun Google
        return;
      }

      final String email = googleUser.email;
      final String name = googleUser.displayName ?? email.split('@').first;
      _proceedGoogleLogin(email, name);
    } catch (e) {
      debugPrint('Google Sign-In Exception: $e');
      if (mounted) {
        _showGoogleWebAccountDialog();
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

  void _showGoogleWebAccountDialog() {
    final emailCtrl = TextEditingController(text: 'alya.google@gmail.com');
    final nameCtrl = TextEditingController(text: 'Alya (Google Account)');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.blueAccent, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Masuk dengan Google',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Gunakan akun Google Anda untuk melanjutkan ke KENTICKET:',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Profil Google', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Alamat Email Google (@gmail.com)', prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.login, color: Colors.black),
                label: const Text('MASUK DENGAN GOOGLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () {
                  Navigator.pop(ctx);
                  final email = emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : 'user.google@gmail.com';
                  final name = nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'Pengguna Google';
                  _proceedGoogleLogin(email, name);
                },
              ),
            ),
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
                    const SizedBox(height: 16),

                    // Google Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _handleGoogleLogin,
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.g_mobiledata, color: Colors.blue, size: 22),
                        ),
                        label: Text(
                          'Masuk dengan Google',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white38, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
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
                          'BUAT AKUN BARU (REGISTRASI)',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
