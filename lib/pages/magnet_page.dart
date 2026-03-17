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

class _FaqjaMagnetiState extends State<FaqjaMagneti> with TickerProviderStateMixin {
  late final AnimationController _vizualController;
  late final AnimationController _simController;

  static const double _coilCenterX = 90.0;
  static const double _minMagnetX = -160.0;
  static const double _maxMagnetX = 155.0;

  double magnetX = -120;
  double magnetVelocity = 0;
  double forcaInduksionit = 0;
  double sinjaliRrymes = 0;
  double currentIntensity = 0;
  double currentDirection = 0;

  bool showFieldLines = true;
  bool showCompass = true;

  double magnetStrength = 1.0;
  double coilTurns = 20;
  double bulbSensitivity = 1.0;

  double compassAngle = 0;

  bool _isDragging = false;
  Duration _lastTick = Duration.zero;
  double _fluxiFundit = 0;
  DateTime? _kohaDrag;

  double get _afersia {
    final d = ((magnetX - _coilCenterX).abs() / 260).clamp(0.0, 1.3);
    return (1 - d).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _vizualController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _simController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )
      ..addListener(_tickSimulimin)
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
    var dt = 0.016;

    if (_lastTick != Duration.zero) {
      dt = ((now - _lastTick).inMicroseconds / 1000000.0).clamp(0.001, 0.035);
    }
    _lastTick = now;

    if (!_isDragging) {
      magnetVelocity = ui.lerpDouble(magnetVelocity, 0, (6.2 * dt).clamp(0.0, 1.0))!.clamp(-1200.0, 1200.0);
      if (magnetVelocity.abs() < 6) magnetVelocity = 0;
    }

    final afersia = _afersia;
    final fluksi = InduksionModel.llogaritFluks(
      afersia: afersia,
      forcaMagnetit: magnetStrength,
      mbeshtjelljet: coilTurns,
    );

    final deltaFluks = (fluksi - _fluxiFundit) / dt;
    _fluxiFundit = fluksi;

    final targetSignal = InduksionModel.llogaritSinjalInduksioni(
      deltaFluksi: deltaFluks,
      shpejtesia: magnetVelocity,
      afersia: afersia,
      ndjeshmeriaLlambes: bulbSensitivity,
    );

    final lerpSignal = _isDragging ? 0.18 : 0.12;
    sinjaliRrymes = ui.lerpDouble(sinjaliRrymes, targetSignal, lerpSignal)!.clamp(-1.0, 1.0);

    final targetIntensity = sinjaliRrymes.abs();
    final intensityLerp = targetIntensity > currentIntensity ? 0.22 : (_isDragging ? 0.16 : 0.08);
    currentIntensity = ui.lerpDouble(currentIntensity, targetIntensity, intensityLerp)!.clamp(0.0, 1.0);

    final directionThreshold = 0.05;
    if (sinjaliRrymes.abs() < directionThreshold) {
      currentDirection = ui.lerpDouble(currentDirection, 0, 0.12)!;
    } else {
      currentDirection = ui.lerpDouble(currentDirection, sinjaliRrymes.sign, 0.24)!;
    }

    final bulbTarget = (currentIntensity * (0.85 + afersia * 0.35)).clamp(0.0, 1.0);
    final bulbLerp = bulbTarget > forcaInduksionit ? 0.2 : (_isDragging ? 0.14 : 0.09);
    forcaInduksionit = ui.lerpDouble(forcaInduksionit, bulbTarget, bulbLerp)!.clamp(0.0, 1.0);

    final distanceNorm = ((magnetX - _coilCenterX).abs() / 220).clamp(0.0, 1.0);
    final fieldStrength = math.pow(1 - distanceNorm, 2.2).toDouble() * (0.35 + 0.65 * magnetStrength);
    final orientation = (magnetX < _coilCenterX ? 1.0 : -1.0);
    final targetCompass = orientation * fieldStrength * 1.05;
    compassAngle = ui.lerpDouble(compassAngle, targetCompass, 0.08 + fieldStrength * 0.12)!;

