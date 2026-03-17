import 'package:flutter/material.dart';

import 'calculator_page.dart';
import 'circuit_page.dart';
import 'hydro_page.dart';
import 'magnet_page.dart';

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
      appBar: AppBar(title: const Text('Laborati i BIE'), centerTitle: true, backgroundColor: Colors.blueGrey[200],),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(indeksi),
          child: faqet[indeksi],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: indeksi,
        onDestinationSelected: (v) => setState(() => indeksi = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.electrical_services_outlined), selectedIcon: Icon(Icons.electrical_services), label: 'Qarku'),
          NavigationDestination(icon: Icon(Icons.settings_input_component_outlined), selectedIcon: Icon(Icons.settings_input_component), label: 'Magneti'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'Kalkulatori'),
          NavigationDestination(icon: Icon(Icons.water_drop_outlined), selectedIcon: Icon(Icons.water_drop), label: 'Gjeneratori me Ujë'),
        ],
      ),
    );
  }
}
