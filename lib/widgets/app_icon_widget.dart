import 'package:flutter/material.dart';
import '../config/theme.dart';

class LuxurySquircleIcon extends StatelessWidget {
  final double size;
  const LuxurySquircleIcon({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LuxuryTheme.pitchBlack,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(color: LuxuryTheme.metallicGold, width: size * 0.025),
        boxShadow: [
          BoxShadow(
            color: LuxuryTheme.brightGold.withOpacity(0.3),
            blurRadius: size * 0.25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _InstagramClockPainter(),
      ),
    );
  }
}

class _InstagramClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint goldPaint = Paint()
      ..shader = LuxuryTheme.goldGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Inner Instagram-style Squircle
    final RRect innerSquircle = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.68,
        height: size.height * 0.68,
      ),
      Radius.circular(size.width * 0.18),
    );
    canvas.drawRRect(innerSquircle, goldPaint);

    // Top-Right Status Dot
    final Paint dotPaint = Paint()
      ..shader = LuxuryTheme.goldGradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.69, size.height * 0.31),
      size.width * 0.038,
      dotPaint,
    );

    // Center Clock Circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.19,
      goldPaint,
    );

    // Checkmark / Clock Hand Fusion
    final Path checkPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.51)
      ..lineTo(size.width * 0.49, size.height * 0.58)
      ..lineTo(size.width * 0.63, size.height * 0.41);
    canvas.drawPath(checkPath, goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
