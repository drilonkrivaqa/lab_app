import 'dart:math' as math;
import 'package:flutter/material.dart';

class PiktoriQarku extends CustomPainter {
  final double progresi;
  final bool qarkuMbyllur;
  final double ndricimi;
  final double rryma;
  final double tensioni;
  final double rezistenca;

  PiktoriQarku({
    required this.progresi,
    required this.qarkuMbyllur,
    required this.ndricimi,
    required this.rryma,
    required this.tensioni,
    required this.rezistenca,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = const Color(0xFF5C6670)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final wireHighlight = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final left = size.width * 0.16;
    final right = size.width * 0.84;
    final top = size.height * 0.26;
    final bottom = size.height * 0.72;

    final bulbCenter = Offset(size.width * 0.50, top);
    final bulbRadius = 30.0;

    final resistorLeft = size.width * 0.66;
    final resistorRight = size.width * 0.78;

    final switchLeft = size.width * 0.28;
    final switchRight = size.width * 0.38;

    final batteryX = left;
    final batteryTop = size.height * 0.38;
    final batteryBottom = size.height * 0.58;

    final bg = Paint()..color = const Color(0xFFF7F9FC);
    canvas.drawRect(Offset.zero & size, bg);

    final border = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      border,
    );

    final path = Path();

    path.moveTo(batteryX, top);
    path.lineTo(bulbCenter.dx - bulbRadius, top);

    path.moveTo(bulbCenter.dx + bulbRadius, top);
    path.lineTo(right, top);
    path.lineTo(right, bottom);
    path.lineTo(resistorRight, bottom);

    path.moveTo(resistorLeft, bottom);
    path.lineTo(switchRight, bottom);

    if (qarkuMbyllur) {
      path.lineTo(switchLeft, bottom);
    }

    path.moveTo(switchLeft, bottom);
    path.lineTo(left, bottom);
    path.lineTo(left, batteryBottom);

    path.moveTo(left, batteryTop);
    path.lineTo(left, top);

    canvas.drawPath(path, wirePaint);
    canvas.drawPath(path, wireHighlight);

    _drawBattery(
      canvas,
      x: batteryX,
      top: batteryTop,
      bottom: batteryBottom,
    );

    _drawBulb(canvas, bulbCenter, bulbRadius, ndricimi);
    _drawResistor(canvas, resistorLeft, resistorRight, bottom);
    _drawSwitch(canvas, switchLeft, switchRight, bottom, qarkuMbyllur);

    if (qarkuMbyllur) {
      _drawCharges(
        canvas,
        size,
        left: left,
        right: right,
        top: top,
        bottom: bottom,
        bulbCenter: bulbCenter,
        bulbRadius: bulbRadius,
        resistorLeft: resistorLeft,
        resistorRight: resistorRight,
        switchLeft: switchLeft,
      );
    }

    _drawLabel(
      canvas,
      'Bateri\n${tensioni.toStringAsFixed(0)} V',
      Offset(batteryX, batteryBottom + 14),
    );
    _drawLabel(
      canvas,
      'Llambë',
      Offset(bulbCenter.dx, top - 54),
    );
    _drawLabel(
      canvas,
      'Rezistencë\n${rezistenca.toStringAsFixed(0)} Ω',
      Offset((resistorLeft + resistorRight) / 2, bottom + 16),
    );
    _drawLabel(
      canvas,
      qarkuMbyllur ? 'Çelësi mbyllur' : 'Çelësi hapur',
      Offset((switchLeft + switchRight) / 2, bottom + 22),
    );
  }

