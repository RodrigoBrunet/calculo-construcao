/// Uma linha do resultado: ex. "Cimento" 7 sacos.
class ItemResultado {
  const ItemResultado({
    required this.rotulo,
    required this.quantidade,
    required this.unidade,
    this.unidadePlural,
    this.casas = 0,
  });

  final String rotulo;
  final num quantidade;
  final String unidade;
  final String? unidadePlural;

  /// Casas decimais ao mostrar a [quantidade].
  final int casas;

  /// Unidade no singular ou plural conforme a quantidade.
  String get unidadeExibida =>
      quantidade > 1 ? (unidadePlural ?? unidade) : unidade;

  Map<String, dynamic> toMap() => {
    'rotulo': rotulo,
    'quantidade': quantidade,
    'unidade': unidadeExibida,
  };

  @override
  bool operator ==(Object other) =>
      other is ItemResultado &&
      other.rotulo == rotulo &&
      other.quantidade == quantidade &&
      other.unidadeExibida == unidadeExibida;

  @override
  int get hashCode => Object.hash(rotulo, quantidade, unidadeExibida);

  @override
  String toString() => '$rotulo: $quantidade $unidadeExibida';
}

/// Resultado de qualquer cálculo: itens para comprar e observações.
class ResultadoCalculo {
  const ResultadoCalculo({required this.itens, this.observacoes = const []});

  final List<ItemResultado> itens;
  final List<String> observacoes;

  /// Procura um item pelo rótulo (útil em testes).
  ItemResultado? item(String rotulo) {
    for (final i in itens) {
      if (i.rotulo == rotulo) return i;
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
    'itens': [for (final i in itens) i.toMap()],
    if (observacoes.isNotEmpty) 'observacoes': observacoes,
  };
}
