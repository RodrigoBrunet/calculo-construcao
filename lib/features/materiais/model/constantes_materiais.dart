/// Valores médios de mercado usados no cálculo de materiais.
///
/// Ficam todos aqui para facilitar o ajuste sem mexer nas fórmulas.
abstract final class ConstantesMateriais {
  static const sacoCimentoKg = 50.0;
  static const sacoCalKg = 20.0;

  /// Junta de argamassa entre tijolos/blocos, em metros.
  static const juntaAlvenariaM = 0.01;
}

/// Consumo de materiais por m³ de argamassa ou concreto pronto.
class Traco {
  const Traco({
    required this.descricao,
    required this.cimentoKg,
    this.calKg = 0,
    required this.areiaM3,
    this.britaM3 = 0,
  });

  final String descricao;
  final double cimentoKg;
  final double calKg;
  final double areiaM3;
  final double britaM3;

  /// Argamassa mista para assentamento e reboco.
  static const argamassa128 = Traco(
    descricao: 'argamassa 1:2:8 (cimento, cal e areia)',
    cimentoKg: 150,
    calKg: 130,
    areiaM3: 0.87,
  );

  /// Contrapiso (farofa).
  static const contrapiso13 = Traco(
    descricao: 'contrapiso 1:3 (cimento e areia)',
    cimentoKg: 420,
    areiaM3: 0.9,
  );

  /// Concreto para piso e laje, cerca de 20 MPa.
  static const concreto123 = Traco(
    descricao: 'concreto 1:2:3 (cimento, areia e brita)',
    cimentoKg: 350,
    areiaM3: 0.55,
    britaM3: 0.80,
  );
}

enum ServicoMateriais {
  alvenaria('Alvenaria', espessuraPadraoCm: 0, perdaPadrao: 10),
  reboco('Reboco', espessuraPadraoCm: 2, perdaPadrao: 10),
  contrapiso('Contrapiso', espessuraPadraoCm: 5, perdaPadrao: 10),
  concreto('Concreto', espessuraPadraoCm: 10, perdaPadrao: 5),
  telhado('Telhado', espessuraPadraoCm: 0, perdaPadrao: 10);

  const ServicoMateriais(
    this.rotulo, {
    required this.espessuraPadraoCm,
    required this.perdaPadrao,
  });

  final String rotulo;
  final double espessuraPadraoCm;
  final double perdaPadrao;

  bool get usaEspessura => espessuraPadraoCm > 0;

  /// Paredes podem descontar portas e janelas.
  bool get descontaVaos => this == alvenaria || this == reboco;
}

enum TipoTijolo {
  blocoCeramico(
    'Bloco cerâmico 9×19×19',
    faceComprimentoM: 0.19,
    faceAlturaM: 0.19,
    argamassaM3PorM2: 0.010,
  ),
  seisFuros(
    'Tijolo 6 furos 9×14×19',
    faceComprimentoM: 0.19,
    faceAlturaM: 0.14,
    argamassaM3PorM2: 0.012,
  ),
  macico(
    'Tijolo maciço 5×10×20',
    faceComprimentoM: 0.20,
    faceAlturaM: 0.05,
    argamassaM3PorM2: 0.025,
  ),
  blocoConcreto(
    'Bloco de concreto 14×19×39',
    faceComprimentoM: 0.39,
    faceAlturaM: 0.19,
    argamassaM3PorM2: 0.012,
  );

  const TipoTijolo(
    this.rotulo, {
    required this.faceComprimentoM,
    required this.faceAlturaM,
    required this.argamassaM3PorM2,
  });

  final String rotulo;
  final double faceComprimentoM;
  final double faceAlturaM;

  /// Argamassa de assentamento gasta por m² de parede.
  final double argamassaM3PorM2;

  /// Peças por m² contando a junta de argamassa.
  double get pecasPorM2 {
    const junta = ConstantesMateriais.juntaAlvenariaM;
    return 1 / ((faceComprimentoM + junta) * (faceAlturaM + junta));
  }
}

enum TipoTelha {
  romana('Cerâmica romana', telhasPorM2: 16, inclinacaoPadrao: 30),
  portuguesa('Cerâmica portuguesa', telhasPorM2: 17, inclinacaoPadrao: 30),
  colonial('Cerâmica colonial', telhasPorM2: 26, inclinacaoPadrao: 30),
  francesa('Cerâmica francesa', telhasPorM2: 16, inclinacaoPadrao: 30),

  /// 2,44 × 1,10 m com sobreposição: área útil de 2,30 × 1,05 m.
  fibrocimento(
    'Fibrocimento 2,44×1,10',
    telhasPorM2: 1 / (2.30 * 1.05),
    inclinacaoPadrao: 15,
  );

  const TipoTelha(
    this.rotulo, {
    required this.telhasPorM2,
    required this.inclinacaoPadrao,
  });

  final String rotulo;
  final double telhasPorM2;

  /// Inclinação usual, em %.
  final double inclinacaoPadrao;
}
