import 'dart:math' as math;

/// Margem para ignorar erros de ponto flutuante (ex.: 250 * 1,1 = 275,00000000000006).
const _margem = 1e-9;

/// Arredonda para cima com [casas] casas decimais. Usado em sacos, latas, peças.
double arredondarParaCima(double valor, {int casas = 0}) {
  final fator = math.pow(10, casas).toDouble();
  return (valor * fator - _margem).ceilToDouble() / fator;
}

/// Arredonda para cima até o inteiro mais próximo.
int inteiroParaCima(double valor) => (valor - _margem).ceil();

/// Arredonda para baixo até o inteiro mais próximo.
int inteiroParaBaixo(double valor) => (valor + _margem).floor();
