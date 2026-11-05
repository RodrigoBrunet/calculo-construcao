import 'package:calculo_construcao/features/materiais/model/calculadora_materiais.dart';
import 'package:calculo_construcao/features/materiais/model/constantes_materiais.dart';
import 'package:calculo_construcao/features/materiais/model/entrada_materiais.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculadora = CalculadoraMateriais();

  num? qtd(EntradaMateriais e, String rotulo) =>
      calculadora.calcular(e).item(rotulo)?.quantidade;

  group('alvenaria', () {
    test('bloco 9×19×19 dá 25 peças/m², mais 10% de perda', () {
      expect(TipoTijolo.blocoCeramico.pecasPorM2, closeTo(25, 1e-9));

      const e = EntradaMateriais(
        servico: ServicoMateriais.alvenaria,
        areaM2: 10,
        tipoTijolo: TipoTijolo.blocoCeramico,
      );
      expect(qtd(e, 'Bloco cerâmico 9×19×19'), 275);
      // 10 m² × 0,010 m³/m² × 1,1 = 0,11 m³ de argamassa
      expect(qtd(e, 'Argamassa de assentamento (volume)'), 0.11);
      expect(qtd(e, 'Cimento (saco 50 kg)'), 1);
      expect(qtd(e, 'Cal hidratada (saco 20 kg)'), 1);
      expect(qtd(e, 'Areia média'), 0.1);
    });

    test('desconta portas e janelas', () {
      // (3 × 2,5 − 1,6) × 33,33 × 1,1 = 216,3
      const e = EntradaMateriais(
        servico: ServicoMateriais.alvenaria,
        areaM2: 7.5,
        vaosM2: 1.6,
        tipoTijolo: TipoTijolo.seisFuros,
      );
      expect(qtd(e, 'Tijolo 6 furos 9×14×19'), 217);
    });

    test('sem perda dá a conta exata', () {
      const e = EntradaMateriais(
        servico: ServicoMateriais.alvenaria,
        areaM2: 8,
        tipoTijolo: TipoTijolo.blocoConcreto,
        perdaPct: 0,
      );
      expect(qtd(e, 'Bloco de concreto 14×19×39'), 100);
    });
  });

  test('reboco de 2 cm em 20 m²', () {
    // 20 × 0,02 × 1,1 = 0,44 m³
    const e = EntradaMateriais(
      servico: ServicoMateriais.reboco,
      areaM2: 20,
      espessuraCm: 2,
    );
    expect(qtd(e, 'Argamassa (volume)'), 0.44);
    expect(qtd(e, 'Cimento (saco 50 kg)'), 2); // 1,32
    expect(qtd(e, 'Cal hidratada (saco 20 kg)'), 3); // 2,86
    expect(qtd(e, 'Areia média'), 0.39); // 0,3828
  });

  test('contrapiso de 5 cm em 10 m² não leva cal nem brita', () {
    const e = EntradaMateriais(
      servico: ServicoMateriais.contrapiso,
      areaM2: 10,
      espessuraCm: 5,
    );
    final r = calculadora.calcular(e);
    expect(r.item('Cimento (saco 50 kg)')?.quantidade, 5); // 4,62
    expect(r.item('Areia média')?.quantidade, 0.5); // 0,495
    expect(r.item('Cal hidratada (saco 20 kg)'), isNull);
    expect(r.item('Brita 1'), isNull);
  });

  test('concreto de 10 cm em 10 m² com 5% de perda', () {
    // 10 × 0,10 × 1,05 = 1,05 m³
    const e = EntradaMateriais(
      servico: ServicoMateriais.concreto,
      areaM2: 10,
      espessuraCm: 10,
      perdaPct: 5,
    );
    expect(qtd(e, 'Concreto (volume)'), 1.05);
    expect(qtd(e, 'Cimento (saco 50 kg)'), 8); // 7,35
    expect(qtd(e, 'Areia média'), 0.58); // 0,5775
    expect(qtd(e, 'Brita 1'), 0.84);
  });

  group('telhado', () {
    test('telha romana com 30% de inclinação', () {
      // 50 × √1,09 = 52,20 m² × 16 × 1,1 = 918,7
      const e = EntradaMateriais(
        servico: ServicoMateriais.telhado,
        areaM2: 50,
        tipoTelha: TipoTelha.romana,
        inclinacaoPct: 30,
      );
      expect(qtd(e, 'Telhas – Cerâmica romana'), 919);
      expect(qtd(e, 'Área do telhado (com inclinação)'), 52.21);
    });

    test('fibrocimento plano usa a área útil da telha', () {
      const e = EntradaMateriais(
        servico: ServicoMateriais.telhado,
        areaM2: 2.30 * 1.05 * 10,
        tipoTelha: TipoTelha.fibrocimento,
        inclinacaoPct: 0,
        perdaPct: 0,
      );
      expect(qtd(e, 'Telhas – Fibrocimento 2,44×1,10'), 10);
    });

    test('telhado não desconta vãos', () {
      const e = EntradaMateriais(
        servico: ServicoMateriais.telhado,
        areaM2: 10,
        vaosM2: 5,
        tipoTelha: TipoTelha.colonial,
        perdaPct: 0,
      );
      expect(qtd(e, 'Telhas – Cerâmica colonial'), 260);
    });
  });
}
