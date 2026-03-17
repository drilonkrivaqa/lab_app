import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../painters/magnet_painter.dart';
import '../simulations/induction_model.dart';
import '../widgets/common_widgets.dart';

class FaqjaMagneti extends StatefulWidget {
  const FaqjaMagneti({super.key});

  @override
  State<FaqjaMagneti> createState() => _FaqjaMagnetiState();
}

class _FaqjaMagnetiState extends State<FaqjaMagneti>
    with TickerProviderStateMixin {
  late final AnimationController _vizualController;
  late final AnimationController _simController;

  // Pozicioni bazë i magnetit në boshtin X
  double magnetX = -120;

  // Vlerë e shfaqur në UI / llambë
  double forcaInduksionit = 0;

  // Shpejtësia horizontale e magnetit
  double magnetVelocity = 0;

  // Parametra të rinj
  bool showFieldLines = true;
  bool showCompass = true;

  double magnetStrength = 1.0;
  double coilTurns = 20;
  double bulbSensitivity = 1.0;

  // Compass
  double compassAngle = 0;
  double targetCompassAngle = 0;

  // Gjendje e drag
  bool _isDragging = false;
  DateTime? _kohaFundit;

  // Për përditësim fizik
  Duration _lastTick = Duration.zero;

  // Pozicion i përafërt i spiralës në koordinata lokale të painter-it
  // I lëmë të sinkronizuara me logjikën ekzistuese.
  static const double _coilCenterX = 90.0;
  static const double _minMagnetX = -150.0;
  static const double _maxMagnetX = 150.0;

  double get _afersia =>
      (1 - ((magnetX - _coilCenterX).abs() / 260)).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();

    _vizualController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _simController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_tickSimulimin)
      ..repeat();
  }

  @override
  void dispose() {
    _vizualController.dispose();
    _simController.dispose();
    super.dispose();
  }

  void _tickSimulimin() {
    final now = _simController.lastElapsedDuration ?? Duration.zero;
    double dt = 0.016;

    if (_lastTick != Duration.zero) {
      final raw = (now - _lastTick).inMicroseconds / 1000000.0;
      dt = raw.clamp(0.001, 0.035);
    }
    _lastTick = now;

    if (!_isDragging) {
      // Inerci + damping
      magnetX += magnetVelocity * dt;
      magnetX = magnetX.clamp(_minMagnetX, _maxMagnetX);

      final damping = math.pow(0.18, dt).toDouble();
      magnetVelocity *= damping;

      if (magnetX <= _minMagnetX || magnetX >= _maxMagnetX) {
        magnetVelocity *= -0.18;
      }

      if (magnetVelocity.abs() < 2.0) {
        magnetVelocity = 0;
      }
    }

    final proximity = _afersia;
    final speed = magnetVelocity.abs();

    // Induksioni të varet kryesisht nga lëvizja pranë spirales
    final fuqiRaw = InduksionModel.llogaritFuqine(
      shpejtesia: speed,
      largesiaNorm: 1 - proximity,
    );

    // Përforcim sipas parametrave të simulimit
    final turnsFactor = ui.lerpDouble(0.75, 1.5, ((coilTurns - 5) / 45).clamp(0.0, 1.0))!;
    final strengthFactor = ui.lerpDouble(0.6, 1.6, magnetStrength.clamp(0.0, 1.0))!;
    final bulbFactor = ui.lerpDouble(0.7, 1.5, bulbSensitivity.clamp(0.0, 1.0))!;

    final targetInduction =
    (fuqiRaw * turnsFactor * strengthFactor * bulbFactor).clamp(0.0, 1.0);

    // Smooth response vizuale
    forcaInduksionit =
        ui.lerpDouble(forcaInduksionit, targetInduction, 0.12)!.clamp(0.0, 1.0);

    // Compass reaction
    // Kur magneti është në të majtë të spiralës, fusha lokale anon në një kah,
    // kur është në të djathtë anon në kahun tjetër.
    final dx = (_coilCenterX - magnetX);
    final normDx = (dx / 140).clamp(-1.0, 1.0);
    final fieldInfluence = (_afersia * magnetStrength).clamp(0.0, 1.0);

    targetCompassAngle = normDx * 0.95 * fieldInfluence;
    compassAngle = ui.lerpDouble(compassAngle, targetCompassAngle, 0.10)!;

    if (mounted) {
      setState(() {});
    }
  }

  void _nisTerheqjen(DragStartDetails _) {
    _isDragging = true;
    _kohaFundit = DateTime.now();
  }

  void _levizMagnetin(DragUpdateDetails details) {
    final tani = DateTime.now();
    final dtMs = (_kohaFundit == null)
        ? 16
        : tani.difference(_kohaFundit!).inMilliseconds.clamp(1, 50);
    _kohaFundit = tani;

    final xRi = (magnetX + details.delta.dx).clamp(_minMagnetX, _maxMagnetX);
    final shpejtesiaPxPerSec = (details.delta.dx / dtMs) * 1000.0;

    setState(() {
      magnetX = xRi;
      magnetVelocity = shpejtesiaPxPerSec;
    });
  }

  void _ndaloTerheqjen([DragEndDetails? _]) {
    _isDragging = false;
    _kohaFundit = null;
  }

  void _ndaloTerheqjenPaDetaje() {
    _ndaloTerheqjen();
  }

  void _rivendos() {
    setState(() {
      magnetX = -120;
      magnetVelocity = 0;
      forcaInduksionit = 0;
      compassAngle = 0;
      targetCompassAngle = 0;
      showFieldLines = true;
      showCompass = true;
      magnetStrength = 1.0;
      coilTurns = 20;
      bulbSensitivity = 1.0;
      _isDragging = false;
      _kohaFundit = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final llambaNdezur = forcaInduksionit > 0.05;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Kartela(
            child: SizedBox(
              height: 430,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanStart: _nisTerheqjen,
                    onPanUpdate: _levizMagnetin,
                    onPanEnd: _ndaloTerheqjen,
                    onPanCancel: _ndaloTerheqjenPaDetaje,
                    child: Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _vizualController,
                          builder: (context, _) => CustomPaint(
                            painter: PiktoriMagneti(
                              progresi: _vizualController.value,
                              magnetX: magnetX,
                              niveliDrites: forcaInduksionit,
                              afersia: _afersia,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        if (showFieldLines)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _FieldLinesPainter(
                                  magnetX: magnetX,
                                  afersia: _afersia,
                                  magnetStrength: magnetStrength,
                                ),
                              ),
                            ),
                          ),
                        if (showCompass)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _CompassOverlayPainter(
                                  angle: compassAngle,
                                  activity: (_afersia * magnetStrength)
                                      .clamp(0.0, 1.0),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: _BadgeInfo(
                            label: llambaNdezur ? 'Llamba: Ndezur' : 'Llamba: Fikur',
                            icon: llambaNdezur
                                ? Icons.lightbulb
                                : Icons.lightbulb_outline,
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: _BadgeInfo(
                            label:
                            'v = ${magnetVelocity.abs().toStringAsFixed(0)} px/s',
                            icon: Icons.speed,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Kartela(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Si përdoret',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tërhiq magnetin majtas-djathtas pranë spiralës. '
                      'Llamba ndizet më shumë kur magneti lëviz më shpejt pranë spiralës. '
                      'Mund të shfaqësh ose fshehësh vijat e fushës magnetike dhe kompasin.',
                ),
                const SizedBox(height: 18),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Shfaq vijat e fushës'),
                  value: showFieldLines,
                  onChanged: (v) => setState(() => showFieldLines = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Shfaq kompasin'),
                  value: showCompass,
                  onChanged: (v) => setState(() => showCompass = v),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Forca e magnetit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: magnetStrength,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: magnetStrength.toStringAsFixed(1),
                  onChanged: (v) => setState(() => magnetStrength = v),
                ),
                const Text(
                  'Numri i mbështjelljeve',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: coilTurns,
                  min: 5,
                  max: 50,
                  divisions: 45,
                  label: coilTurns.round().toString(),
                  onChanged: (v) => setState(() => coilTurns = v),
                ),
                const Text(
                  'Ndjeshmëria e llambës',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: bulbSensitivity,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: bulbSensitivity.toStringAsFixed(1),
                  onChanged: (v) => setState(() => bulbSensitivity = v),
                ),
                const SizedBox(height: 12),
                InfoRresht(
                  etiketa: 'Gjendja e llambës',
                  vlera: llambaNdezur ? 'Ndezur' : 'Fikur',
                ),
                const SizedBox(height: 6),
                InfoRresht(
                  etiketa: 'Forca e induksionit',
                  vlera: forcaInduksionit.toStringAsFixed(2),
                ),
                const SizedBox(height: 6),
                InfoRresht(
                  etiketa: 'Afërsia me spiralen',
                  vlera: _afersia.toStringAsFixed(2),
                ),
                const SizedBox(height: 6),
                InfoRresht(
                  etiketa: 'Shpejtësia e magnetit',
                  vlera: magnetVelocity.abs().toStringAsFixed(0),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _rivendos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Rivendos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeInfo extends StatelessWidget {
  final String label;
  final IconData icon;

  const _BadgeInfo({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLinesPainter extends CustomPainter {
  final double magnetX;
  final double afersia;
  final double magnetStrength;

  const _FieldLinesPainter({
    required this.magnetX,
    required this.afersia,
    required this.magnetStrength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.40;
    final magnetCenter = Offset(size.width * 0.5 + magnetX, centerY);
    final intensity = (0.20 + (afersia * 0.55) + (magnetStrength * 0.25))
        .clamp(0.15, 0.95);

    final paint = Paint()
      ..color = Colors.blueGrey.withOpacity(intensity * 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final smallPaint = Paint()
      ..color = Colors.blueGrey.withOpacity(intensity * 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final radii = <double>[36, 54, 76, 102, 132];

    for (final r in radii) {
      final pathTop = Path()
        ..moveTo(magnetCenter.dx - r, magnetCenter.dy)
        ..quadraticBezierTo(
          magnetCenter.dx,
          magnetCenter.dy - r * 0.92,
          magnetCenter.dx + r,
          magnetCenter.dy,
        );

      final pathBottom = Path()
        ..moveTo(magnetCenter.dx - r, magnetCenter.dy)
        ..quadraticBezierTo(
          magnetCenter.dx,
          magnetCenter.dy + r * 0.92,
          magnetCenter.dx + r,
          magnetCenter.dy,
        );

      canvas.drawPath(pathTop, paint);
      canvas.drawPath(pathBottom, paint);
    }

    for (final r in <double>[22, 30]) {
      final pathTop = Path()
        ..moveTo(magnetCenter.dx - r, magnetCenter.dy)
        ..quadraticBezierTo(
          magnetCenter.dx,
          magnetCenter.dy - r * 0.86,
          magnetCenter.dx + r,
          magnetCenter.dy,
        );

      final pathBottom = Path()
        ..moveTo(magnetCenter.dx - r, magnetCenter.dy)
        ..quadraticBezierTo(
          magnetCenter.dx,
          magnetCenter.dy + r * 0.86,
          magnetCenter.dx + r,
          magnetCenter.dy,
        );

      canvas.drawPath(pathTop, smallPaint);
      canvas.drawPath(pathBottom, smallPaint);
    }

    _drawArrowHints(canvas, magnetCenter, paint);
  }

  void _drawArrowHints(Canvas canvas, Offset c, Paint paintBase) {
    final paint = Paint()
      ..color = paintBase.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final offsets = <Offset>[
      const Offset(-60, -36),
      const Offset(60, -36),
      const Offset(-60, 36),
      const Offset(60, 36),
    ];

    for (final o in offsets) {
      final p = c + o;
      canvas.drawLine(p, p + const Offset(8, -4), paint);
      canvas.drawLine(p, p + const Offset(8, 4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FieldLinesPainter oldDelegate) {
    return oldDelegate.magnetX != magnetX ||
        oldDelegate.afersia != afersia ||
        oldDelegate.magnetStrength != magnetStrength;
  }
}

class _CompassOverlayPainter extends CustomPainter {
  final double angle;
  final double activity;

  const _CompassOverlayPainter({
    required this.angle,
    required this.activity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width - 54, size.height - 54);
    const radius = 28.0;

    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawCircle(center, radius, borderPaint);

    final crossPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx - 16, center.dy),
      Offset(center.dx + 16, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 16),
      Offset(center.dx, center.dy + 16),
      crossPaint,
    );

    final pulse = 0.85 + (activity * 0.25);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final northPaint = Paint()
      ..color = Colors.red.withOpacity((0.80 * pulse).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final southPaint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final needleNorth = Path()
      ..moveTo(0, -19)
      ..lineTo(5.5, 0)
      ..lineTo(-5.5, 0)
      ..close();

    final needleSouth = Path()
      ..moveTo(0, 19)
      ..lineTo(5.5, 0)
      ..lineTo(-5.5, 0)
      ..close();

    canvas.drawPath(needleNorth, northPaint);
    canvas.drawPath(needleSouth, southPaint);
    canvas.drawCircle(Offset.zero, 3.2, Paint()..color = Colors.black87);

    canvas.restore();

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - radius + 4),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassOverlayPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.activity != activity;
  }
}