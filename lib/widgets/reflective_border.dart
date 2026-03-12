import 'package:flutter/material.dart';

class ReflectiveBorder extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final bool glow;
  /// Optional border color. When null, uses the default gold gradient.
  final Color? color;
  final Decoration? decoration;

  const ReflectiveBorder({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.borderWidth = 2,
    this.glow = true,
    this.color,
    this.decoration
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          foregroundPainter: _ReflectiveBorderPainter(
            borderRadius: borderRadius,
            borderWidth: borderWidth,
            glow: glow,
            color: color,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ReflectiveBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final bool glow;
  final Color? color;

  _ReflectiveBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.glow,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(borderRadius),
    );

    final gradient = color != null
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(color!, Colors.white, 0.4)!,
              color!,
              Color.lerp(color!, Colors.black, 0.4)!,
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF4C2), // bright highlight
              Color(0xFFC5A028), // mid gold
              Color(0xFF8C6A12), // darker bottom
            ],
          );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Optional glow
    if (glow) {
      final glowColor = color ?? const Color(0xFFD4AF37);
      final glowPaint = Paint()
        ..color = glowColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      canvas.drawRRect(rrect, glowPaint);
    }

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _ReflectiveBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
