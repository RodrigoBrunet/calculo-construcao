import 'constantes_tintas.dart';

class EntradaTintas {
  const EntradaTintas({
    required this.areaM2,
    required this.superficie,
    this.demaos = ConstantesTintas.demaosPadrao,
    this.perdaPct = ConstantesTintas.perdaPadrao,
  });

  final double areaM2;
  final SuperficiePintura superficie;

  /// Demãos de tinta (o fundo é sempre 1 demão).
  final int demaos;
  final double perdaPct;

  Map<String, dynamic> toMap() => {
    'area_m2': areaM2,
    'superficie': superficie.name,
    'demaos': demaos,
    'perda_pct': perdaPct,
  };
}
