import 'dart:math' as math;

import 'package:flutter/material.dart';

class PiktoriGjeneratorit extends CustomPainter {
  final double progresi;
  final double rrjedhaUjit;
  final double bateria;

  PiktoriGjeneratorit({
    required this.progresi,
    required this.rrjedhaUjit,
    required this.bateria,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final turbine = Offset(size.width * 0.3, size.height * 0.60);
    final batteryRect = Rect.fromLTWH(size.width * 0.58, size.height * 0.38, 74, 130);
    final bulb = Offset(size.width * 0.84, size.height * 0.28);

    _vizatoTubinDheUjin(canvas, size);
    _vizatoTurbinen(canvas, turbine);
    _vizatoEnergjine(canvas, turbine, batteryRect, bulb);
    _vizatoBaterine(canvas, batteryRect);
    _vizatoLlamben(canvas, bulb);
  }

  void _vizatoTubinDheUjin(Canvas c, Size size) {
    final pipe = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.14, size.height * 0.12, 24, size.height * 0.46),
      const Radius.circular(10),
    );
    c.drawRRect(pipe, Paint()..color = const Color(0xFFB0BEC5));

    final stream = Paint()
      ..color = Colors.lightBlue.withOpacity(0.45 + rrjedhaUjit * 0.35)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      final x = size.width * 0.146 + i * 3.4;
      final wave = math.sin((progresi * 2 * math.pi) + i) * 4;
      c.drawLine(Offset(x, size.height * 0.14), Offset(x + wave, size.height * 0.55), stream);
    }
  }

  void _vizatoTurbinen(Canvas c, Offset center) {
    final r = 40.0;
    final speed = 0.3 + rrjedhaUjit * 2.0;
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(progresi * 2 * math.pi * speed);
    final p = Paint()..color = const Color(0xFF546E7A)..strokeWidth = 3..style = PaintingStyle.stroke;
    c.drawCircle(Offset.zero, r, p);
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      c.drawLine(
        Offset(math.cos(a) * 8, math.sin(a) * 8),
        Offset(math.cos(a) * r, math.sin(a) * r),
        p,
      );
    }
    c.drawCircle(Offset.zero, 6, Paint()..color = Colors.black87);
    c.restore();
  }

  void _vizatoEnergjine(Canvas c, Offset turbine, Rect battery, Offset bulb) {
    final p = Paint()..color = Colors.black87..strokeWidth = 2.5..style = PaintingStyle.stroke;
    final tOut = Offset(turbine.dx + 41, turbine.dy);
    final bIn = Offset(battery.left, battery.center.dy);
    final bOut = Offset(battery.right, battery.top + 18);
    c.drawPath(Path()..moveTo(tOut.dx, tOut.dy)..lineTo(bIn.dx - 18, tOut.dy)..lineTo(bIn.dx - 18, bIn.dy)..lineTo(bIn.dx, bIn.dy), p);
    c.drawPath(Path()..moveTo(bOut.dx, bOut.dy)..lineTo(bulb.dx - 18, bOut.dy)..lineTo(bulb.dx - 18, bulb.dy)..lineTo(bulb.dx, bulb.dy), p);

    final energji = bateria > 0.05 ? Colors.lightGreenAccent : Colors.transparent;
    c.drawCircle(Offset.lerp(tOut, bIn, 0.5)!, 4, Paint()..color = energji);
    c.drawCircle(Offset.lerp(bOut, bulb, 0.6)!, 4, Paint()..color = energji);
  }

  void _vizatoBaterine(Canvas c, Rect rect) {
    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = Colors.black87,
    );
    c.drawRect(Rect.fromLTWH(rect.left + rect.width * 0.33, rect.top - 10, rect.width * 0.34, 10), Paint()..color = Colors.black87);
    final h = (rect.height - 8) * bateria;
    final fill = Rect.fromLTWH(rect.left + 4, rect.bottom - h - 4, rect.width - 8, h);
    c.drawRRect(RRect.fromRectAndRadius(fill, const Radius.circular(7)), Paint()..color = Color.lerp(Colors.red, Colors.green, bateria)!);
  }

  void _vizatoLlamben(Canvas c, Offset center) {
    final level = bateria.clamp(0.0, 1.0);
    if (level > 0.12) {
      c.drawCircle(
        center,
        28,
        Paint()
          ..color = Colors.amber.withOpacity(0.12 + level * 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
    c.drawCircle(center, 18, Paint()..color = Color.lerp(Colors.grey.shade300, Colors.amber.shade500, level)!);
    c.drawCircle(center, 18, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant PiktoriGjeneratorit oldDelegate) {
    return progresi != oldDelegate.progresi || rrjedhaUjit != oldDelegate.rrjedhaUjit || bateria != oldDelegate.bateria;
  }
}
