import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const LaboratoriFizikesApp());
}

class LaboratoriFizikesApp extends StatelessWidget {
  const LaboratoriFizikesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laboratori i Fizikës',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const FaqjaKryesore(),
    );
  }
}

class FaqjaKryesore extends StatefulWidget {
  const FaqjaKryesore({super.key});

  @override
  State<FaqjaKryesore> createState() => _FaqjaKryesoreState();
}

class _FaqjaKryesoreState extends State<FaqjaKryesore> {
  int indeksi = 0;

  final faqet = const [
    FaqjaQarku(),
    FaqjaMagneti(),
    FaqjaKalkulatori(),
    FaqjaGjeneratoriUjit(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratori i Fizikës'),
        centerTitle: true,
      ),
      body: faqet[indeksi],
      bottomNavigationBar: NavigationBar(
        selectedIndex: indeksi,
        onDestinationSelected: (v) => setState(() => indeksi = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.electrical_services_outlined),
            selectedIcon: Icon(Icons.electrical_services),
            label: 'Qarku',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_input_component_outlined),
            selectedIcon: Icon(Icons.settings_input_component),
            label: 'Magneti',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Kalkulatori',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Gjeneratori',
          ),
        ],
      ),
    );
  }
}

class Kartela extends StatelessWidget {
  final Widget child;

