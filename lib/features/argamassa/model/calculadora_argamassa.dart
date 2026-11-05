import 'dart:math' as math;

import '../../../core/calculo/arredondamento.dart';
import '../../../core/calculo/calculadora.dart';
import '../../../core/calculo/resultado_calculo.dart';
import '../../../core/utils/number_formatter.dart';
import 'constantes_argamassa.dart';
import 'entrada_argamassa.dart';

/// Sacos de argamassa colante e de rejunte para assentar um piso/revestimento.
class CalculadoraArgamassa
    implements Calculadora<EntradaArgamassa, ResultadoCalculo> {
  const CalculadoraArgamassa();

  @override
  ResultadoCalculo calcular(EntradaArgamassa e) {
    final perda = 1 + e.perdaPct / 100;
    final ladoMaior = math.max(e.larguraPecaCm, e.comprimentoPecaCm);
    final duplaColagem =
        e.larguraPecaCm * e.comprimentoPecaCm >
        ConstantesArgamassa.areaDuplaColagemCm2;

    final consumo = ConstantesArgamassa.consumoKgPorM2(ladoMaior);
    final argamassaKg = e.areaM2 * consumo * perda;
    final rejunteKg = e.areaM2 * rejunteKgPorM2(e) * perda;
    final tipo = tipoArgamassa(e);

    return ResultadoCalculo(
      itens: [
        ItemResultado(
          rotulo: 'Argamassa $tipo (saco 20 kg)',
          quantidade: inteiroParaCima(
            argamassaKg / ConstantesArgamassa.sacoArgamassaKg,
          ),
          unidade: 'saco',
          unidadePlural: 'sacos',
        ),
        ItemResultado(
          rotulo: 'Argamassa (total)',
          quantidade: arredondarParaCima(argamassaKg, casas: 1),
          unidade: 'kg',
          casas: 1,
        ),
        ItemResultado(
          rotulo: 'Rejunte (saco 1 kg)',
          quantidade: inteiroParaCima(
            rejunteKg / ConstantesArgamassa.sacoRejunteKg,
          ),
          unidade: 'saco',
          unidadePlural: 'sacos',
        ),
        ItemResultado(
          rotulo: 'Rejunte (total)',
          quantidade: arredondarParaCima(rejunteKg, casas: 2),
          unidade: 'kg',
          casas: 2,
        ),
      ],
      observacoes: [
        'Consumo médio de argamassa: ${NumberFormatter.format(consumo)} kg/m².',
        if (duplaColagem) 'Peça grande: faça dupla colagem (argamassa no contrapiso e no verso da peça).',
        _motivoTipo(tipo),
      ],
    );
  }

  /// Fórmula dos fabricantes: ((C + L) / (C × L)) × E × J × densidade, em mm.
  static double rejunteKgPorM2(EntradaArgamassa e) {
    final c = e.comprimentoPecaCm * 10;
    final l = e.larguraPecaCm * 10;
    return (c + l) /
        (c * l) *
        e.espessuraPecaMm *
        e.juntaMm *
        ConstantesArgamassa.densidadeRejunte;
  }

  /// AC-III para porcelanato e peças grandes; AC-II para área externa; senão AC-I.
  static String tipoArgamassa(EntradaArgamassa e) {
    final ladoMaior = math.max(e.larguraPecaCm, e.comprimentoPecaCm);
    if (e.tipoPeca == TipoPeca.porcelanato || ladoMaior >= 60) return 'AC-III';
    if (e.local == LocalAplicacao.externo) return 'AC-II';
    return 'AC-I';
  }

  String _motivoTipo(String tipo) => switch (tipo) {
    'AC-III' => 'AC-III: indicada para porcelanato e peças grandes.',
    'AC-II' => 'AC-II: indicada para áreas externas.',
    _ => 'AC-I: indicada para cerâmica em área interna.',
  };
}
