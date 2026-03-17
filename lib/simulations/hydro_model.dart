class HidroModel {
  const HidroModel._();

  static double ndryshoNgarkesen({
    required double aktuale,
    required bool aktiv,
    required double rrjedha,
    required double dt,
  }) {
    final shkallaNgarkimit = 0.20 * rrjedha;
    final shkallaShkarkimit = 0.05;
    final eRe = aktiv
        ? aktuale + shkallaNgarkimit * dt
        : aktuale - shkallaShkarkimit * dt;
    return eRe.clamp(0.0, 1.0);
  }
}
