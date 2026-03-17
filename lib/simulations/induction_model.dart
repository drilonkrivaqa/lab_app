class InduksionModel {
  const InduksionModel._();

  static double llogaritFuqine({
    required double shpejtesia,
    required double largesiaNorm,
  }) {
    final speedTerm = (shpejtesia / 550).clamp(0.0, 1.0);
    final afersia = (1.0 - largesiaNorm).clamp(0.0, 1.0);
    return (speedTerm * afersia * 1.2).clamp(0.0, 1.0);
  }
}
