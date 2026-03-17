import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../painters/hydro_painter.dart';
import '../simulations/hydro_model.dart';
import '../widgets/common_widgets.dart';

class FaqjaGjeneratoriUjit extends StatefulWidget {
  const FaqjaGjeneratoriUjit({super.key});

  @override
  State<FaqjaGjeneratoriUjit> createState() => _FaqjaGjeneratoriUjitState();
}

class _FaqjaGjeneratoriUjitState extends State<FaqjaGjeneratoriUjit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrolleri;

  bool gjeneratoriAktiv = true;
  double rrjedhaUjit = 0.7;
  double bateria = 0.0;
  Duration _kohaFundit = Duration.zero;

  @override
  void initState() {
    super.initState();
    _kontrolleri =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..addListener(_perditesoSimulimin)
      ..repeat();
  }

  void _perditesoSimulimin() {
    final koha = _kontrolleri.lastElapsedDuration ?? Duration.zero;
    final dt = (koha - _kohaFundit).inMicroseconds / 1e6;
    _kohaFundit = koha;
    if (dt <= 0) return;

    final eRe = HidroModel.ndryshoNgarkesen(
      aktuale: bateria,
      aktiv: gjeneratoriAktiv,
      rrjedha: rrjedhaUjit,
      dt: dt,
    );

    if ((eRe - bateria).abs() > 0.0005 && mounted) {
      setState(() => bateria = eRe);
    }
  }

  @override
  void dispose() {
    _kontrolleri
      ..removeListener(_perditesoSimulimin)
      ..dispose();
    super.dispose();
  }

  void _rivendos() {
    setState(() {
      gjeneratoriAktiv = true;
      rrjedhaUjit = 0.7;
      bateria = 0;
      _kohaFundit = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final llambaNdezur = bateria >= 0.35;
    final rrjedhaEfektive = gjeneratoriAktiv ? rrjedhaUjit : 0.0;

    return Column(
      children: [
        Expanded(
          child: Kartela(
            child: AnimatedBuilder(
              animation: _kontrolleri,
              builder: (context, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: PiktoriGjeneratorit(
                          progresi: _kontrolleri.value,
                          rrjedhaUjit: rrjedhaEfektive,
                          bateria: bateria,
                        ),
                        child: const SizedBox.expand(),
                      ),

                      // Overlay i ri për ta bërë rrjedhën e ujit më të gjallë
                      IgnorePointer(
                        child: _RrjedhaUjitOverlay(
                          progresi: _kontrolleri.value,
                          rrjedhaUjit: rrjedhaEfektive,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Kartela(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gjeneratori me Ujë',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Aktivizo gjeneratorin'),
                value: gjeneratoriAktiv,
                onChanged: (v) => setState(() => gjeneratoriAktiv = v),
              ),
              Text(
                'Rrjedha e ujit: ${(rrjedhaUjit * 100).toStringAsFixed(0)}%',
              ),
              Slider(
                value: rrjedhaUjit,
                min: 0.1,
                max: 1.0,
                onChanged: (v) => setState(() => rrjedhaUjit = v),
              ),
              const Divider(height: 24),
              InfoRresht(
                etiketa: 'Ngarkesa e baterisë',
                vlera: '${(bateria * 100).toStringAsFixed(0)}%',
              ),
              const SizedBox(height: 6),
              InfoRresht(
                etiketa: 'Llamba',
                vlera: llambaNdezur ? 'Ndezur' : 'Fikur',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _rivendos,
                icon: const Icon(Icons.refresh),
                label: const Text('Rivendos'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RrjedhaUjitOverlay extends StatelessWidget {
  final double progresi;
  final double rrjedhaUjit;

  const _RrjedhaUjitOverlay({
    required this.progresi,
    required this.rrjedhaUjit,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        // Pozicionim i përafërt që zakonisht funksionon mirë mbi skenën ekzistuese.
        // Mund ta rregullosh pak më vonë vetëm nëse do që të përputhet 100% me painter-in.
        final left = w * 0.09;
        final top = h * 0.12;
        final width = w * 0.24;
        final height = h * 0.56;

        final intensiteti = rrjedhaUjit.clamp(0.0, 1.0);
        final opacityBase = 0.18 + (0.35 * intensiteti);
        final rippleOpacity = 0.10 + (0.28 * intensiteti);

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
              child: CustomPaint(
                painter: _PiktoriRrjedhesSeUjit(
                  progresi: progresi,
                  intensiteti: intensiteti,
                  opacityBase: opacityBase,
                ),
              ),
            ),

            Positioned(
              left: left + width * 0.08,
              top: top + height * 0.80,
              width: width * 1.05,
              height: h * 0.16,
              child: CustomPaint(
                painter: _PiktoriRipple(
                  progresi: progresi,
                  intensiteti: intensiteti,
                  opacityBase: rippleOpacity,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PiktoriRrjedhesSeUjit extends CustomPainter {
  final double progresi;
  final double intensiteti;
  final double opacityBase;

  const _PiktoriRrjedhesSeUjit({
    required this.progresi,
    required this.intensiteti,
    required this.opacityBase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensiteti <= 0.001) return;

    final rect = Offset.zero & size;
    final radius = Radius.circular(size.width * 0.18);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    canvas.save();
    canvas.clipRRect(rrect);

    // Bazë e ujit
    final paintBase = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.lightBlueAccent.withOpacity(0.18 + 0.18 * intensiteti),
          Colors.blue.withOpacity(0.12 + 0.22 * intensiteti),
          Colors.blue.shade700.withOpacity(0.18 + 0.24 * intensiteti),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paintBase);

    // Shirita që lëvizin poshtë për ndjesi më reale të rrjedhës
    final stripeCount = 8 + (intensiteti * 8).round();
    for (int i = 0; i < stripeCount; i++) {
      final phase = (progresi + i * 0.13) % 1.0;
      final y = lerpDouble(-size.height * 0.35, size.height * 1.1, phase);
      final stripeHeight = size.height * (0.10 + 0.05 * (i % 3));
      final stripeRect = Rect.fromLTWH(
        0,
        y,
        size.width,
        stripeHeight,
      );

      final stripePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(opacityBase * 0.35),
            Colors.white.withOpacity(opacityBase * 0.05),
            Colors.transparent,
          ],
        ).createShader(stripeRect);

      canvas.drawRect(stripeRect, stripePaint);
    }

    // Vala anësore për të mos u dukur si bllok statik
    final path = Path();
    final amplitude = size.width * (0.04 + intensiteti * 0.03);
    final waveCount = 3.0;
    final shift = progresi * math.pi * 2;

    path.moveTo(0, 0);
    for (double y = 0; y <= size.height; y += 4) {
      final nx = math.sin((y / size.height) * math.pi * 2 * waveCount + shift) *
          amplitude;
      path.lineTo(size.width * 0.18 + nx, y);
    }
    path.lineTo(0, size.height);
    path.close();

    final sidePaint = Paint()
      ..color = Colors.white.withOpacity(opacityBase * 0.22);
    canvas.drawPath(path, sidePaint);

    // Disa pika të vogla uji
    final pikaPaint = Paint()
      ..color = Colors.white.withOpacity(0.28 + 0.20 * intensiteti);

    final pikaCount = 12 + (intensiteti * 14).round();
    for (int i = 0; i < pikaCount; i++) {
      final localPhase = (progresi * (1.0 + (i % 4) * 0.12) + i * 0.09) % 1.0;
      final dy = localPhase * size.height;
      final dx = size.width * (0.25 + 0.5 * ((i * 37) % 100) / 100);
      final r = size.width * (0.010 + ((i % 3) * 0.004));
      canvas.drawCircle(Offset(dx, dy), r, pikaPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PiktoriRrjedhesSeUjit oldDelegate) {
    return oldDelegate.progresi != progresi ||
        oldDelegate.intensiteti != intensiteti ||
        oldDelegate.opacityBase != opacityBase;
  }
}

class _PiktoriRipple extends CustomPainter {
  final double progresi;
  final double intensiteti;
  final double opacityBase;

  const _PiktoriRipple({
    required this.progresi,
    required this.intensiteti,
    required this.opacityBase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensiteti <= 0.001) return;

    final center = Offset(size.width * 0.42, size.height * 0.45);

    for (int i = 0; i < 3; i++) {
      final t = ((progresi + i * 0.28) % 1.0);
      final radiusX = size.width * (0.10 + t * 0.42);
      final radiusY = size.height * (0.04 + t * 0.18);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 - (t * 0.6)
        ..color = Colors.lightBlueAccent.withOpacity(
          (1 - t) * opacityBase,
        );

      final rect = Rect.fromCenter(
        center: center,
        width: radiusX * 2,
        height: radiusY * 2,
      );
      canvas.drawOval(rect, paint);
    }

    // Shkumë e lehtë pranë goditjes së ujit
    final foamPaint = Paint()
      ..color = Colors.white.withOpacity(0.16 + 0.18 * intensiteti);

    for (int i = 0; i < 6; i++) {
      final t = ((progresi * 1.2) + i * 0.17) % 1.0;
      final dx = size.width * (0.18 + 0.48 * t);
      final dy = size.height * (0.40 + 0.10 * math.sin(t * math.pi * 2));
      final r = size.height * (0.010 + (i % 3) * 0.006);
      canvas.drawCircle(Offset(dx, dy), r, foamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PiktoriRipple oldDelegate) {
    return oldDelegate.progresi != progresi ||
        oldDelegate.intensiteti != intensiteti ||
        oldDelegate.opacityBase != opacityBase;
  }
}

double lerpDouble(num a, num b, double t) {
  return a + (b - a) * t;
}