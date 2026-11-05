/// Rendimentos médios de mercado para tinta acrílica e fundos.
abstract final class ConstantesTintas {
  /// m² pintados com 1 litro de tinta acrílica, por demão (já diluída).
  static const rendimentoTintaM2PorL = 12.0;

  static const lataL = 18.0;
  static const galaoL = 3.6;

  /// A partir de quantos galões vale mais levar uma lata.
  static const galoesPorLata = 5;

  static const demaosPadrao = 2;
  static const perdaPadrao = 10.0;
}

/// Tipo de superfície: define se precisa de fundo antes da tinta.
enum SuperficiePintura {
  rebocoNovo(
    'Reboco novo',
    fundo: 'Selador acrílico',
    rendimentoFundoM2PorL: 6,
  ),
  gesso(
    'Gesso / drywall',
    fundo: 'Fundo preparador para gesso',
    rendimentoFundoM2PorL: 10,
  ),
  repintura('Repintura');

  const SuperficiePintura(
    this.rotulo, {
    this.fundo,
    this.rendimentoFundoM2PorL,
  });

  final String rotulo;

  /// Produto aplicado antes da tinta (1 demão), ou null se não precisa.
  final String? fundo;
  final double? rendimentoFundoM2PorL;
}
