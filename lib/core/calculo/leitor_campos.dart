import '../utils/number_formatter.dart';

/// Lê os textos de um formulário de cálculo e junta os erros por campo.
///
/// Os métodos devolvem 0 quando o campo é inválido; confira [valido] antes de usar.
class LeitorCampos<C> {
  LeitorCampos(this._textos);

  final Map<C, String> _textos;
  final Map<C, String> erros = {};

  bool get valido => erros.isEmpty;

  /// Número obrigatório e maior que zero.
  double positivo(C campo) {
    final texto = _textos[campo]?.trim() ?? '';
    if (texto.isEmpty) return _erro(campo, 'Informe um valor');
    final valor = NumberFormatter.parse(texto);
    if (valor == null) return _erro(campo, 'Número inválido');
    if (valor <= 0) return _erro(campo, 'Deve ser maior que zero');
    return valor;
  }

  /// Número opcional (vazio vale [padrao]) e não negativo.
  double naoNegativo(C campo, {double padrao = 0}) {
    final texto = _textos[campo]?.trim() ?? '';
    if (texto.isEmpty) return padrao;
    final valor = NumberFormatter.parse(texto);
    if (valor == null) return _erro(campo, 'Número inválido');
    if (valor < 0) return _erro(campo, 'Não pode ser negativo');
    return valor;
  }

  /// Registra um erro de regra de negócio num campo.
  void erro(C campo, String mensagem) => erros[campo] = mensagem;

  double _erro(C campo, String mensagem) {
    erros[campo] = mensagem;
    return 0;
  }
}
