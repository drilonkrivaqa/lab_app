import 'package:flutter/material.dart';

import '../painters/circuit_painter.dart';

class FaqjaQarku extends StatefulWidget {
  const FaqjaQarku({super.key});

  @override
  State<FaqjaQarku> createState() => _FaqjaQarkuState();
}

class _FaqjaQarkuState extends State<FaqjaQarku>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool qarkuMbyllur = true;
  double tensioni = 9;
  double rezistenca = 6;

  double get rryma => qarkuMbyllur ? tensioni / rezistenca : 0.0;

  double get ndricimi {
    if (!qarkuMbyllur) return 0.0;
    return (rryma / 3.0).clamp(0.0, 1.0);
  }

  double get shpejtesiaNgarkesave {
    if (!qarkuMbyllur) return 0.0;

    // Baza fizike e thjeshtuar:
    // më shumë tension -> më shpejt
    // më shumë rezistencë -> më ngadalë
    final speed = (tensioni / rezistenca) / 3.0;
    return speed.clamp(0.08, 1.0);
  }

  String get pershkrimiShpejtesise {
    if (!qarkuMbyllur) return 'Zero';
    if (shpejtesiaNgarkesave < 0.22) return 'Shumë e ngadaltë';
    if (shpejtesiaNgarkesave < 0.45) return 'E ngadaltë';
    if (shpejtesiaNgarkesave < 0.72) return 'Mesatare';
    return 'E shpejtë';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 360,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: PiktoriQarku(
                          progresi: _controller.value,
                          qarkuMbyllur: qarkuMbyllur,
                          ndricimi: ndricimi,
                          rryma: rryma,
                          tensioni: tensioni,
                          rezistenca: rezistenca,
                          shpejtesiaNgarkesave: shpejtesiaNgarkesave,
                        ),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  qarkuMbyllur
                      ? 'Qarku është i mbyllur — ngarkesat lëvizin dhe llamba ndizet.'
                      : 'Qarku është i hapur — ngarkesat nuk lëvizin dhe llamba fiket.',
                  style: tema.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mbyll qarkun'),
                  subtitle: Text(qarkuMbyllur ? 'ON' : 'OFF'),
                  value: qarkuMbyllur,
                  onChanged: (value) {
                    setState(() {
                      qarkuMbyllur = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Tensioni: ${tensioni.toStringAsFixed(0)} V',
                  style: tema.textTheme.titleSmall,
                ),
                Slider(
                  value: tensioni,
                  min: 1,
                  max: 24,
                  divisions: 23,
                  label: '${tensioni.toStringAsFixed(0)} V',
                  onChanged: (v) {
                    setState(() {
                      tensioni = v;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Rezistenca: ${rezistenca.toStringAsFixed(0)} Ω',
                  style: tema.textTheme.titleSmall,
                ),
                Slider(
                  value: rezistenca,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '${rezistenca.toStringAsFixed(0)} Ω',
                  onChanged: (v) {
                    setState(() {
                      rezistenca = v;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoBox(
                      title: 'Rryma',
                      value: '${rryma.toStringAsFixed(2)} A',
                    ),
                    _InfoBox(
                      title: 'Llamba',
                      value: ndricimi == 0
                          ? 'Fikur'
                          : ndricimi < 0.35
                          ? 'E dobët'
                          : ndricimi < 0.7
                          ? 'Mesatare'
                          : 'E fortë',
                    ),
                    _InfoBox(
                      title: 'Shpejtësia',
                      value: pershkrimiShpejtesise,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}