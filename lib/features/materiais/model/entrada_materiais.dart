import 'constantes_materiais.dart';

class EntradaMateriais {
  const EntradaMateriais({
    required this.servico,
    required this.areaM2,
    this.vaosM2 = 0,
    this.espessuraCm = 0,
    this.tipoTijolo = TipoTijolo.blocoCeramico,
    this.tipoTelha = TipoTelha.romana,
    this.inclinacaoPct = 0,
    this.perdaPct = 10,
  });

  final ServicoMateriais servico;

  /// Área da parede/piso, ou área em planta (vista de cima) do telhado.
  final double areaM2;

  /// Portas e janelas descontadas (só alvenaria e reboco).
  final double vaosM2;

  final double espessuraCm;
  final TipoTijolo tipoTijolo;
  final TipoTelha tipoTelha;
  final double inclinacaoPct;
  final double perdaPct;

  Map<String, dynamic> toMap() => {
    'servico': servico.name,
    'area_m2': areaM2,
    if (servico.descontaVaos) 'vaos_m2': vaosM2,
    if (servico.usaEspessura) 'espessura_cm': espessuraCm,
    if (servico == ServicoMateriais.alvenaria) 'tijolo': tipoTijolo.name,
    if (servico == ServicoMateriais.telhado) ...{
      'telha': tipoTelha.name,
      'inclinacao_pct': inclinacaoPct,
    },
    'perda_pct': perdaPct,
  };
}
