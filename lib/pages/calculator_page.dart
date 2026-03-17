import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';

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
      if (b == 0) return setState(() => rezultati = 'Rezistenca s’mund të jetë 0');
      setState(() => rezultati = 'I = ${(a / b).toStringAsFixed(4)} A');
    } else if (lloji == 'Fuqia elektrike') {
      setState(() => rezultati = 'P = ${(a * b).toStringAsFixed(4)} W');
    } else if (lloji == 'Induksioni magnetik') {
      if (b == 0) return setState(() => rezultati = 'Distanca s’mund të jetë 0');
      setState(() => rezultati = 'B = ${((mu0 * a) / (2 * math.pi * b)).toStringAsExponential(4)} T');
    } else {
      setState(() => rezultati = 'B = ${(mu0 * a * b).toStringAsExponential(4)} T');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Kartela(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kalkulatori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: lloji,
              decoration: const InputDecoration(labelText: 'Zgjidh formulën', border: OutlineInputBorder()),
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
            TextField(controller: aController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: etiketaA, border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: bController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: etiketaB, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _llogarit, icon: const Icon(Icons.calculate), label: const Text('Llogarit')),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35), borderRadius: BorderRadius.circular(12)),
              child: Text(rezultati, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
