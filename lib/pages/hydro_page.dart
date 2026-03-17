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
  double _progresiVizual = 0.0;

  double get _rrjedhaEfektive => gjeneratoriAktiv ? rrjedhaUjit : 0.0;

  @override
  void initState() {
    super.initState();

    // Controller is now only a steady heartbeat for simulation updates.
    // This keeps battery draining even when water flow becomes 0.
    _kontrolleri = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_perditesoSimulimin);

    _kontrolleri.repeat();
  }

  void _perditesoSimulimin() {
    final koha = _kontrolleri.lastElapsedDuration ?? Duration.zero;
    final dt = (koha - _kohaFundit).inMicroseconds / 1e6;
    _kohaFundit = koha;
    if (dt <= 0) return;

    final rrjedhaEfektive = _rrjedhaEfektive;

    final bateriaRe = HidroModel.ndryshoNgarkesen(
      aktuale: bateria,
      aktiv: gjeneratoriAktiv,
      rrjedha: rrjedhaUjit,
      dt: dt,
    );

    // Visual wheel/water progress is advanced manually based on real water flow.
    // When there is no flow, progress stops, so the wheel stays stationary.
    final shpejtesiaRrotes = 0.15 + (rrjedhaEfektive * 1.85);
    if (rrjedhaEfektive > 0.001) {
      _progresiVizual = (_progresiVizual + dt * shpejtesiaRrotes) % 1.0;
    }

    final kaNdryshimBaterie = (bateriaRe - bateria).abs() > 0.0005;

    if ((kaNdryshimBaterie || rrjedhaEfektive > 0.001) && mounted) {
      setState(() {
        bateria = bateriaRe;
      });
    } else if (kaNdryshimBaterie && mounted) {
      setState(() {
        bateria = bateriaRe;
      });
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
      _progresiVizual = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final skema = tema.colorScheme;
    final llambaNdezur = bateria >= 0.35;
    final rrjedhaEfektive = _rrjedhaEfektive;

    return LayoutBuilder(
      builder: (context, constraints) {
        final lartesiaSimulimit =
        (constraints.maxHeight * 0.42).clamp(260.0, 520.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Kartela(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PaneliGjendjes(
                        gjeneratoriAktiv: gjeneratoriAktiv,
                        rrjedhaUjit: rrjedhaEfektive,
                        bateria: bateria,
                        llambaNdezur: llambaNdezur,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: lartesiaSimulimit,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: skema.surfaceContainerHighest.withOpacity(0.35),
                          border: Border.all(
                            color: skema.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedBuilder(
                            animation: _kontrolleri,
                            builder: (context, _) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  CustomPaint(
                                    painter: PiktoriGjeneratorit(
                                      progresi: _progresiVizual,
                                      rrjedhaUjit: 0.0,
                                      bateria: bateria,
                                    ),
                                    child: const SizedBox.expand(),
                                  ),

                                  // Mask old rectangular waterfall visuals that may
                                  // still be drawn inside hydro_painter.
                                  IgnorePointer(
                                    child: _MbulesaRrjedhesSeVjeter(
                                      backgroundColor: skema
                                          .surfaceContainerHighest
                                          .withOpacity(0.35),
                                    ),
                                  ),

                                  IgnorePointer(
                                    child: _RrjedhaUjitOverlay(
                                      progresi: _progresiVizual,
                                      rrjedhaUjit: rrjedhaEfektive,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MesazhDidaktikHidro(
                        gjeneratoriAktiv: gjeneratoriAktiv,
                        rrjedhaUjit: rrjedhaEfektive,
                        bateria: bateria,
                      ),
                    ],
                  ),
                ),
              ),
              Kartela(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gjeneratori me Ujë',
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Aktivizo gjeneratorin dhe ndrysho rrjedhën e ujit për të parë si ngarkohet bateria dhe ndizet llamba.',
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Aktivizo gjeneratorin'),
                      subtitle: Text(
                        gjeneratoriAktiv
                            ? 'Uji po lëviz sistemin dhe po ngarkon baterinë'
                            : 'Gjeneratori është ndalur',
                      ),
                      value: gjeneratoriAktiv,
                      onChanged: (v) {
                        setState(() {
                          gjeneratoriAktiv = v;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _BllokuSlider(
                      titulli: 'Rrjedha e ujit',
                      vleraTekst:
                      '${(rrjedhaUjit * 100).toStringAsFixed(0)}%',
                      ikona: Icons.water_drop_rounded,
                      femija: Slider(
                        value: rrjedhaUjit,
                        min: 0.0,
                        max: 1.0,
                        divisions: 20,
                        label: '${(rrjedhaUjit * 100).toStringAsFixed(0)}%',
                        onChanged: (v) {
                          setState(() {
                            rrjedhaUjit = v;
                          });
                        },
                      ),
                    ),
                    const Divider(height: 26),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: _gjeresiaKarteles(constraints.maxWidth),
                          child: _VlereKartela(
                            etiketa: 'Ngarkesa e baterisë',
                            vlera: '${(bateria * 100).toStringAsFixed(0)}%',
                            ikona: Icons.battery_charging_full_rounded,
                            accent: Colors.green,
                          ),
                        ),
                        SizedBox(
                          width: _gjeresiaKarteles(constraints.maxWidth),
                          child: _VlereKartela(
                            etiketa: 'Llamba',
                            vlera: llambaNdezur ? 'Ndezur' : 'Fikur',
                            ikona: Icons.lightbulb_rounded,
                            accent: llambaNdezur ? Colors.amber : Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: _gjeresiaKarteles(constraints.maxWidth),
                          child: _VlereKartela(
                            etiketa: 'Gjeneratori',
                            vlera: gjeneratoriAktiv ? 'Aktiv' : 'Jo aktiv',
                            ikona: Icons.settings_rounded,
                            accent:
                            gjeneratoriAktiv ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _rivendos,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Rivendos'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _gjeresiaKarteles(double maxWidth) {
    if (maxWidth >= 1100) return (maxWidth - 52) / 3;
    if (maxWidth >= 700) return (maxWidth - 42) / 2;
    return maxWidth - 24;
  }
}

class _PaneliGjendjes extends StatelessWidget {
  final bool gjeneratoriAktiv;
  final double rrjedhaUjit;
  final double bateria;
  final bool llambaNdezur;

  const _PaneliGjendjes({
    required this.gjeneratoriAktiv,
    required this.rrjedhaUjit,
    required this.bateria,
    required this.llambaNdezur,
  });

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: skema.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: skema.outlineVariant.withOpacity(0.45)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _StatusChip(
            ikona: gjeneratoriAktiv
                ? Icons.play_circle_fill_rounded
                : Icons.pause_circle_filled_rounded,
            etiketa:
            gjeneratoriAktiv ? 'Gjenerator aktiv' : 'Gjenerator i ndalur',
            ngjyra: gjeneratoriAktiv ? Colors.green : Colors.grey,
          ),
          _StatusChip(
            ikona: Icons.water_drop_rounded,
            etiketa: 'Rrjedha ${(rrjedhaUjit * 100).toStringAsFixed(0)}%',
            ngjyra: Colors.lightBlue,
          ),
          _StatusChip(
            ikona: Icons.battery_charging_full_rounded,
            etiketa: 'Bateria ${(bateria * 100).toStringAsFixed(0)}%',
            ngjyra: Colors.teal,
          ),
          _StatusChip(
            ikona: Icons.lightbulb_rounded,
            etiketa: llambaNdezur ? 'Llamba ndezur' : 'Llamba fikur',
            ngjyra: llambaNdezur ? Colors.amber : Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _MesazhDidaktikHidro extends StatelessWidget {
  final bool gjeneratoriAktiv;
  final double rrjedhaUjit;
  final double bateria;

  const _MesazhDidaktikHidro({
    required this.gjeneratoriAktiv,
    required this.rrjedhaUjit,
    required this.bateria,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final skema = tema.colorScheme;

    String mesazhi;
    if (!gjeneratoriAktiv) {
      mesazhi =
      'Gjeneratori është i ndalur. Pa rrjedhje aktive të ujit, bateria nuk vazhdon të ngarkohet.';
    } else if (rrjedhaUjit <= 0.001) {
      mesazhi =
      'Nuk ka rrjedhje uji. Prandaj rrota qëndron e palëvizshme dhe bateria fillon të zbrazet gradualisht.';
    } else if (rrjedhaUjit < 0.3) {
      mesazhi =
      'Rrjedha e ujit është e vogël. Provo ta rrisësh që bateria të ngarkohet më shpejt.';
    } else if (bateria < 0.35) {
      mesazhi =
      'Sistemi po punon. Uji po lëviz turbinën dhe bateria po grumbullon energji.';
    } else {
      mesazhi =
      'Bateria ka arritur nivel të mjaftueshëm dhe llamba ndizet falë energjisë së prodhuar nga uji.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: skema.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.school_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mesazhi,
              style: tema.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _MbulesaRrjedhesSeVjeter extends StatelessWidget {
  final Color backgroundColor;

  const _MbulesaRrjedhesSeVjeter({
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        return Stack(
          children: [
            Positioned(
              left: w * 0.055,
              top: h * 0.08,
              width: w * 0.22,
              height: h * 0.70,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ],
        );
      },
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

    final stripeCount = 8 + (intensiteti * 8).round();
    for (int i = 0; i < stripeCount; i++) {
      final phase = (progresi + i * 0.13) % 1.0;
      final y = lerpDouble(-size.height * 0.35, size.height * 1.1, phase);
      final stripeHeight = size.height * (0.10 + 0.05 * (i % 3));
      final stripeRect = Rect.fromLTWH(0, y, size.width, stripeHeight);

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

    final path = Path();
    final amplitude = size.width * (0.04 + intensiteti * 0.03);
    final waveCount = 3.0;
    final shift = progresi * math.pi * 2;

    path.moveTo(0, 0);
    for (double y = 0; y <= size.height; y += 4) {
      final nx =
          math.sin((y / size.height) * math.pi * 2 * waveCount + shift) *
              amplitude;
      path.lineTo(size.width * 0.18 + nx, y);
    }
    path.lineTo(0, size.height);
    path.close();

    final sidePaint = Paint()
      ..color = Colors.white.withOpacity(opacityBase * 0.22);
    canvas.drawPath(path, sidePaint);

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
        ..color = Colors.lightBlueAccent.withOpacity((1 - t) * opacityBase);

      final rect = Rect.fromCenter(
        center: center,
        width: radiusX * 2,
        height: radiusY * 2,
      );
      canvas.drawOval(rect, paint);
    }

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

class _StatusChip extends StatelessWidget {
  final IconData ikona;
  final String etiketa;
  final Color ngjyra;

  const _StatusChip({
    required this.ikona,
    required this.etiketa,
    required this.ngjyra,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: ngjyra.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ngjyra.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikona, size: 18, color: ngjyra),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              etiketa,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ngjyra,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BllokuSlider extends StatelessWidget {
  final String titulli;
  final String vleraTekst;
  final IconData ikona;
  final Widget femija;

  const _BllokuSlider({
    required this.titulli,
    required this.vleraTekst,
    required this.ikona,
    required this.femija,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final skema = tema.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      decoration: BoxDecoration(
        color: skema.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: skema.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(ikona, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    titulli,
                    style: tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                vleraTekst,
                style: tema.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: femija,
          ),
        ],
      ),
    );
  }
}

class _VlereKartela extends StatelessWidget {
  final String etiketa;
  final String vlera;
  final IconData ikona;
  final Color? accent;

  const _VlereKartela({
    required this.etiketa,
    required this.vlera,
    required this.ikona,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final skema = tema.colorScheme;
    final ngjyra = accent ?? skema.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ngjyra.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ngjyra.withOpacity(0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ngjyra.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ikona, color: ngjyra),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiketa,
                  style: tema.textTheme.bodySmall,
                ),
                const SizedBox(height: 3),
                Text(
                  vlera,
                  softWrap: true,
                  style: tema.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ngjyra,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

double lerpDouble(num a, num b, double t) {
  return a + (b - a) * t;
}