import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';

/// Widget Logo Resmi KENTICKET sesuai desain Cinema Ticket
class KenticketLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isCompact;

  const KenticketLogo({
    super.key,
    this.size = 36,
    this.showText = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ticket Vector Graphic
        _buildTicketIcon(size),
        if (showText) ...[
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'KEN',
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 18 : (size * 0.65),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFB71C1C), // Deep Crimson Red
                    letterSpacing: 1.5,
                  ),
                ),
                TextSpan(
                  text: 'TICKET',
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 18 : (size * 0.65),
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryGold, // Gold
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTicketIcon(double h) {
    final w = h * 1.5;
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: const Color(0xFF9E1B2A), // Burgundy Red
        borderRadius: BorderRadius.circular(h * 0.15),
        border: Border.all(color: AppTheme.primaryGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withAlpha(50),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left cinema stub
          Positioned(
            left: h * 0.1,
            child: Icon(
              Icons.theaters_rounded,
              size: h * 0.5,
              color: Colors.white.withAlpha(220),
            ),
          ),
          // Center Cinema Ticket text
          Positioned(
            right: h * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'CINEMA',
                  style: TextStyle(
                    fontSize: h * 0.18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightGold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'TICKET',
                  style: TextStyle(
                    fontSize: h * 0.22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Perforated line right divider
          Positioned(
            right: h * 0.12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 2,
                height: h * 0.7,
                color: AppTheme.primaryGold.withAlpha(180),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
