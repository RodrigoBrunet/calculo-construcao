/// Uma fórmula de cálculo: recebe a entrada e devolve o resultado.
///
/// Implementações são Dart puro (sem Flutter) para serem testadas direto.
abstract interface class Calculadora<E, R> {
  R calcular(E entrada);
}
