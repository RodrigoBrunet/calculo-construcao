import 'constantes_argamassa.dart';

class EntradaArgamassa {
  const EntradaArgamassa({
    required this.larguraPecaCm,
    required this.comprimentoPecaCm,
    required this.areaM2,
    this.tipoPeca = TipoPeca.ceramica,
    this.local = LocalAplicacao.interno,
    this.espessuraPecaMm = 8,
    this.juntaMm = 3,
    this.perdaPct = ConstantesArgamassa.perdaPadrao,
  });

  final double larguraPecaCm;
  final double comprimentoPecaCm;
  final double areaM2;
  final TipoPeca tipoPeca;
  final LocalAplicacao local;
  final double espessuraPecaMm;
  final double juntaMm;
  final double perdaPct;

  Map<String, dynamic> toMap() => {
    'peca_cm': '${larguraPecaCm}x$comprimentoPecaCm',
    'area_m2': areaM2,
    'tipo_peca': tipoPeca.name,
    'local': local.name,
    'espessura_mm': espessuraPecaMm,
    'junta_mm': juntaMm,
    'perda_pct': perdaPct,
  };
}