  void _drawBattery(
      Canvas canvas, {
        required double x,
        required double top,
        required double bottom,
      }) {
    final longLine = Paint()
      ..color = Colors.black87
      ..strokeWidth = 4;

    final shortLine = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5;

    canvas.drawLine(
      Offset(x - 9, top),
      Offset(x - 9, bottom),
      longLine,
    );
    canvas.drawLine(
      Offset(x + 9, top + 24),
      Offset(x + 9, bottom - 24),
      shortLine,
    );

    final tpPlus = TextPainter(
      text: const TextSpan(
        text: '+',
        style: TextStyle(
          color: Colors.red,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tpPlus.paint(canvas, Offset(x + 18, top - 4));

    final tpMinus = TextPainter(
      text: const TextSpan(
        text: '-',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tpMinus.paint(canvas, Offset(x + 18, bottom - 14));
  }

  void _drawBulb(
      Canvas canvas,
      Offset center,
      double radius,
      double brightness,
      ) {
    if (brightness > 0) {
      final glow = Paint()
        ..color = Colors.yellow.withOpacity(0.35 + brightness * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(center, radius + 10, glow);
    }

    final fill = Paint()
      ..color = Color.lerp(
        const Color(0xFFE8EDF3),
        const Color(0xFFFFE082),
        brightness,
      )!;

    final stroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, stroke);

    final filament = Paint()
      ..color = Color.lerp(Colors.black54, Colors.orange.shade700, brightness)!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(center.dx - 12, center.dy + 4)
      ..lineTo(center.dx - 6, center.dy - 4)
      ..lineTo(center.dx, center.dy + 4)
      ..lineTo(center.dx + 6, center.dy - 4)
      ..lineTo(center.dx + 12, center.dy + 4);

    canvas.drawPath(path, filament);

    final baseRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + radius + 12),
      width: 22,
      height: 16,
    );

    canvas.drawRect(baseRect, Paint()..color = const Color(0xFF9AA4AE));
    canvas.drawRect(
      baseRect,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawResistor(
      Canvas canvas,
      double left,
      double right,
      double y,
      ) {
    final resistorPaint = Paint()
      ..color = const Color(0xFFF5D7A1)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(left, y - 16, right - left, 32);
    canvas.drawRect(rect, resistorPaint);
    canvas.drawRect(rect, borderPaint);

    final stripePaint1 = Paint()..color = Colors.brown;
    final stripePaint2 = Paint()..color = Colors.red;
    final stripePaint3 = Paint()..color = Colors.blue;

    canvas.drawRect(Rect.fromLTWH(left + 14, y - 16, 6, 32), stripePaint1);
    canvas.drawRect(Rect.fromLTWH(left + 28, y - 16, 6, 32), stripePaint2);
    canvas.drawRect(Rect.fromLTWH(left + 42, y - 16, 6, 32), stripePaint3);
  }

  void _drawSwitch(
      Canvas canvas,
      double left,
      double right,
      double y,
      bool closed,
      ) {
    final pointPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(Offset(left, y), 5, pointPaint);
    canvas.drawCircle(Offset(right, y), 5, pointPaint);

    final armPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    if (closed) {
      canvas.drawLine(Offset(left, y), Offset(right, y), armPaint);
    } else {
      canvas.drawLine(Offset(left, y), Offset(right - 6, y - 18), armPaint);
    }
  }

  void _drawCharges(
      Canvas canvas,
      Size size, {
        required double left,
        required double right,
        required double top,
        required double bottom,
        required Offset bulbCenter,
        required double bulbRadius,
        required double resistorLeft,
        required double resistorRight,
        required double switchLeft,
      }) {
    final points = <Offset>[];

    for (double x = left; x < bulbCenter.dx - bulbRadius; x += 22) {
      points.add(Offset(x, top));
    }
    for (double x = bulbCenter.dx + bulbRadius; x < right; x += 22) {
      points.add(Offset(x, top));
    }
    for (double y = top; y < bottom; y += 22) {
      points.add(Offset(right, y));
    }
    for (double x = right; x > resistorRight; x -= 22) {
      points.add(Offset(x, bottom));
    }
    for (double x = resistorLeft; x > switchLeft; x -= 22) {
      points.add(Offset(x, bottom));
    }
    for (double x = switchLeft; x > left; x -= 22) {
      points.add(Offset(x, bottom));
    }
    for (double y = bottom; y > top; y -= 22) {
      points.add(Offset(left, y));
    }

    if (points.isEmpty) return;

    final shift = (progresi * points.length).floor();

    for (int i = 0; i < points.length; i++) {
      final p = points[(i + shift) % points.length];
      final opacity = i % 4 == 0 ? 1.0 : 0.45;
      final paint = Paint()
        ..color = const Color(0xFF42A5F5).withOpacity(opacity);
      canvas.drawCircle(p, 4, paint);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.15,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 120);

    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy));
  }

  @override
  bool shouldRepaint(covariant PiktoriQarku oldDelegate) {
    return progresi != oldDelegate.progresi ||
        qarkuMbyllur != oldDelegate.qarkuMbyllur ||
        ndricimi != oldDelegate.ndricimi ||
        rryma != oldDelegate.rryma ||
        tensioni != oldDelegate.tensioni ||
        rezistenca != oldDelegate.rezistenca;
  }
}