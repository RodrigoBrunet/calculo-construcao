import 'dart:math' as math;

import '../../../core/calculo/arredondamento.dart';
import '../../../core/calculo/calculadora.dart';
import '../../../core/calculo/resultado_calculo.dart';
import '../../../core/utils/number_formatter.dart';
import 'constantes_materiais.dart';
import 'entrada_materiais.dart';

/// Quantidade de materiais por metragem: alvenaria, reboco, contrapiso,
/// concreto e telhado. Todas as quantidades já incluem a perda.
class CalculadoraMateriais
    implements Calculadora<EntradaMateriais, ResultadoCalculo> {
  const CalculadoraMateriais();

  @override
  ResultadoCalculo calcular(EntradaMateriais e) {
    final fatorPerda = 1 + e.perdaPct / 100;
    final area = e.servico.descontaVaos
        ? math.max(0.0, e.areaM2 - e.vaosM2)
        : e.areaM2;
    final volume = area * e.espessuraCm / 100 * fatorPerda;

    return switch (e.servico) {
      ServicoMateriais.alvenaria => _alvenaria(e.tipoTijolo, area, fatorPerda),
      ServicoMateriais.reboco => _comTraco(
        area,
        volume,
        Traco.argamassa128,
        'Argamassa',
      ),
      ServicoMateriais.contrapiso => _comTraco(
        area,
        volume,
        Traco.contrapiso13,
        'Argamassa',
      ),
      ServicoMateriais.concreto => _comTraco(
        area,
        volume,
        Traco.concreto123,
        'Concreto',
      ),
      ServicoMateriais.telhado => _telhado(e, fatorPerda),
    };
  }

  ResultadoCalculo _alvenaria(TipoTijolo tijolo, double area, double perda) {
    final pecas = inteiroParaCima(area * tijolo.pecasPorM2 * perda);
    final argamassa = _comTraco(
      area,
      area * tijolo.argamassaM3PorM2 * perda,
      Traco.argamassa128,
      'Argamassa de assentamento',
    );

    return ResultadoCalculo(
      itens: [
        ItemResultado(
          rotulo: tijolo.rotulo,
          quantidade: pecas,
          unidade: 'unidade',
          unidadePlural: 'unidades',
        ),
        ...argamassa.itens,
      ],
      observacoes: argamassa.observacoes,
    );
  }

  /// Converte um volume de argamassa/concreto em cimento, cal, areia e brita.
  ResultadoCalculo _comTraco(
    double area,
    double volumeM3,
    Traco traco,
    String nomeVolume,
  ) {
    return ResultadoCalculo(
      itens: [
        ItemResultado(
          rotulo: '$nomeVolume (volume)',
          quantidade: arredondarParaCima(volumeM3, casas: 3),
          unidade: 'm³',
          casas: 3,
        ),
        ItemResultado(
          rotulo: 'Cimento (saco 50 kg)',
          quantidade: inteiroParaCima(
            volumeM3 * traco.cimentoKg / ConstantesMateriais.sacoCimentoKg,
          ),
          unidade: 'saco',
          unidadePlural: 'sacos',
        ),
        if (traco.calKg > 0)
          ItemResultado(
            rotulo: 'Cal hidratada (saco 20 kg)',
            quantidade: inteiroParaCima(
              volumeM3 * traco.calKg / ConstantesMateriais.sacoCalKg,
            ),
            unidade: 'saco',
            unidadePlural: 'sacos',
          ),
        ItemResultado(
          rotulo: 'Areia média',
          quantidade: arredondarParaCima(volumeM3 * traco.areiaM3, casas: 2),
          unidade: 'm³',
          casas: 2,
        ),
        if (traco.britaM3 > 0)
          ItemResultado(
            rotulo: 'Brita 1',
            quantidade: arredondarParaCima(volumeM3 * traco.britaM3, casas: 2),
            unidade: 'm³',
            casas: 2,
          ),
      ],
      observacoes: [
        'Área considerada: ${NumberFormatter.format(area)} m². '
            'Traço: ${traco.descricao}.',
      ],
    );
  }

  ResultadoCalculo _telhado(EntradaMateriais e, double perda) {
    final inclinacao = e.inclinacaoPct / 100;
    final areaReal = e.areaM2 * math.sqrt(1 + inclinacao * inclinacao);
    final telhas = inteiroParaCima(areaReal * e.tipoTelha.telhasPorM2 * perda);

    return ResultadoCalculo(
      itens: [
        ItemResultado(
          rotulo: 'Telhas – ${e.tipoTelha.rotulo}',
          quantidade: telhas,
          unidade: 'telha',
          unidadePlural: 'telhas',
        ),
        ItemResultado(
          rotulo: 'Área do telhado (com inclinação)',
          quantidade: arredondarParaCima(areaReal, casas: 2),
          unidade: 'm²',
          casas: 2,
        ),
      ],
      observacoes: const [
        'Informe a área vista de cima (em planta), incluindo os beirais.',
        'Cumeeiras e rufos não estão incluídos.',
      ],
    );
  }
}
