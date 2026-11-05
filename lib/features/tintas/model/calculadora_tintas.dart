import '../../../core/calculo/arredondamento.dart';
import '../../../core/calculo/calculadora.dart';
import '../../../core/calculo/resultado_calculo.dart';
import '../../../core/utils/number_formatter.dart';
import 'constantes_tintas.dart';
import 'entrada_tintas.dart';

/// Quantas latas (18 L) e galões (3,6 L) comprar.
typedef Embalagens = ({int latas, int galoes});

/// Litros e embalagens de tinta e fundo para uma área.
class CalculadoraTintas
    implements Calculadora<EntradaTintas, ResultadoCalculo> {
  const CalculadoraTintas();

  @override
  ResultadoCalculo calcular(EntradaTintas e) {
    final perda = 1 + e.perdaPct / 100;
    final litrosTinta =
        e.areaM2 * e.demaos / ConstantesTintas.rendimentoTintaM2PorL * perda;

    final superficie = e.superficie;
    final fundo = superficie.fundo;
    final rendimentoFundo = superficie.rendimentoFundoM2PorL;

    return ResultadoCalculo(
      itens: [
        ..._itens('Tinta acrílica', litrosTinta),
        if (fundo != null && rendimentoFundo != null)
          ..._itens(fundo, e.areaM2 / rendimentoFundo * perda),
      ],
      observacoes: [
        'Rendimento médio: ${NumberFormatter.format(ConstantesTintas.rendimentoTintaM2PorL)} m² '
            'por litro, por demão. Confira na lata do fabricante.',
        if (fundo != null) '$fundo: 1 demão antes da tinta.',
      ],
    );
  }

  /// Total em litros + quantas latas e galões.
  List<ItemResultado> _itens(String produto, double litros) {
    final (:latas, :galoes) = embalagensPara(litros);
    return [
      ItemResultado(
        rotulo: '$produto (total)',
        quantidade: arredondarParaCima(litros, casas: 1),
        unidade: 'litro',
        unidadePlural: 'litros',
        casas: 1,
      ),
      if (latas > 0)
        ItemResultado(
          rotulo: '$produto – lata 18 L',
          quantidade: latas,
          unidade: 'lata',
          unidadePlural: 'latas',
        ),
      if (galoes > 0)
        ItemResultado(
          rotulo: '$produto – galão 3,6 L',
          quantidade: galoes,
          unidade: 'galão',
          unidadePlural: 'galões',
        ),
    ];
  }

  /// Latas cheias primeiro; o resto em galões. Se forem galões demais, leva mais uma lata.
  static Embalagens embalagensPara(double litros) {
    var latas = inteiroParaBaixo(litros / ConstantesTintas.lataL);
    final resto = litros - latas * ConstantesTintas.lataL;
    var galoes = inteiroParaCima(resto / ConstantesTintas.galaoL);
    if (galoes >= ConstantesTintas.galoesPorLata) {
      latas++;
      galoes = 0;
    }
    return (latas: latas, galoes: galoes);
  }
}
