import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget Logo Resmi Google dengan 4 warna (Merah, Kuning, Hijau, Biru).
/// Menggunakan gambar resmi dengan fallback CustomPainter vektor jika offline.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return CustomPaint(
            size: Size(size, size),
            painter: _GoogleGPainter(),
          );
        },
      ),
    );
  }
}

/// CustomPainter untuk menggambar logo 4-warna Google "G" secara offline
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final double strokeWidth = w * 0.22;
    final double radius = (w / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red arc: Top
    canvas.drawArc(rect, -math.pi * 0.75, math.pi * 0.5, false, redPaint);

    // Yellow arc: Left
    canvas.drawArc(rect, -math.pi * 1.25, math.pi * 0.5, false, yellowPaint);

    // Green arc: Bottom
    canvas.drawArc(rect, math.pi * 0.25, math.pi * 0.5, false, greenPaint);

    // Blue arc: Right
    canvas.drawArc(rect, -math.pi * 0.25, math.pi * 0.45, false, bluePaint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTWH(
      center.dx - (strokeWidth * 0.1),
      center.dy - (strokeWidth / 2),
      (w / 2) + (strokeWidth * 0.1),
      strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
