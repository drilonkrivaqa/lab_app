import 'package:flutter/material.dart';

import '../painters/hydro_painter.dart';
import '../simulations/hydro_model.dart';
import '../widgets/common_widgets.dart';

class FaqjaGjeneratoriUjit extends StatefulWidget {
  const FaqjaGjeneratoriUjit({super.key});

  @override
  State<FaqjaGjeneratoriUjit> createState() => _FaqjaGjeneratoriUjitState();
}

class _FaqjaGjeneratoriUjitState extends State<FaqjaGjeneratoriUjit> with SingleTickerProviderStateMixin {
  late final AnimationController _kontrolleri;

  bool gjeneratoriAktiv = true;
  double rrjedhaUjit = 0.7;
  double bateria = 0.0;
  Duration _kohaFundit = Duration.zero;

  @override
  void initState() {
    super.initState();
    _kontrolleri = AnimationController(vsync: this, duration: const Duration(seconds: 2))
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

    return Column(
      children: [
        Expanded(
          child: Kartela(
            child: AnimatedBuilder(
              animation: _kontrolleri,
              builder: (context, _) => CustomPaint(
                painter: PiktoriGjeneratorit(
                  progresi: _kontrolleri.value,
                  rrjedhaUjit: gjeneratoriAktiv ? rrjedhaUjit : 0,
                  bateria: bateria,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        Kartela(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gjeneratori me Ujë', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Aktivizo gjeneratorin'),
                value: gjeneratoriAktiv,
                onChanged: (v) => setState(() => gjeneratoriAktiv = v),
              ),
              Text('Rrjedha e ujit: ${(rrjedhaUjit * 100).toStringAsFixed(0)}%'),
              Slider(value: rrjedhaUjit, min: 0.1, max: 1.0, onChanged: (v) => setState(() => rrjedhaUjit = v)),
              const Divider(height: 24),
              InfoRresht(etiketa: 'Ngarkesa e baterisë', vlera: '${(bateria * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: 6),
              InfoRresht(etiketa: 'Llamba', vlera: llambaNdezur ? 'Ndezur' : 'Fikur'),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: _rivendos, icon: const Icon(Icons.refresh), label: const Text('Rivendos')),
            ],
          ),
        ),
      ],
    );
  }
}
