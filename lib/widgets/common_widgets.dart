import 'package:flutter/material.dart';

class Kartela extends StatelessWidget {
  final Widget child;

  const Kartela({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
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
