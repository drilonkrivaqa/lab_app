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
  late final AnimationController _zbehjeController;

  double magnetX = -120;
  double forcaInduksionit = 0;
  DateTime? _kohaFundit;

  double get _afersia => (1 - ((magnetX - 90).abs() / 260)).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _vizualController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _zbehjeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))
      ..addListener(() {
        setState(() {
          forcaInduksionit = (forcaInduksionit * (1 - _zbehjeController.value)).clamp(0.0, 1.0);
        });
      });
  }

  @override
  void dispose() {
    _vizualController.dispose();
    _zbehjeController.dispose();
    super.dispose();
  }

  void _nisTerheqjen(DragStartDetails _) {
    _kohaFundit = DateTime.now();
    _zbehjeController.stop();
  }

  void _levizMagnetin(DragUpdateDetails details) {
    final tani = DateTime.now();
    final dtMs = (_kohaFundit == null) ? 16 : tani.difference(_kohaFundit!).inMilliseconds.clamp(1, 50);
    _kohaFundit = tani;

    final xRi = (magnetX + details.delta.dx).clamp(-150.0, 150.0);
    final shpejtesia = (details.delta.dx.abs() / dtMs) * 1000;
    final afersia = (1 - ((xRi - 90).abs() / 260)).clamp(0.0, 1.0);
    final fuqi = InduksionModel.llogaritFuqine(shpejtesia: shpejtesia, largesiaNorm: 1 - afersia);

    setState(() {
      magnetX = xRi;
      forcaInduksionit = fuqi;
    });
  }

  void _ndaloTerheqjen([DragEndDetails? _]) {
    _zbehjeController
      ..reset()
      ..forward();
  }

  void _ndaloTerheqjenPaDetaje() {
    _ndaloTerheqjen();
  }

  void _rivendos() {
    _zbehjeController.stop();
    setState(() {
      magnetX = -120;
      forcaInduksionit = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final llambaNdezur = forcaInduksionit > 0.05;

    return Column(
      children: [
        Expanded(
          child: Kartela(
            child: GestureDetector(
              onPanStart: _nisTerheqjen,
              onPanUpdate: _levizMagnetin,
              onPanEnd: _ndaloTerheqjen,
              onPanCancel: _ndaloTerheqjenPaDetaje,
              child: AnimatedBuilder(
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
            ),
          ),
        ),
        Kartela(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Si përdoret', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Tërhiq magnetin majtas-djathtas. Llamba ndizet vetëm gjatë lëvizjes pranë spiralës.'),
              const SizedBox(height: 16),
              InfoRresht(etiketa: 'Gjendja e llambës', vlera: llambaNdezur ? 'Ndezur' : 'Fikur'),
              const SizedBox(height: 6),
              InfoRresht(etiketa: 'Forca e induksionit', vlera: forcaInduksionit.toStringAsFixed(2)),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: _rivendos, icon: const Icon(Icons.refresh), label: const Text('Rivendos')),
            ],
          ),
        ),
      ],
    );
  }
}

