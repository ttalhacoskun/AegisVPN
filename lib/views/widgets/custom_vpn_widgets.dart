import 'dart:math' as math;

import 'package:flutter/material.dart';

class LiveShieldBadge extends StatelessWidget {
  final String label;
  final String val;
  final IconData icon;
  final Color color;

  const LiveShieldBadge({
    super.key,
    required this.label,
    required this.val,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LiveMetricItem extends StatelessWidget {
  final String label;
  final String val;
  final IconData icon;
  final Color color;

  const LiveMetricItem({
    super.key,
    required this.label,
    required this.val,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class HarmonicSmoothWavePainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final Color waveColor;

  HarmonicSmoothWavePainter({
    required this.progress,
    required this.isActive,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = isActive ? 2.0 : 1.2
      ..style = PaintingStyle.stroke;

    final midY = size.height / 2;
    final path = Path();
    final amplitude = isActive ? 7.0 : 2.0;
    final frequency = isActive ? 2.5 : 1.2;

    for (double x = 0; x <= size.width; x += 2) {
      final rad = (x / size.width) * 2 * math.pi * frequency;
      final y = midY + math.sin(rad + (progress * 2 * math.pi)) * amplitude;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HarmonicSmoothWavePainter oldDelegate) => true;
}
