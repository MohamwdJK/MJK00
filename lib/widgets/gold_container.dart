import 'package:flutter/material.dart';
import '../config/theme.dart';

class GoldContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool glowing;

  const GoldContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LuxuryTheme.darkSurfaceGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowing ? LuxuryTheme.brightGold : LuxuryTheme.metallicGold.withOpacity(0.45),
          width: glowing ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: glowing
                ? LuxuryTheme.metallicGold.withOpacity(0.22)
                : Colors.black.withOpacity(0.6),
            blurRadius: glowing ? 20 : 12,
            spreadRadius: glowing ? 2 : 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
