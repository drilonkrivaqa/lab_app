import 'package:flutter/material.dart';

import 'pages/home_page.dart';

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
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        cardTheme: const CardThemeData(
          clipBehavior: Clip.antiAlias,
          elevation: 0.6,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      home: const FaqjaKryesore(),
    );
  }
}
