import 'package:flutter/material.dart';

class PiktoriMagneti extends CustomPainter {
  final double progresi;
  final double magnetX;
  final double niveliDrites;
  final double afersia;
  final double coilTurns;
  final double currentIntensity;
  final double currentDirection;

  PiktoriMagneti({
    required this.progresi,
    required this.magnetX,
    required this.niveliDrites,
    required this.afersia,
    required this.coilTurns,
    required this.currentIntensity,
    required this.currentDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.52);
    final magnetCenter = center + Offset(magnetX, 0);
    final coilCenter = center + const Offset(90, 0);
    final bulbCenter = center + const Offset(140, -88);

    final wirePaths = _vizatoQarkun(canvas, coilCenter, bulbCenter);
    _vizatoSpiralen(canvas, coilCenter);
    _vizatoRrymen(canvas, wirePaths, currentIntensity, currentDirection);
    _vizatoLlamben(canvas, bulbCenter);
    _vizatoMagnetin(canvas, magnetCenter);
  }

  List<Path> _vizatoQarkun(Canvas c, Offset coil, Offset bulb) {
    final wirePaint = Paint()
      ..color = const Color(0xFF3B4351)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final upperWire = Path()
      ..moveTo(coil.dx + 52, coil.dy)
      ..lineTo(bulb.dx - 28, coil.dy)
      ..lineTo(bulb.dx - 28, bulb.dy)
      ..lineTo(bulb.dx - 2, bulb.dy);

    final lowerWire = Path()
      ..moveTo(coil.dx - 54, coil.dy)
      ..lineTo(coil.dx - 104, coil.dy)
      ..lineTo(coil.dx - 104, bulb.dy + 20)
      ..lineTo(bulb.dx - 2, bulb.dy + 20)
      ..lineTo(bulb.dx - 2, bulb.dy + 8);

    c.drawPath(upperWire, wirePaint);
    c.drawPath(lowerWire, wirePaint);

    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    c.drawPath(upperWire, highlight);
    c.drawPath(lowerWire, highlight);

    return [upperWire, lowerWire];
  }

  void _vizatoSpiralen(Canvas c, Offset center) {
    final turns = (7 + ((coilTurns - 5) / 45) * 13).round().clamp(7, 20);
    const width = 12.0;
    const height = 64.0;
    const spacing = 7.0;

    final framePaint = Paint()
      ..color = const Color(0xFF394150)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    c.drawLine(
      center.translate(-56, 0),
      center.translate(56, 0),
      framePaint..color = const Color(0xFF5D6575),
    );

    for (int i = 0; i < turns; i++) {
      final t = i / (turns - 1);
      final dx = -48 + i * spacing;
      final color = Color.lerp(const Color(0xFF7E57C2), const Color(0xFF4A3F9E), t)!;
      c.drawOval(
        Rect.fromCenter(center: center.translate(dx, 0), width: width, height: height),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.25,
      );
    }
  }

  void _vizatoLlamben(Canvas c, Offset center) {
    final glow = niveliDrites.clamp(0.0, 1.0);

    if (glow > 0.01) {
      c.drawCircle(
        center,
        34,
        Paint()
          ..color = const Color(0xFFFFCC4D).withOpacity(0.17 + glow * 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, 17), width: 16, height: 12),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF8A8F9A),
    );

    c.drawCircle(
      center,
      17,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(const Color(0xFFFFF8E1), const Color(0xFFFFF176), glow)!,
            Color.lerp(const Color(0xFFE0E0E0), const Color(0xFFFFD54F), glow)!,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 17)),
    );

    c.drawCircle(
      center,
      17,
      Paint()
        ..color = const Color(0xFF2D2D2D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _vizatoMagnetin(Canvas c, Offset k) {
    const w = 128.0;
    const h = 38.0;
    final rect = Rect.fromCenter(center: k, width: w, height: h);

    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(11)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE05A5A), Color(0xFFDB4B4B), Color(0xFF64B5F6), Color(0xFF4E9FE6)],
          stops: [0, 0.48, 0.52, 1],
        ).createShader(rect),
    );

    c.drawLine(
      k.translate(0, -h / 2 + 1),
      k.translate(0, h / 2 - 1),
      Paint()
        ..color = Colors.white.withOpacity(0.45)
        ..strokeWidth = 1.2,
    );

    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(11)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFF1D2330),
    );

    _drawText(c, 'N', k.translate(-38, -8));
    _drawText(c, 'S', k.translate(28, -8));
  }

  void _vizatoRrymen(
    Canvas canvas,
    List<Path> wires,
    double intensity,
    double direction,
  ) {
    if (intensity < 0.02 || direction == 0) return;

    final glowPaint = Paint()
      ..color = const Color(0xFF29B6F6).withOpacity(0.18 + intensity * 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final linePaint = Paint()
      ..color = const Color(0xFF26C6DA).withOpacity(0.40 + intensity * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final path in wires) {
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, linePaint);
      _vizatoPulse(canvas, path, intensity, direction);
    }
  }

  void _vizatoPulse(Canvas canvas, Path path, double intensity, double direction) {
    final metrics = path.computeMetrics();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final count = 3;

    for (int i = 0; i < count; i++) {
      var phase = (progresi + i / count) % 1.0;
      if (direction < 0) {
        phase = 1.0 - phase;
      }

      final tangent = metric.getTangentForOffset(metric.length * phase);
      if (tangent == null) continue;

      final radius = 1.8 + intensity * 2.6;
      canvas.drawCircle(
        tangent.position,
        radius,
        Paint()..color = const Color(0xFFB3E5FC).withOpacity(0.55 + intensity * 0.4),
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2430),
          fontSize: 13,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant PiktoriMagneti oldDelegate) {
    return progresi != oldDelegate.progresi ||
        magnetX != oldDelegate.magnetX ||
        niveliDrites != oldDelegate.niveliDrites ||
        afersia != oldDelegate.afersia ||
        coilTurns != oldDelegate.coilTurns ||
        currentIntensity != oldDelegate.currentIntensity ||
        currentDirection != oldDelegate.currentDirection;
  }
}
