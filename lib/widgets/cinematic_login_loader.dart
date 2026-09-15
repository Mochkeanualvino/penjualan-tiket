import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import 'kenticket_logo.dart';

/// Screen animasi loading sinematik berdurasi 7 detik saat login
class CinematicLoginLoader extends StatefulWidget {
  final String userName;
  final VoidCallback onCompleted;

  const CinematicLoginLoader({
    super.key,
    required this.userName,
    required this.onCompleted,
  });

  @override
  State<CinematicLoginLoader> createState() => _CinematicLoginLoaderState();
}

class _CinematicLoginLoaderState extends State<CinematicLoginLoader>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  String _statusText = 'Menghubungkan ke server KENTICKET...';
  String _statusSubtitle = 'Memuat data film dan jadwal bioskop';
  int _secondsLeft = 7;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    // 7-second main controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    // Continuous rotation for film reels
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Pulsing glow for ticket
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 10.0, end: 28.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Dynamic status text update along the 7 seconds
    _mainController.addListener(() {
      final value = _mainController.value;
      if (!mounted) return;
      setState(() {
        if (value < 0.28) {
          _statusText = '🎬 Menghubungkan ke server KENTICKET...';
          _statusSubtitle = 'Sinkronisasi koneksi aman dengan server bioskop';
        } else if (value < 0.55) {
          _statusText = '🎫 Memverifikasi Kredensial & Tiket...';
          _statusSubtitle = 'Memeriksa hak akses dan preferensi pengguna';
        } else if (value < 0.80) {
          _statusText = '🍿 Menyiapkan Jadwal & Promo Spesial...';
          _statusSubtitle = 'Memuat film box office, studio, dan snack m.food';
        } else {
          _statusText = '✨ Selamat Datang di KENTICKET!';
          _statusSubtitle = 'Halo ${widget.userName}, selamat menikmati film!';
        }
      });
    });

    // Countdown timer 7s
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        if (mounted) setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });

    _mainController.forward().then((_) {
      if (mounted) {
        widget.onCompleted();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0D),
      body: Stack(
        children: [
          // Background ambient cinema lighting
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB71C1C).withAlpha(40),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFB71C1C), blurRadius: 150, spreadRadius: 30),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withAlpha(40),
                boxShadow: const [
                  BoxShadow(color: AppTheme.primaryGold, blurRadius: 150, spreadRadius: 30),
                ],
              ),
            ),
          ),

          // Central Cinematic Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rotating Film Reel Projector
                  RotationTransition(
                    turns: _rotateController,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryGold, width: 3),
                        gradient: const SweepGradient(
                          colors: [
                            AppTheme.primaryGold,
                            Color(0xFFB71C1C),
                            AppTheme.primaryGold,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGold.withAlpha(80),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_roll_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Animated Glowing KENTICKET Logo
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryGold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGold.withAlpha(90),
                            blurRadius: _glowAnimation.value,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const KenticketLogo(size: 46, showText: true),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Status Text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      _statusText,
                      key: ValueKey(_statusText),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 7-second Progress Bar
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 10,
                              width: 280,
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryGold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: AppTheme.primaryGold),
                              const SizedBox(width: 6),
                              Text(
                                '${(_progressAnimation.value * 100).toInt()}% • Membuka dalam $_secondsLeft dtk',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
