import 'dart:math' as math;

class InduksionModel {
  const InduksionModel._();

  static double llogaritFluks({
    required double afersia,
    required double forcaMagnetit,
    required double mbeshtjelljet,
  }) {
    final afersi = afersia.clamp(0.0, 1.0);
    final force = forcaMagnetit.clamp(0.0, 1.0);
    final turnsNorm = ((mbeshtjelljet - 5.0) / 45.0).clamp(0.0, 1.0);

    final profile = math.pow(afersi, 1.8).toDouble();
    final turnsFactor = 0.7 + turnsNorm * 0.8;
    final strengthFactor = 0.55 + force * 0.95;

    return (profile * turnsFactor * strengthFactor).clamp(0.0, 1.6);
  }

  static double llogaritSinjalInduksioni({
    required double deltaFluksi,
    required double shpejtesia,
    required double afersia,
    required double ndjeshmeriaLlambes,
  }) {
    final afersi = afersia.clamp(0.0, 1.0);
    final sensitivity = (0.65 + ndjeshmeriaLlambes.clamp(0.0, 1.0) * 0.95);

    final fluxDerivative = (deltaFluksi * 0.055).clamp(-1.2, 1.2);
    final velocityFactor = (shpejtesia / 900.0).clamp(-1.0, 1.0);

    final nearBoost = 0.18 + math.pow(afersi, 1.45) * 1.08;

    final weighted = (fluxDerivative * 0.72 + velocityFactor * 0.28) * nearBoost;

    return (weighted * sensitivity).clamp(-1.0, 1.0);
  }
}