  const Kartela({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class InfoRresht extends StatelessWidget {
  final String etiketa;
  final String vlera;

  const InfoRresht({
    super.key,
    required this.etiketa,
    required this.vlera,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            etiketa,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(vlera),
      ],
    );
  }
}

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
  double get fuqia => tensioni * rryma;
  double get ndricimi => qarkuMbyllur ? (rryma / 5).clamp(0.0, 1.0) : 0.0;

  @override
  void initState() {
    super.initState();
    _kontrolleri = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _rifillo();
  }

  void _rifillo() {
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
      _rifillo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Kartela(
            child: AnimatedBuilder(
              animation: _kontrolleri,
              builder: (context, _) {
                return CustomPaint(
                  painter: PiktoriQarku(
                    progresi: _kontrolleri.value,
                    qarkuMbyllur: qarkuMbyllur,
                    ndricimi: ndricimi,
                    rryma: rryma,
                  ),
                  child: const SizedBox.expand(),
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
                'Kontrollat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mbylle qarkun'),
                value: qarkuMbyllur,
                onChanged: (v) {
                  setState(() {
                    qarkuMbyllur = v;
                    _rifillo();
                  });
                },
              ),
              const SizedBox(height: 8),
              Text('Tensioni: ${tensioni.toStringAsFixed(0)} V'),
              Slider(
                value: tensioni,
                min: 1,
                max: 24,
                divisions: 23,
                onChanged: (v) => setState(() => tensioni = v),
              ),
              Text('Rezistenca: ${rezistenca.toStringAsFixed(0)} Ω'),
              Slider(
                value: rezistenca,
                min: 1,
                max: 20,
                divisions: 19,
                onChanged: (v) => setState(() => rezistenca = v),
              ),
              const Divider(height: 24),
              InfoRresht(
                etiketa: 'Rryma',
                vlera: '${rryma.toStringAsFixed(2)} A',
              ),
              const SizedBox(height: 6),
              InfoRresht(
                etiketa: 'Fuqia',
                vlera: '${fuqia.toStringAsFixed(2)} W',
              ),
              const SizedBox(height: 6),
              InfoRresht(
                etiketa: 'Llamba',
                vlera: qarkuMbyllur ? 'Ndezur' : 'Fikur',
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

class PiktoriQarku extends CustomPainter {
  final double progresi;
  final bool qarkuMbyllur;
  final double ndricimi;
  final double rryma;

  PiktoriQarku({
    required this.progresi,
    required this.qarkuMbyllur,
    required this.ndricimi,
    required this.rryma,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tel = Paint()
      ..color = Colors.black87
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final element = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final majtas = size.width * 0.14;
    final djathtas = size.width * 0.86;
    final lart = size.height * 0.22;
    final poshte = size.height * 0.78;
    final llambaQendra = Offset(djathtas, size.height * 0.50);
    final r = size.width * 0.065;

    canvas.drawLine(Offset(majtas, poshte), Offset(majtas, size.height * 0.62), tel);

    if (qarkuMbyllur) {
      canvas.drawLine(Offset(majtas, size.height * 0.48), Offset(majtas, lart), tel);
      canvas.drawLine(Offset(majtas, lart), Offset(size.width * 0.34, lart), tel);
    } else {
      canvas.drawLine(Offset(majtas, size.height * 0.48), Offset(majtas, size.height * 0.43), tel);
      canvas.drawLine(Offset(majtas, size.height * 0.43), Offset(majtas + 26, size.height * 0.36), tel);
      canvas.drawLine(Offset(majtas + 46, lart), Offset(size.width * 0.34, lart), tel);
    }

    final rezPath = Path()..moveTo(size.width * 0.34, lart);
    const zig = 6;
    final seg = (size.width * 0.54 - size.width * 0.34) / zig;
    bool up = true;
    for (int i = 0; i < zig; i++) {
      rezPath.lineTo(
        size.width * 0.34 + (i + 1) * seg,
        lart + (up ? -10 : 10),
      );
      up = !up;
    }
    canvas.drawPath(rezPath, element);

    canvas.drawLine(Offset(size.width * 0.54, lart), Offset(djathtas, lart), tel);
    canvas.drawLine(Offset(djathtas, lart), Offset(djathtas, llambaQendra.dy - r), tel);
    canvas.drawLine(Offset(djathtas, llambaQendra.dy + r), Offset(djathtas, poshte), tel);
    canvas.drawLine(Offset(djathtas, poshte), Offset(majtas, poshte), tel);

    canvas.drawLine(
      Offset(majtas - 10, size.height * 0.60),
      Offset(majtas - 10, size.height * 0.50),
      element,
    );
    canvas.drawLine(
      Offset(majtas + 10, size.height * 0.46),
      Offset(majtas + 10, size.height * 0.30),
      element,
    );

    if (ndricimi > 0) {
      final glow = Paint()
        ..color = Colors.amber.withOpacity(0.25 + ndricimi * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(llambaQendra, r + 16, glow);
    }

    canvas.drawCircle(
      llambaQendra,
      r,
      Paint()..color = Color.lerp(Colors.grey.shade300, Colors.yellow.shade600, ndricimi)!,
    );
    canvas.drawCircle(llambaQendra, r, element);

    if (qarkuMbyllur) {
      final pika = <Offset>[
        Offset(majtas, poshte),
        Offset(majtas, lart),
        Offset(djathtas, lart),
        Offset(djathtas, poshte),
      ];

      final nr = (8 + rryma * 2).clamp(8, 16).toInt();
      for (int i = 0; i < nr; i++) {
        final t = (progresi + i / nr) % 1.0;
        final p = _pikaNeRruge(pika, t);
        canvas.drawCircle(p, 4, Paint()..color = Colors.blueAccent);
      }
    }
  }

  Offset _pikaNeRruge(List<Offset> points, double t) {
    final a = points[0];
    final b = points[1];
    final c = points[2];
    final d = points[3];

    final lengths = [
      (b - a).distance,
      (c - b).distance,
      (d - c).distance,
      (a - d).distance,
    ];
    final total = lengths.reduce((x, y) => x + y);
    double target = t * total;

    if (target <= lengths[0]) return Offset.lerp(a, b, target / lengths[0])!;
    target -= lengths[0];
    if (target <= lengths[1]) return Offset.lerp(b, c, target / lengths[1])!;
    target -= lengths[1];
    if (target <= lengths[2]) return Offset.lerp(c, d, target / lengths[2])!;
    target -= lengths[2];
    return Offset.lerp(d, a, target / lengths[3])!;
  }

  @override
  bool shouldRepaint(covariant PiktoriQarku oldDelegate) {
    return oldDelegate.progresi != progresi ||
        oldDelegate.qarkuMbyllur != qarkuMbyllur ||
        oldDelegate.ndricimi != ndricimi ||
        oldDelegate.rryma != rryma;
  }
}

class FaqjaMagneti extends StatefulWidget {
  const FaqjaMagneti({super.key});

  @override
  State<FaqjaMagneti> createState() => _FaqjaMagnetiState();
}

class _FaqjaMagnetiState extends State<FaqjaMagneti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrolleri;

  double magnetX = -120;
  double magnetXMeparshem = -120;
  double forcaLevizjes = 0;
  Timer? _timerFikjes;

  @override
  void initState() {
    super.initState();
    _kontrolleri = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _timerFikjes?.cancel();
    _kontrolleri.dispose();
    super.dispose();
  }

  void _levizMagnetin(DragUpdateDetails details) {
    setState(() {
      magnetXMeparshem = magnetX;
      magnetX += details.delta.dx;
      magnetX = magnetX.clamp(-150, 150);

      final delta = (magnetX - magnetXMeparshem).abs();
      forcaLevizjes = (delta / 18).clamp(0.0, 1.0);
    });

    _timerFikjes?.cancel();
    _timerFikjes = Timer(const Duration(milliseconds: 220), () {
      if (mounted) {
        setState(() {
          forcaLevizjes = 0;
        });
      }
    });
  }

  void _rivendos() {
    setState(() {
      magnetX = -120;
      magnetXMeparshem = -120;
      forcaLevizjes = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final llambaNdezur = forcaLevizjes > 0.05;

    return Column(
      children: [
        Expanded(
          child: Kartela(
            child: GestureDetector(
              onPanUpdate: _levizMagnetin,
              child: AnimatedBuilder(
                animation: _kontrolleri,
                builder: (context, _) {
                  return CustomPaint(
                    painter: PiktoriMagneti(
                      progresi: _kontrolleri.value,
                      magnetX: magnetX,
                      niveliDrites: forcaLevizjes,
                    ),
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
          ),
        ),
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
                'Tërhiq magnetin majtas-djathtas. Llamba ndizet vetëm kur magneti lëviz.',
              ),
              const SizedBox(height: 16),
              InfoRresht(
                etiketa: 'Gjendja e llambës',
                vlera: llambaNdezur ? 'Ndezur' : 'Fikur',
              ),
              const SizedBox(height: 6),
              InfoRresht(
                etiketa: 'Forca e induksionit',
                vlera: forcaLevizjes.toStringAsFixed(2),
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

class PiktoriMagneti extends CustomPainter {
  final double progresi;
  final double magnetX;
  final double niveliDrites;

  PiktoriMagneti({
    required this.progresi,
    required this.magnetX,
    required this.niveliDrites,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final qendra = Offset(size.width / 2, size.height / 2);
    final qendraMagnetit = qendra + Offset(magnetX, 0);
    final qendraSpirales = qendra + const Offset(85, 0);
    final qendraLlambes = qendra + const Offset(150, -75);

    if (niveliDrites > 0) {
      for (int i = 0; i < 5; i++) {
        final rect = Rect.fromCenter(
          center: qendraMagnetit,
          width: 170 + i * 32 + math.sin(progresi * 2 * math.pi + i) * 6,
          height: 80 + i * 20,
        );
        final path = Path()
          ..addArc(rect, math.pi * 0.15, math.pi * 0.70)
          ..addArc(rect, math.pi * 1.15, math.pi * 0.70);

        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.blue.withOpacity((0.14 - i * 0.02).clamp(0.03, 0.14))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }

    _vizatoSpiralen(canvas, qendraSpirales);
    _vizatoLlamben(canvas, qendraLlambes, niveliDrites);
    _vizatoTelat(canvas, qendraSpirales, qendraLlambes);
    _vizatoMagnetin(canvas, qendraMagnetit);
  }

  void _vizatoMagnetin(Canvas canvas, Offset c) {
    const w = 120.0;
    const h = 34.0;

    final majtas = Rect.fromCenter(center: c.translate(-w / 4, 0), width: w / 2, height: h);
    final djathtas = Rect.fromCenter(center: c.translate(w / 4, 0), width: w / 2, height: h);

    canvas.drawRRect(
      RRect.fromRectAndRadius(majtas, const Radius.circular(8)),
      Paint()..color = Colors.red.shade400,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(djathtas, const Radius.circular(8)),
      Paint()..color = Colors.blue.shade400,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: w, height: h),
        const Radius.circular(8),
      ),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _tekst(canvas, 'N', c.translate(-36, -8));
    _tekst(canvas, 'S', c.translate(24, -8));
  }

  void _vizatoSpiralen(Canvas canvas, Offset c) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final x = c.dx - 40 + i * 14.0;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, c.dy), width: 14, height: 52),
        paint,
      );
    }
  }

  void _vizatoTelat(Canvas canvas, Offset spiralja, Offset llamba) {
    final tel = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(spiralja.dx + 42, spiralja.dy), Offset(llamba.dx - 20, spiralja.dy), tel);
    canvas.drawLine(Offset(llamba.dx - 20, spiralja.dy), Offset(llamba.dx - 20, llamba.dy), tel);
    canvas.drawLine(Offset(spiralja.dx - 58, spiralja.dy), Offset(spiralja.dx - 90, spiralja.dy), tel);
    canvas.drawLine(Offset(spiralja.dx - 90, spiralja.dy), Offset(spiralja.dx - 90, llamba.dy + 14), tel);
    canvas.drawLine(Offset(spiralja.dx - 90, llamba.dy + 14), Offset(llamba.dx, llamba.dy + 14), tel);
  }

  void _vizatoLlamben(Canvas canvas, Offset c, double level) {
    final r = 16.0;

    if (level > 0) {
      final glow = Paint()
        ..color = Colors.amber.withOpacity(0.20 + level * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(c, 26, glow);
    }

    canvas.drawCircle(
      c,
      r,
      Paint()..color = Color.lerp(Colors.grey.shade300, Colors.yellow.shade600, level)!,
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _tekst(Canvas canvas, String text, Offset offset) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant PiktoriMagneti oldDelegate) {
    return oldDelegate.progresi != progresi ||
        oldDelegate.magnetX != magnetX ||
        oldDelegate.niveliDrites != niveliDrites;
  }
}

class FaqjaKalkulatori extends StatefulWidget {
  const FaqjaKalkulatori({super.key});

  @override
  State<FaqjaKalkulatori> createState() => _FaqjaKalkulatoriState();
}

class _FaqjaKalkulatoriState extends State<FaqjaKalkulatori> {
  final aController = TextEditingController();
  final bController = TextEditingController();

  String lloji = 'Ligji i Ohmit';
  String etiketaA = 'Tensioni (V)';
  String etiketaB = 'Rezistenca (Ω)';
  String rezultati = '-';

  @override
  void dispose() {
    aController.dispose();
    bController.dispose();
    super.dispose();
  }

  void _ndryshoLlojin(String value) {
    setState(() {
      lloji = value;
      aController.clear();
      bController.clear();
      rezultati = '-';

      if (lloji == 'Ligji i Ohmit') {
        etiketaA = 'Tensioni (V)';
        etiketaB = 'Rezistenca (Ω)';
      } else if (lloji == 'Fuqia elektrike') {
        etiketaA = 'Tensioni (V)';
        etiketaB = 'Rryma (A)';
      } else if (lloji == 'Induksioni magnetik') {
        etiketaA = 'Rryma (A)';
        etiketaB = 'Distanca (m)';
      } else {
        etiketaA = 'Dendësia e mbështjelljeve n';
        etiketaB = 'Rryma (A)';
      }
    });
  }

  void _llogarit() {
    final a = double.tryParse(aController.text.replaceAll(',', '.'));
    final b = double.tryParse(bController.text.replaceAll(',', '.'));

    if (a == null || b == null) {
      setState(() => rezultati = 'Shkruaj vlera të sakta');
      return;
    }

    const mu0 = 4 * math.pi * 1e-7;

    if (lloji == 'Ligji i Ohmit') {
      if (b == 0) {
        setState(() => rezultati = 'Rezistenca s’mund të jetë 0');
        return;
      }
      final i = a / b;
      setState(() => rezultati = 'I = ${i.toStringAsFixed(4)} A');
    } else if (lloji == 'Fuqia elektrike') {
      final p = a * b;
      setState(() => rezultati = 'P = ${p.toStringAsFixed(4)} W');
    } else if (lloji == 'Induksioni magnetik') {
      if (b == 0) {
        setState(() => rezultati = 'Distanca s’mund të jetë 0');
        return;
      }
      final B = (mu0 * a) / (2 * math.pi * b);
      setState(() => rezultati = 'B = ${B.toStringAsExponential(4)} T');
    } else {
      final B = mu0 * a * b;
      setState(() => rezultati = 'B = ${B.toStringAsExponential(4)} T');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Kartela(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kalkulatori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: lloji,
              decoration: const InputDecoration(
                labelText: 'Zgjidh formulën',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Ligji i Ohmit', child: Text('Ligji i Ohmit')),
                DropdownMenuItem(value: 'Fuqia elektrike', child: Text('Fuqia elektrike')),
                DropdownMenuItem(value: 'Induksioni magnetik', child: Text('Induksioni magnetik')),
                DropdownMenuItem(value: 'Solenoidi', child: Text('Solenoidi')),
              ],
              onChanged: (v) {
                if (v != null) _ndryshoLlojin(v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: aController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: etiketaA,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: etiketaB,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _llogarit,
              icon: const Icon(Icons.calculate),
              label: const Text('Llogarit'),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rezultati,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _kontrolleri = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (gjeneratoriAktiv) {
          bateria += rrjedhaUjit * 0.01;
          if (bateria > 1) bateria = 1;
        } else {
          bateria -= 0.003;
          if (bateria < 0) bateria = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _kontrolleri.dispose();
    super.dispose();
  }

  void _rivendos() {
    setState(() {
      gjeneratoriAktiv = true;
      rrjedhaUjit = 0.7;
      bateria = 0;
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
              builder: (context, _) {
                return CustomPaint(
                  painter: PiktoriGjeneratorit(
                    progresi: _kontrolleri.value,
                    rrjedhaUjit: gjeneratoriAktiv ? rrjedhaUjit : 0,
                    bateria: bateria,
                    llambaNdezur: llambaNdezur,
                  ),
                  child: const SizedBox.expand(),
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
              const SizedBox(height: 8),
              Text('Rrjedha e ujit: ${(rrjedhaUjit * 100).toStringAsFixed(0)}%'),
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

class PiktoriGjeneratorit extends CustomPainter {
  final double progresi;
  final double rrjedhaUjit;
  final double bateria;
  final bool llambaNdezur;

  PiktoriGjeneratorit({
    required this.progresi,
    required this.rrjedhaUjit,
    required this.bateria,
    required this.llambaNdezur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final qendraTurbines = Offset(size.width * 0.28, size.height * 0.58);
    final bateriaRect = Rect.fromLTWH(size.width * 0.55, size.height * 0.38, 70, 130);
    final llambaQendra = Offset(size.width * 0.82, size.height * 0.30);

    _vizatoUjin(canvas, size);
    _vizatoTurbinen(canvas, qendraTurbines, rrjedhaUjit, progresi);
    _vizatoTelat(canvas, qendraTurbines, bateriaRect, llambaQendra);
    _vizatoBaterine(canvas, bateriaRect, bateria);
    _vizatoLlamben(canvas, llambaQendra, llambaNdezur ? bateria : 0);
  }

  void _vizatoUjin(Canvas canvas, Size size) {
    final ujPaint = Paint()
      ..color = Colors.blue.withOpacity(0.65)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final x = size.width * 0.18;
    final y1 = size.height * 0.14;
    final y2 = size.height * 0.50;

    for (int i = 0; i < 5; i++) {
      final dx = i * 10.0;
      canvas.drawLine(
        Offset(x + dx, y1),
        Offset(x + dx, y2),
        ujPaint,
      );
    }
  }

  void _vizatoTurbinen(Canvas canvas, Offset c, double force, double progress) {
    final r = 38.0;

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(progress * 2 * math.pi * (0.3 + force * 1.7));

    final paint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset.zero, r, paint);

    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final p1 = Offset(math.cos(angle) * 10, math.sin(angle) * 10);
      final p2 = Offset(math.cos(angle) * r, math.sin(angle) * r);
      canvas.drawLine(p1, p2, paint);
    }

    canvas.drawCircle(Offset.zero, 5, Paint()..color = Colors.black87);
    canvas.restore();
  }

  void _vizatoTelat(Canvas canvas, Offset turbine, Rect bateriaRect, Offset llamba) {
    final tel = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final turbineOut = Offset(turbine.dx + 40, turbine.dy);
    final batteryIn = Offset(bateriaRect.left, bateriaRect.center.dy);
    final batteryOut = Offset(bateriaRect.right, bateriaRect.top + 18);

    canvas.drawLine(turbineOut, Offset(batteryIn.dx - 20, turbineOut.dy), tel);
    canvas.drawLine(Offset(batteryIn.dx - 20, turbineOut.dy), Offset(batteryIn.dx - 20, batteryIn.dy), tel);
    canvas.drawLine(Offset(batteryIn.dx - 20, batteryIn.dy), batteryIn, tel);

    canvas.drawLine(batteryOut, Offset(llamba.dx - 18, batteryOut.dy), tel);
    canvas.drawLine(Offset(llamba.dx - 18, batteryOut.dy), Offset(llamba.dx - 18, llamba.dy), tel);
    canvas.drawLine(Offset(llamba.dx - 18, llamba.dy), Offset(llamba.dx, llamba.dy), tel);
  }

  void _vizatoBaterine(Canvas canvas, Rect rect, double level) {
    final outline = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      outline,
    );

    final kapaku = Rect.fromLTWH(rect.left + rect.width * 0.32, rect.top - 10, rect.width * 0.36, 10);
    canvas.drawRect(kapaku, Paint()..color = Colors.black87);

    final fillHeight = rect.height * level;
    final fillRect = Rect.fromLTWH(
      rect.left + 4,
      rect.bottom - fillHeight - 4,
      rect.width - 8,
      fillHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, const Radius.circular(6)),
      Paint()..color = Colors.green,
    );
  }

  void _vizatoLlamben(Canvas canvas, Offset c, double level) {
    final r = 18.0;

    if (level > 0.01) {
      final glow = Paint()
        ..color = Colors.amber.withOpacity(0.20 + level * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(c, 28, glow);
    }

    canvas.drawCircle(
      c,
      r,
      Paint()..color = Color.lerp(Colors.grey.shade300, Colors.yellow.shade600, level.clamp(0.0, 1.0))!,
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant PiktoriGjeneratorit oldDelegate) {
    return oldDelegate.progresi != progresi ||
        oldDelegate.rrjedhaUjit != rrjedhaUjit ||
        oldDelegate.bateria != bateria ||
        oldDelegate.llambaNdezur != llambaNdezur;
  }
}