    if (mounted) {
      setState(() {});
    }
  }

  void _nisTerheqjen(DragStartDetails _) {
    _isDragging = true;
    _kohaDrag = DateTime.now();
  }

  void _levizMagnetin(DragUpdateDetails details) {
    final tani = DateTime.now();
    final dtUs = (_kohaDrag == null) ? 16000 : tani.difference(_kohaDrag!).inMicroseconds.clamp(2000, 48000);
    _kohaDrag = tani;

    final rawDelta = details.delta.dx;
    final xRi = (magnetX + rawDelta).clamp(_minMagnetX, _maxMagnetX);

    var rawV = (rawDelta / dtUs) * 1000000;
    if (rawDelta.abs() < 0.15) rawV = 0;

    if (xRi == _minMagnetX || xRi == _maxMagnetX) {
      rawV *= 0.35;
    }

    setState(() {
      magnetX = xRi;
      magnetVelocity = ui.lerpDouble(magnetVelocity, rawV, 0.32)!.clamp(-1000.0, 1000.0);
      if (magnetVelocity.abs() < 3.5) magnetVelocity = 0;
    });
  }

  void _ndaloTerheqjen([DragEndDetails? _]) {
    setState(() {
      _isDragging = false;
      _kohaDrag = null;
      magnetVelocity *= 0.35;
      if (magnetVelocity.abs() < 24) magnetVelocity = 0;
    });
  }

  void _rivendos() {
    setState(() {
      magnetX = -120;
      magnetVelocity = 0;
      forcaInduksionit = 0;
      sinjaliRrymes = 0;
      currentIntensity = 0;
      currentDirection = 0;
      compassAngle = 0;
      _fluxiFundit = 0;

      showFieldLines = true;
      showCompass = true;
      magnetStrength = 1.0;
      coilTurns = 20;
      bulbSensitivity = 1.0;

      _isDragging = false;
      _kohaDrag = null;
    });
  }

  String get _drejtimiRrymes {
    if (currentIntensity < 0.05 || currentDirection.abs() < 0.2) return 'Pa rrymë';
    return currentDirection > 0 ? 'Orar' : 'Kundërorar';
  }

  String get _statusLidhurMeSpiralen {
    if (magnetVelocity.abs() < 8) return 'I palëvizshëm';
    final toward = (_coilCenterX - magnetX) * magnetVelocity > 0;
    return toward ? 'Po afrohet' : 'Po largohet';
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
              child: GestureDetector(
                onPanStart: _nisTerheqjen,
                onPanUpdate: _levizMagnetin,
                onPanEnd: _ndaloTerheqjen,
                onPanCancel: () => _ndaloTerheqjen(),
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
                          coilTurns: coilTurns,
                          currentIntensity: currentIntensity,
                          currentDirection: currentDirection,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    if (showFieldLines)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _FieldLinesPainter(
                              progresi: _vizualController.value,
                              magnetX: magnetX,
                              afersia: _afersia,
                              magnetStrength: magnetStrength,
                              induction: currentIntensity,
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
                              activity: (_afersia * magnetStrength).clamp(0.0, 1.0),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: _BadgeInfo(
                        label: llambaNdezur ? 'Llamba: Ndezur' : 'Llamba: Fikur',
                        icon: llambaNdezur ? Icons.lightbulb : Icons.lightbulb_outline,
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: _BadgeInfo(
                        label: 'Rryma: $_drejtimiRrymes',
                        icon: Icons.sync,
                      ),
                    ),
                  ],
                ),
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
                const SizedBox(height: 10),
                const Text(
                  'Lëviz magnetin majtas-djathtas pranë spiralës. Rryma induktohet kur fluksi magnetik ndryshon; '
                  'sa më shpejt dhe sa më afër spirales, aq më e fortë është ndezja e llambës.',
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 8),
                const Text('Forca e magnetit', style: TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: magnetStrength,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: magnetStrength.toStringAsFixed(1),
                  onChanged: (v) => setState(() => magnetStrength = v),
                ),
                const Text('Numri i mbështjelljeve', style: TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: coilTurns,
                  min: 5,
                  max: 50,
                  divisions: 45,
                  label: coilTurns.round().toString(),
                  onChanged: (v) => setState(() => coilTurns = v),
                ),
                const Text('Ndjeshmëria e llambës', style: TextStyle(fontWeight: FontWeight.w600)),
                Slider(
                  value: bulbSensitivity,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: bulbSensitivity.toStringAsFixed(1),
                  onChanged: (v) => setState(() => bulbSensitivity = v),
                ),
                const SizedBox(height: 10),
                InfoRresht(etiketa: 'Gjendja e llambës', vlera: llambaNdezur ? 'Ndezur' : 'Fikur'),
                const SizedBox(height: 6),
                InfoRresht(etiketa: 'Vlera e induksionit', vlera: currentIntensity.toStringAsFixed(2)),
                const SizedBox(height: 6),
                InfoRresht(etiketa: 'Drejtimi i rrymës', vlera: _drejtimiRrymes),
                const SizedBox(height: 6),
                InfoRresht(etiketa: 'Lëvizja ndaj spirales', vlera: _statusLidhurMeSpiralen),
                const SizedBox(height: 6),
                InfoRresht(etiketa: 'Shpejtësia e magnetit', vlera: '${magnetVelocity.abs().toStringAsFixed(0)} px/s'),
                const SizedBox(height: 14),
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
        color: const Color(0xFF1F2A37).withOpacity(0.78),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLinesPainter extends CustomPainter {
  final double progresi;
  final double magnetX;
  final double afersia;
  final double magnetStrength;
  final double induction;

  const _FieldLinesPainter({
    required this.progresi,
    required this.magnetX,
    required this.afersia,
    required this.magnetStrength,
    required this.induction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.52;
    final magnetCenter = Offset(size.width * 0.5 + magnetX, centerY);

    const halfWidth = 64.0;
    const halfHeight = 19.0;
    final leftFace = Offset(magnetCenter.dx - halfWidth, magnetCenter.dy);
    final rightFace = Offset(magnetCenter.dx + halfWidth, magnetCenter.dy);

    final visibility = (0.12 + afersia * 0.30 + magnetStrength * 0.30 + induction * 0.25).clamp(0.12, 0.82);

    final basePaint = Paint()
      ..color = const Color(0xFF607D8B).withOpacity(visibility)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF90CAF9).withOpacity(visibility * 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

    const gaps = [24.0, 44.0, 68.0, 96.0];
    for (int i = 0; i < gaps.length; i++) {
      final wobble = math.sin((progresi * math.pi * 2) + i * 0.55) * (1.5 + induction * 1.5);
      final gap = gaps[i] + wobble;

      final top = Path()
        ..moveTo(rightFace.dx, rightFace.dy - halfHeight)
        ..cubicTo(
          rightFace.dx + gap * 0.55,
          rightFace.dy - halfHeight,
          magnetCenter.dx + gap * 0.88,
          magnetCenter.dy - gap,
          magnetCenter.dx,
          magnetCenter.dy - gap,
        )
        ..cubicTo(
          magnetCenter.dx - gap * 0.88,
          magnetCenter.dy - gap,
          leftFace.dx - gap * 0.55,
          leftFace.dy - halfHeight,
          leftFace.dx,
          leftFace.dy - halfHeight,
        );

      final bottom = Path()
        ..moveTo(rightFace.dx, rightFace.dy + halfHeight)
        ..cubicTo(
          rightFace.dx + gap * 0.55,
          rightFace.dy + halfHeight,
          magnetCenter.dx + gap * 0.88,
          magnetCenter.dy + gap,
          magnetCenter.dx,
          magnetCenter.dy + gap,
        )
        ..cubicTo(
          magnetCenter.dx - gap * 0.88,
          magnetCenter.dy + gap,
          leftFace.dx - gap * 0.55,
          leftFace.dy + halfHeight,
          leftFace.dx,
          leftFace.dy + halfHeight,
        );

      canvas.drawPath(top, glowPaint);
      canvas.drawPath(bottom, glowPaint);
      canvas.drawPath(top, basePaint);
      canvas.drawPath(bottom, basePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FieldLinesPainter oldDelegate) {
    return oldDelegate.progresi != progresi ||
        oldDelegate.magnetX != magnetX ||
        oldDelegate.afersia != afersia ||
        oldDelegate.magnetStrength != magnetStrength ||
        oldDelegate.induction != induction;
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
    final center = Offset(size.width - 58, size.height - 56);
    const radius = 30.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.95)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF1F2937).withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final ringPaint = Paint()
      ..color = const Color(0xFF90A4AE).withOpacity(0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 20, ringPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final intensity = (0.35 + activity * 0.65).clamp(0.0, 1.0);

    final north = Path()
      ..moveTo(0, -20)
      ..lineTo(6, 0)
      ..lineTo(-6, 0)
      ..close();

    final south = Path()
      ..moveTo(0, 20)
      ..lineTo(6, 0)
      ..lineTo(-6, 0)
      ..close();

    canvas.drawPath(
      north,
      Paint()..color = const Color(0xFFEF5350).withOpacity(0.65 + intensity * 0.35),
    );

    canvas.drawPath(
      south,
      Paint()..color = const Color(0xFF546E7A).withOpacity(0.88),
    );

    canvas.drawCircle(Offset.zero, 3.2, Paint()..color = const Color(0xFF1F2937));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassOverlayPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.activity != activity;
  }
}
