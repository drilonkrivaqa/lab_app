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
  String pershkrimi = 'Llogarit rrymën elektrike nga tensioni dhe rezistenca.';
  String formula = 'I = V / R';

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
        pershkrimi = 'Llogarit rrymën elektrike nga tensioni dhe rezistenca.';
        formula = 'I = V / R';
      } else if (lloji == 'Fuqia elektrike') {
        etiketaA = 'Tensioni (V)';
        etiketaB = 'Rryma (A)';
        pershkrimi = 'Llogarit fuqinë elektrike nga tensioni dhe rryma.';
        formula = 'P = V × I';
      } else if (lloji == 'Induksioni magnetik') {
        etiketaA = 'Rryma (A)';
        etiketaB = 'Distanca (m)';
        pershkrimi =
        'Llogarit induksionin magnetik pranë një përçuesi të drejtë me rrymë.';
        formula = 'B = μ₀I / 2πr';
      } else {
        etiketaA = 'Dendësia e mbështjelljeve n';
        etiketaB = 'Rryma (A)';
        pershkrimi =
        'Llogarit induksionin magnetik brenda një solenoidi ideal.';
        formula = 'B = μ₀ × n × I';
      }
    });
  }

  void _pastro() {
    setState(() {
      aController.clear();
      bController.clear();
      rezultati = '-';
    });
  }

  double? _parseInput(String text) {
    final cleaned = text.trim().replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  void _llogarit() {
    FocusScope.of(context).unfocus();

    final a = _parseInput(aController.text);
    final b = _parseInput(bController.text);

    if (a == null || b == null) {
      setState(() => rezultati = 'Shkruaj vlera të sakta numerike');
      return;
    }

    const mu0 = 4 * math.pi * 1e-7;

    if (lloji == 'Ligji i Ohmit') {
      if (b == 0) {
        setState(() => rezultati = 'Rezistenca s’mund të jetë 0');
        return;
      }
      setState(() => rezultati = 'I = ${(a / b).toStringAsFixed(4)} A');
    } else if (lloji == 'Fuqia elektrike') {
      setState(() => rezultati = 'P = ${(a * b).toStringAsFixed(4)} W');
    } else if (lloji == 'Induksioni magnetik') {
      if (b == 0) {
        setState(() => rezultati = 'Distanca s’mund të jetë 0');
        return;
      }
      final bField = (mu0 * a) / (2 * math.pi * b);
      setState(() => rezultati = 'B = ${bField.toStringAsExponential(4)} T');
    } else {
      final bField = mu0 * a * b;
      setState(() => rezultati = 'B = ${bField.toStringAsExponential(4)} T');
    }
  }

  Widget _buildInfoCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Formula',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              )),
          const SizedBox(height: 6),
          Text(
            formula,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            pershkrimi,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withOpacity(0.82),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rezultati',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            rezultati,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Kartela(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            child: const Icon(Icons.calculate_rounded),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Kalkulatori i Fizikës',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Zgjidh formulën, shkruaj vlerat dhe llogarit menjëherë rezultatin.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: lloji,
                        decoration: InputDecoration(
                          labelText: 'Zgjidh formulën',
                          prefixIcon: const Icon(Icons.functions_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Ligji i Ohmit',
                            child: Text('Ligji i Ohmit'),
                          ),
                          DropdownMenuItem(
                            value: 'Fuqia elektrike',
                            child: Text('Fuqia elektrike'),
                          ),
                          DropdownMenuItem(
                            value: 'Induksioni magnetik',
                            child: Text('Induksioni magnetik'),
                          ),
                          DropdownMenuItem(
                            value: 'Solenoidi',
                            child: Text('Solenoidi'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) _ndryshoLlojin(v);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(context),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: aController,
                        label: etiketaA,
                        icon: Icons.tune_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: bController,
                        label: etiketaB,
                        icon: Icons.straighten_rounded,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _llogarit,
                              icon: const Icon(Icons.calculate_rounded),
                              label: const Text('Llogarit'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _pastro,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Pastro'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildResultCard(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}