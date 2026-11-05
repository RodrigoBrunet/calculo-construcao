/// Valores médios de mercado para assentamento de pisos e revestimentos.
abstract final class ConstantesArgamassa {
  static const sacoArgamassaKg = 20.0;
  static const sacoRejunteKg = 1.0;

  /// Densidade do rejunte cimentício (kg/dm³), usada na fórmula dos fabricantes.
  static const densidadeRejunte = 1.58;

  /// Peças maiores que isso (30×30 = 900 cm²) pedem dupla colagem.
  static const areaDuplaColagemCm2 = 900.0;

  static const perdaPadrao = 10.0;

  /// Consumo médio de argamassa colante (kg/m²) pelo maior lado da peça.
  static double consumoKgPorM2(double ladoMaiorCm) {
    if (ladoMaiorCm <= 20) return 4;
    if (ladoMaiorCm <= 33) return 5;
    if (ladoMaiorCm <= 45) return 6;
    if (ladoMaiorCm <= 60) return 8;
    return 10;
  }
}

enum TipoPeca {
  ceramica('Cerâmica', juntaPadraoMm: 3, espessuraPadraoMm: 8),
  porcelanato('Porcelanato', juntaPadraoMm: 2, espessuraPadraoMm: 9);

  const TipoPeca(
    this.rotulo, {
    required this.juntaPadraoMm,
    required this.espessuraPadraoMm,
  });

  final String rotulo;
  final double juntaPadraoMm;
  final double espessuraPadraoMm;
}

enum LocalAplicacao {
  interno('Área interna'),
  externo('Área externa');

  const LocalAplicacao(this.rotulo);
  final String rotulo;
}

/// Tamanhos comuns de peça, em cm. [personalizado] libera os campos.
enum TamanhoPeca {
  p30x30(30, 30),
  p45x45(45, 45),
  p60x60(60, 60),
  p60x120(60, 120),
  p90x90(90, 90),
  personalizado(0, 0);

  const TamanhoPeca(this.larguraCm, this.comprimentoCm);

  final double larguraCm;
  final double comprimentoCm;

  String get rotulo => this == personalizado
      ? 'Outro tamanho'
      : '${larguraCm.round()}×${comprimentoCm.round()}';
}
