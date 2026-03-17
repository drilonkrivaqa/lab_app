import 'package:flutter/material.dart';

import '../painters/circuit_painter.dart';
import '../widgets/common_widgets.dart';

class FaqjaQarku extends StatefulWidget {
  const FaqjaQarku({super.key});

  @override
  State<FaqjaQarku> createState() => _FaqjaQarkuState();
}

class _FaqjaQarkuState extends State<FaqjaQarku>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrolleri;

  bool qarkuMbyllur = true;
  double tensioni = 9;
  double rezistenca = 6;

  double get rryma => rezistenca == 0 ? 0 : tensioni / rezistenca;
  double get fuqia => qarkuMbyllur ? tensioni * rryma : 0.0;
  double get ndricimi =>
      qarkuMbyllur ? (rryma / 4.5).clamp(0.0, 1.0) : 0.0;

  String get gjendjaLlambes {
    if (!qarkuMbyllur) return 'Fikur';
    if (ndricimi < 0.2) return 'Shumë e zbehtë';
    if (ndricimi < 0.5) return 'E zbehtë';
    if (ndricimi < 0.8) return 'Mesatare';
    return 'Shumë e ndritshme';
  }

  Color get ngjyraGjendjes {
    if (!qarkuMbyllur) return Colors.grey;
    if (ndricimi < 0.2) return Colors.blueGrey;
    if (ndricimi < 0.5) return Colors.orange;
    if (ndricimi < 0.8) return Colors.deepOrange;
    return Colors.amber;
  }

  @override
  void initState() {
    super.initState();
    _kontrolleri = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _sinkronizoAnimacionin();
  }

  void _sinkronizoAnimacionin() {
    if (qarkuMbyllur) {
      _kontrolleri.repeat();
    } else {
      _kontrolleri.stop();
    }
  }

  @override
  void dispose() {
    _kontrolleri.dispose();
    super.dispose();
  }

  void _rivendos() {
    setState(() {
      qarkuMbyllur = true;
      tensioni = 9;
      rezistenca = 6;
      _sinkronizoAnimacionin();
    });
  }

  void _vendosPresetin({
    required double tension,
    required double resistance,
    required bool closed,
  }) {
    setState(() {
      tensioni = tension;
      rezistenca = resistance;
      qarkuMbyllur = closed;
      _sinkronizoAnimacionin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final skema = tema.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final lartesiaSimulimit = (constraints.maxHeight * 0.42).clamp(
          260.0,
          520.0,
        );

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
                      _PaneliSiperm(
                        qarkuMbyllur: qarkuMbyllur,
                        gjendjaLlambes: gjendjaLlambes,
                        ngjyraGjendjes: ngjyraGjendjes,
                        rryma: rryma,
                        tensioni: tensioni,
                        rezistenca: rezistenca,
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
                          child: RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _kontrolleri,
                              builder: (context, _) => CustomPaint(
                                painter: PiktoriQarku(
                                  progresi: _kontrolleri.value,
                                  qarkuMbyllur: qarkuMbyllur,
                                  ndricimi: ndricimi,
                                  rryma: rryma,
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MesazhDidaktik(
                        qarkuMbyllur: qarkuMbyllur,
                        tensioni: tensioni,
                        rezistenca: rezistenca,
                        rryma: rryma,
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
                      'Kontrollat e qarkut',
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ndrysho tensionin dhe rezistencën për të parë si ndryshon rryma dhe ndriçimi i llambës.',
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mbylle qarkun'),
                      subtitle: Text(
                        qarkuMbyllur
                            ? 'Rryma po kalon nëpër qark'
                            : 'Qarku është i hapur, rryma nuk kalon',
                      ),
                      value: qarkuMbyllur,
                      onChanged: (v) {
                        setState(() {
                          qarkuMbyllur = v;
                          _sinkronizoAnimacionin();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shembuj të shpejtë',
                      style: tema.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PresetButon(
                          etiketa: 'Bazik',
                          onTap: () => _vendosPresetin(
                            tension: 9,
                            resistance: 6,
                            closed: true,
                          ),
                        ),
                        _PresetButon(
                          etiketa: 'Më i ndritshëm',
                          onTap: () => _vendosPresetin(
                            tension: 18,
                            resistance: 4,
                            closed: true,
                          ),
                        ),
                        _PresetButon(
                          etiketa: 'Më i dobët',
                          onTap: () => _vendosPresetin(
                            tension: 6,
                            resistance: 12,
                            closed: true,
                          ),
                        ),
                        _PresetButon(
                          etiketa: 'Qark i hapur',
                          onTap: () => _vendosPresetin(
                            tension: 9,
                            resistance: 6,
                            closed: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _BllokuSlider(
                      titulli: 'Tensioni',
                      vleraTekst: '${tensioni.toStringAsFixed(0)} V',
                      ikona: Icons.battery_charging_full_rounded,
                      femija: Slider(
                        value: tensioni,
                        min: 1,
                        max: 24,
                        divisions: 23,
                        label: '${tensioni.toStringAsFixed(0)} V',
                        onChanged: (v) => setState(() => tensioni = v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BllokuSlider(
                      titulli: 'Rezistenca',
                      vleraTekst: '${rezistenca.toStringAsFixed(0)} Ω',
                      ikona: Icons.settings_input_component_rounded,
                      femija: Slider(
                        value: rezistenca,
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: '${rezistenca.toStringAsFixed(0)} Ω',
                        onChanged: (v) => setState(() => rezistenca = v),
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
                            etiketa: 'Rryma',
                            vlera: '${rryma.toStringAsFixed(2)} A',
                            ikona: Icons.bolt_rounded,
                          ),
                        ),
                        SizedBox(
                          width: _gjeresiaKarteles(constraints.maxWidth),
                          child: _VlereKartela(
                            etiketa: 'Fuqia',
                            vlera: '${fuqia.toStringAsFixed(2)} W',
                            ikona: Icons.flash_on_rounded,
                          ),
                        ),
                        SizedBox(
                          width: _gjeresiaKarteles(constraints.maxWidth),
                          child: _VlereKartela(
                            etiketa: 'Llamba',
                            vlera: gjendjaLlambes,
                            ikona: Icons.lightbulb_rounded,
                            accent: ngjyraGjendjes,
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

class _PaneliSiperm extends StatelessWidget {
  final bool qarkuMbyllur;
  final String gjendjaLlambes;
  final Color ngjyraGjendjes;
  final double rryma;
  final double tensioni;
  final double rezistenca;

  const _PaneliSiperm({
    required this.qarkuMbyllur,
    required this.gjendjaLlambes,
    required this.ngjyraGjendjes,
    required this.rryma,
    required this.tensioni,
    required this.rezistenca,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final skema = tema.colorScheme;

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
            ikona: qarkuMbyllur
                ? Icons.toggle_on_rounded
                : Icons.toggle_off_rounded,
            etiketa: qarkuMbyllur ? 'Qark i mbyllur' : 'Qark i hapur',
            ngjyra: qarkuMbyllur ? Colors.green : Colors.grey,
          ),
          _StatusChip(
            ikona: Icons.lightbulb_rounded,
            etiketa: gjendjaLlambes,
            ngjyra: ngjyraGjendjes,
          ),
          _StatusChip(
            ikona: Icons.bolt_rounded,
            etiketa: '${rryma.toStringAsFixed(2)} A',
            ngjyra: Colors.blue,
          ),
          _StatusChip(
            ikona: Icons.battery_charging_full_rounded,
            etiketa: '${tensioni.toStringAsFixed(0)} V',
            ngjyra: Colors.deepPurple,
          ),
          _StatusChip(
            ikona: Icons.settings_input_component_rounded,
            etiketa: '${rezistenca.toStringAsFixed(0)} Ω',
            ngjyra: Colors.teal,
          ),
        ],
      ),
    );
  }
}

class _MesazhDidaktik extends StatelessWidget {
  final bool qarkuMbyllur;
  final double tensioni;
  final double rezistenca;
  final double rryma;

  const _MesazhDidaktik({
    required this.qarkuMbyllur,
    required this.tensioni,
    required this.rezistenca,
    required this.rryma,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final skema = tema.colorScheme;

    String mesazhi;
    if (!qarkuMbyllur) {
      mesazhi =
      'Qarku është i hapur, prandaj nuk ka rrjedhje të rrymës dhe llamba qëndron e fikur.';
    } else if (rryma < 1) {
      mesazhi =
      'Rryma është e ulët. Provo të rrisësh tensionin ose të ulësh rezistencën që llamba të ndriçojë më shumë.';
    } else if (rryma < 2.5) {
      mesazhi =
      'Qarku po punon normalisht. Ndrysho vlerat për të parë si ndikon ligji i Ohmit në ndriçim.';
    } else {
      mesazhi =
      'Rryma është e lartë. Llamba ndriçon fort sepse tensioni është i lartë ose rezistenca është e vogël.';
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

class _PresetButon extends StatelessWidget {
  final String etiketa;
  final VoidCallback onTap;

  const _PresetButon({
    required this.etiketa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(etiketa),
      onPressed: onTap,
      avatar: const Icon(Icons.tune_rounded, size: 18),
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