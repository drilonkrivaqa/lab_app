import 'package:flutter/material.dart';

class PiktoriQarku extends CustomPainter {
  final double progresi;
  final bool qarkuMbyllur;
  final double ndricimi;
  final double rryma;
  final double tensioni;
  final double rezistenca;
  final double shpejtesiaNgarkesave;

  PiktoriQarku({
    required this.progresi,
    required this.qarkuMbyllur,
    required this.ndricimi,
    required this.rryma,
    required this.tensioni,
    required this.rezistenca,
    required this.shpejtesiaNgarkesave,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bgColor = Color(0xFFF7F9FC);
    const wireColor = Color(0xFF5C6670);

    final wirePaint = Paint()
      ..color = wireColor
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final wireHighlight = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final left = size.width * 0.16;
    final right = size.width * 0.84;
    final top = size.height * 0.26;
    final bottom = size.height * 0.72;

    final bulbCenter = Offset(size.width * 0.50, top);
    final bulbRadius = 28.0;

    final resistorLeft = size.width * 0.66;
    final resistorRight = size.width * 0.78;

    final switchLeft = size.width * 0.28;
    final switchRight = size.width * 0.38;

    final batteryX = left;
    final batteryTop = size.height * 0.38;
    final batteryBottom = size.height * 0.58;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = bgColor,
    );

    canvas.drawRect(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Paint()
        ..color = Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final path = Path()
      ..moveTo(batteryX, top)
      ..lineTo(bulbCenter.dx - bulbRadius, top)
      ..moveTo(bulbCenter.dx + bulbRadius, top)
      ..lineTo(right, top)
      ..lineTo(right, bottom)
      ..lineTo(resistorRight, bottom)
      ..moveTo(resistorLeft, bottom)
      ..lineTo(switchRight, bottom);

    if (qarkuMbyllur) {
      path.lineTo(switchLeft, bottom);
    }

    path
      ..moveTo(switchLeft, bottom)
      ..lineTo(left, bottom)
      ..lineTo(left, batteryBottom)
      ..moveTo(left, batteryTop)
      ..lineTo(left, top);

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

    // Labels moved to empty zones so they don't sit on top of the circuit
    _drawLabelCard(
      canvas,
      'Bateri\n${tensioni.toStringAsFixed(0)} V',
      Rect.fromCenter(
        center: Offset(size.width * 0.14, size.height * 0.18),
        width: 86,
        height: 42,
      ),
    );

    _drawLabelCard(
      canvas,
      'Llambë',
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.10),
        width: 72,
        height: 34,
      ),
    );

    _drawLabelCard(
      canvas,
      'Rezistencë\n${rezistenca.toStringAsFixed(0)} Ω',
      Rect.fromCenter(
        center: Offset(size.width * 0.80, size.height * 0.86),
        width: 104,
        height: 42,
      ),
    );

    _drawLabelCard(
      canvas,
      qarkuMbyllur ? 'Çelësi\nmbyllur' : 'Çelësi\nhapur',
      Rect.fromCenter(
        center: Offset(size.width * 0.18, size.height * 0.86),
        width: 92,
        height: 42,
      ),
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

    final plusPainter = TextPainter(
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

    plusPainter.paint(canvas, Offset(x + 18, top - 4));

    final minusPainter = TextPainter(
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

    minusPainter.paint(canvas, Offset(x + 18, bottom - 14));
  }

  void _drawBulb(
      Canvas canvas,
      Offset center,
      double radius,
      double brightness,
      ) {
    if (brightness > 0) {
      final glow = Paint()
        ..color = Colors.yellow.withOpacity(0.22 + brightness * 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(center, radius + 8, glow);
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

    final filamentPath = Path()
      ..moveTo(center.dx - 12, center.dy + 4)
      ..lineTo(center.dx - 6, center.dy - 4)
      ..lineTo(center.dx, center.dy + 4)
      ..lineTo(center.dx + 6, center.dy - 4)
      ..lineTo(center.dx + 12, center.dy + 4);

    canvas.drawPath(filamentPath, filament);

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
    final rect = Rect.fromLTWH(left, y - 14, right - left, 28);

    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFFF5D7A1),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRect(
      Rect.fromLTWH(left + 14, y - 14, 6, 28),
      Paint()..color = Colors.brown,
    );
    canvas.drawRect(
      Rect.fromLTWH(left + 28, y - 14, 6, 28),
      Paint()..color = Colors.red,
    );
    canvas.drawRect(
      Rect.fromLTWH(left + 42, y - 14, 6, 28),
      Paint()..color = Colors.blue,
    );
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
      Canvas canvas, {
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
    const spacing = 28.0;

    for (double x = left; x < bulbCenter.dx - bulbRadius; x += spacing) {
      points.add(Offset(x, top));
    }
    for (double x = bulbCenter.dx + bulbRadius; x < right; x += spacing) {
      points.add(Offset(x, top));
    }
    for (double y = top; y < bottom; y += spacing) {
      points.add(Offset(right, y));
    }
    for (double x = right; x > resistorRight; x -= spacing) {
      points.add(Offset(x, bottom));
    }
    for (double x = resistorLeft; x > switchLeft; x -= spacing) {
      points.add(Offset(x, bottom));
    }
    for (double x = switchLeft; x > left; x -= spacing) {
      points.add(Offset(x, bottom));
    }
    for (double y = bottom; y > top; y -= spacing) {
      points.add(Offset(left, y));
    }

    if (points.isEmpty) return;

    final effectiveProgress = (progresi * shpejtesiaNgarkesave * 6.0) % 1.0;
    final shift = (effectiveProgress * points.length).floor();

    for (int i = 0; i < points.length; i++) {
      final p = points[(i + shift) % points.length];
      final strong = i % 4 == 0;

      canvas.drawCircle(
        p,
        strong ? 4.2 : 3.1,
        Paint()
          ..color = const Color(0xFF42A5F5).withOpacity(strong ? 0.95 : 0.38),
      );
    }
  }

  void _drawLabelCard(Canvas canvas, String text, Rect rect) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    canvas.drawRRect(
      rrect,
      Paint()..color = Colors.white.withOpacity(0.92),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          height: 1.15,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: rect.width - 10);

    tp.paint(
      canvas,
      Offset(
        rect.center.dx - tp.width / 2,
        rect.center.dy - tp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant PiktoriQarku oldDelegate) {
    return progresi != oldDelegate.progresi ||
        qarkuMbyllur != oldDelegate.qarkuMbyllur ||
        ndricimi != oldDelegate.ndricimi ||
        rryma != oldDelegate.rryma ||
        tensioni != oldDelegate.tensioni ||
        rezistenca != oldDelegate.rezistenca ||
        shpejtesiaNgarkesave != oldDelegate.shpejtesiaNgarkesave;
  }
}