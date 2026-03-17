import 'dart:math' as math;

import 'package:flutter/material.dart';

class PiktoriQarku extends CustomPainter {
  final double progresi;
  final bool qarkuMbyllur;
  final double ndricimi;
  final double rryma;

  PiktoriQarku({
    required this.progresi,
    required this.qarkuMbyllur,
    required this.ndricimi,
    required this.rryma,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tel = Paint()
      ..color = const Color(0xFF263238)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wirePath = _krijoShtegun(size, qarkuMbyllur);
    canvas.drawPath(wirePath, tel);

    _vizatoBaterine(canvas, size);
    _vizatoRezistorin(canvas, size);
    _vizatoNderpreresin(canvas, size, qarkuMbyllur);
    _vizatoLlamben(canvas, size, ndricimi);

    if (qarkuMbyllur) {
      final metric = wirePath.computeMetrics().first;
      final nrPikave = (10 + rryma * 2).clamp(10, 18).toInt();
      final pPaint = Paint()..color = Colors.lightBlueAccent;
      for (int i = 0; i < nrPikave; i++) {
        final d = ((progresi + i / nrPikave) % 1.0) * metric.length;
        final pos = metric.getTangentForOffset(d)?.position;
        if (pos != null) {
          canvas.drawCircle(pos, 3.6 + ndricimi, pPaint);
        }
      }
    }
  }

  Path _krijoShtegun(Size size, bool closed) {
    final left = size.width * 0.14;
    final right = size.width * 0.86;
    final top = size.height * 0.22;
    final bottom = size.height * 0.79;
    final switchY = size.height * 0.42;

    final p = Path()..moveTo(left, bottom);
    p.lineTo(left, switchY + 28);
    if (closed) {
      p.lineTo(left, top);
    } else {
      p.lineTo(left, switchY);
    }
    p.lineTo(size.width * 0.34, top);
    p.lineTo(size.width * 0.64, top);
    p.lineTo(right, top);
    p.lineTo(right, size.height * 0.42);
    p.arcToPoint(
      Offset(right, size.height * 0.58),
      radius: const Radius.circular(38),
      clockwise: false,
    );
    p.lineTo(right, bottom);
    p.lineTo(left, bottom);
    return p;
  }

  void _vizatoBaterine(Canvas c, Size size) {
    final x = size.width * 0.14;
    final p = Paint()..color = Colors.black87;
    c.drawLine(Offset(x - 12, size.height * 0.66), Offset(x - 12, size.height * 0.52), p..strokeWidth = 3);
    c.drawLine(Offset(x + 12, size.height * 0.66), Offset(x + 12, size.height * 0.46), p..strokeWidth = 4);
  }

  void _vizatoRezistorin(Canvas c, Size size) {
    final y = size.height * 0.22;
    final start = size.width * 0.34;
    final end = size.width * 0.64;
    final body = Rect.fromCenter(center: Offset((start + end) / 2, y), width: end - start, height: 20);
    c.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(6)),
      Paint()..color = const Color(0xFFD7CCC8),
    );
    final line = Paint()..color = Colors.brown.shade700..strokeWidth = 2;
    for (int i = 1; i <= 3; i++) {
      final x = body.left + (body.width / 4) * i;
      c.drawLine(Offset(x, body.top + 2), Offset(x, body.bottom - 2), line);
    }
    c.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(6)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.brown.shade900,
    );
  }

  void _vizatoNderpreresin(Canvas c, Size size, bool closed) {
    final x = size.width * 0.14;
    final y = size.height * 0.42;
    final paint = Paint()..color = Colors.black87..strokeWidth = 3;
    c.drawCircle(Offset(x, y), 4, paint);
    c.drawCircle(Offset(x + 30, y - 18), 4, paint);
    final angle = closed ? -0.54 : -0.18;
    c.drawLine(
      Offset(x, y),
      Offset(x + 30 * math.cos(angle), y + 30 * math.sin(angle)),
      paint,
    );
  }

  void _vizatoLlamben(Canvas c, Size size, double level) {
    final center = Offset(size.width * 0.86, size.height * 0.50);
    final r = size.width * 0.06;
    if (level > 0) {
      c.drawCircle(
        center,
        r + 18,
        Paint()
          ..color = Colors.amber.withOpacity(0.18 + level * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
    c.drawCircle(center, r, Paint()..color = Color.lerp(Colors.grey.shade300, Colors.amber.shade400, level)!);
    c.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black87,
    );
  }

  @override
  bool shouldRepaint(covariant PiktoriQarku oldDelegate) {
    return progresi != oldDelegate.progresi ||
        qarkuMbyllur != oldDelegate.qarkuMbyllur ||
        ndricimi != oldDelegate.ndricimi ||
        rryma != oldDelegate.rryma;
  }
}
