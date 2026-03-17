import 'dart:math' as math;

import 'package:flutter/material.dart';

class PiktoriMagneti extends CustomPainter {
  final double progresi;
  final double magnetX;
  final double niveliDrites;
  final double afersia;

  PiktoriMagneti({
    required this.progresi,
    required this.magnetX,
    required this.niveliDrites,
    required this.afersia,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final magnetCenter = center + Offset(magnetX, 0);
    final coilCenter = center + const Offset(90, 0);
    final bulbCenter = center + const Offset(145, -78);

    _vizatoFushen(canvas, magnetCenter);
    _vizatoSpiralen(canvas, coilCenter);
    _vizatoTelat(canvas, coilCenter, bulbCenter);
    _vizatoLlamben(canvas, bulbCenter);
    _vizatoMagnetin(canvas, magnetCenter);
  }

  void _vizatoFushen(Canvas c, Offset m) {
    if (niveliDrites <= 0.01) return;
    for (int i = 0; i < 4; i++) {
      final r = Rect.fromCenter(
        center: m,
        width: 150 + i * 35 + math.sin(progresi * math.pi * 2 + i) * 5,
        height: 75 + i * 22,
      );
      final op = (0.12 - i * 0.02) * niveliDrites;
      c.drawArc(
        r,
        math.pi * 0.15,
        math.pi * 0.7,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.indigo.withOpacity(op.clamp(0.02, 0.14)),
      );
      c.drawArc(
        r,
        math.pi * 1.15,
        math.pi * 0.7,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.indigo.withOpacity(op.clamp(0.02, 0.14)),
      );
    }
  }

  void _vizatoMagnetin(Canvas c, Offset k) {
    const w = 126.0;
    const h = 36.0;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: k.translate(-w / 4, 0), width: w / 2, height: h),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xFFE57373),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: k.translate(w / 4, 0), width: w / 2, height: h),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xFF64B5F6),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: k, width: w, height: h), const Radius.circular(9)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black87,
    );
    _drawText(c, 'N', k.translate(-37, -8));
    _drawText(c, 'S', k.translate(24, -8));
  }

  void _vizatoSpiralen(Canvas c, Offset center) {
    final p = Paint()
      ..color = const Color(0xFF7E57C2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (int i = 0; i < 8; i++) {
      c.drawOval(Rect.fromCenter(center: center.translate(i * 11 - 40, 0), width: 12, height: 54), p);
    }
    c.drawLine(
      center.translate(-46, 0),
      center.translate(46, 0),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 1,
    );
  }

  void _vizatoTelat(Canvas c, Offset coil, Offset bulb) {
    final p = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;
    final path1 = Path()
      ..moveTo(coil.dx + 44, coil.dy)
      ..lineTo(bulb.dx - 20, coil.dy)
      ..lineTo(bulb.dx - 20, bulb.dy)
      ..lineTo(bulb.dx, bulb.dy);
    final path2 = Path()
      ..moveTo(coil.dx - 54, coil.dy)
      ..lineTo(coil.dx - 92, coil.dy)
      ..lineTo(coil.dx - 92, bulb.dy + 14)
      ..lineTo(bulb.dx, bulb.dy + 14);
    c.drawPath(path1, p);
    c.drawPath(path2, p);
  }

  void _vizatoLlamben(Canvas c, Offset center) {
    if (niveliDrites > 0) {
      c.drawCircle(
        center,
        28,
        Paint()
          ..color = Colors.amber.withOpacity(0.18 + 0.22 * niveliDrites)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
    }
    c.drawCircle(center, 16, Paint()..color = Color.lerp(Colors.grey.shade300, Colors.amber, niveliDrites)!);
    c.drawCircle(
      center,
      16,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black87,
    );

    if (afersia > 0.75) {
      c.drawCircle(center, 22, Paint()..color = Colors.orange.withOpacity(0.07));
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
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
        afersia != oldDelegate.afersia;
  }
}
