import 'package:flutter/material.dart';

import '../painters/circuit_painter.dart';
import '../widgets/common_widgets.dart';

class FaqjaQarku extends StatefulWidget {
  const FaqjaQarku({super.key});

  @override
  State<FaqjaQarku> createState() => _FaqjaQarkuState();
}

class _FaqjaQarkuState extends State<FaqjaQarku> with SingleTickerProviderStateMixin {
  late final AnimationController _kontrolleri;

  bool qarkuMbyllur = true;
  double tensioni = 9;
  double rezistenca = 6;

  double get rryma => rezistenca == 0 ? 0 : tensioni / rezistenca;
  double get fuqia => tensioni * rryma;
  double get ndricimi => qarkuMbyllur ? (rryma / 4.5).clamp(0.0, 1.0) : 0.0;

  @override
  void initState() {
    super.initState();
    _kontrolleri = AnimationController(vsync: this, duration: const Duration(seconds: 3));
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Kartela(
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
        Kartela(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kontrollat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mbylle qarkun'),
                value: qarkuMbyllur,
                onChanged: (v) => setState(() {
                  qarkuMbyllur = v;
                  _sinkronizoAnimacionin();
                }),
              ),
              Text('Tensioni: ${tensioni.toStringAsFixed(0)} V'),
              Slider(value: tensioni, min: 1, max: 24, divisions: 23, onChanged: (v) => setState(() => tensioni = v)),
              Text('Rezistenca: ${rezistenca.toStringAsFixed(0)} Ω'),
              Slider(value: rezistenca, min: 1, max: 20, divisions: 19, onChanged: (v) => setState(() => rezistenca = v)),
              const Divider(height: 24),
              InfoRresht(etiketa: 'Rryma', vlera: '${rryma.toStringAsFixed(2)} A'),
              const SizedBox(height: 6),
              InfoRresht(etiketa: 'Fuqia', vlera: '${fuqia.toStringAsFixed(2)} W'),
              const SizedBox(height: 6),
              InfoRresht(etiketa: 'Llamba', vlera: qarkuMbyllur ? 'Ndezur' : 'Fikur'),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: _rivendos, icon: const Icon(Icons.refresh), label: const Text('Rivendos')),
            ],
          ),
        ),
      ],
    );
  }
}
