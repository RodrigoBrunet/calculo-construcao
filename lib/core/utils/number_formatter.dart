import 'package:intl/intl.dart';

/// Converte números entre texto (padrão brasileiro, com vírgula) e double.
abstract final class NumberFormatter {
  static const _locale = 'pt_BR';

  /// Lê "1.234,5", "1234,5" ou "1234.5". Retorna null se não for um número.
  static double? parse(String? texto) {
    if (texto == null) return null;
    var limpo = texto.trim().replaceAll(' ', '');
    if (limpo.isEmpty) return null;

    if (limpo.contains(',')) {
      // Formato brasileiro: ponto é separador de milhar.
      limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
    }
    return double.tryParse(limpo);
  }

  /// Formata com até [casas] casas decimais, sem zeros sobrando: 2.5 -> "2,5".
  static String format(num valor, {int casas = 2}) {
    final formato = NumberFormat.decimalPattern(_locale)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = casas;
    return formato.format(valor);
  }
}
