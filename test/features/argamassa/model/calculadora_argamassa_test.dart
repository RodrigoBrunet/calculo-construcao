import 'package:calculo_construcao/features/argamassa/model/calculadora_argamassa.dart';
import 'package:calculo_construcao/features/argamassa/model/constantes_argamassa.dart';
import 'package:calculo_construcao/features/argamassa/model/entrada_argamassa.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculadora = CalculadoraArgamassa();

  test('porcelanato 60×60 em 20 m²', () {
    const e = EntradaArgamassa(
      larguraPecaCm: 60,
      comprimentoPecaCm: 60,
      areaM2: 20,
      tipoPeca: TipoPeca.porcelanato,
      espessuraPecaMm: 9,
      juntaMm: 2,
    );
    final r = calculadora.calcular(e);

    // 20 m² × 8 kg/m² × 1,1 = 176 kg → 8,8 sacos
    expect(r.item('Argamassa AC-III (saco 20 kg)')?.quantidade, 9);
    expect(r.item('Argamassa (total)')?.quantidade, 176);
    // (1200 / 360000) × 9 × 2 × 1,58 = 0,0948 kg/m² × 20 × 1,1 = 2,09 kg
    expect(CalculadoraArgamassa.rejunteKgPorM2(e), closeTo(0.0948, 1e-4));
    expect(r.item('Rejunte (total)')?.quantidade, 2.09);
    expect(r.item('Rejunte (saco 1 kg)')?.quantidade, 3);
    expect(r.observacoes.any((o) => o.contains('dupla colagem')), isTrue);
  });

  group('consumo por tamanho da peça', () {
    test('tabela pelo maior lado', () {
      expect(ConstantesArgamassa.consumoKgPorM2(20), 4);
      expect(ConstantesArgamassa.consumoKgPorM2(30), 5);
      expect(ConstantesArgamassa.consumoKgPorM2(45), 6);
      expect(ConstantesArgamassa.consumoKgPorM2(60), 8);
      expect(ConstantesArgamassa.consumoKgPorM2(120), 10);
    });

    test('30×30 não pede dupla colagem', () {
      final r = calculadora.calcular(
        const EntradaArgamassa(
          larguraPecaCm: 30,
          comprimentoPecaCm: 30,
          areaM2: 10,
          perdaPct: 0,
        ),
      );
      expect(r.item('Argamassa AC-I (saco 20 kg)')?.quantidade, 3); // 50 kg
      expect(r.observacoes.any((o) => o.contains('dupla colagem')), isFalse);
    });
  });

  group('tipo de argamassa', () {
    const base = EntradaArgamassa(
      larguraPecaCm: 45,
      comprimentoPecaCm: 45,
      areaM2: 10,
    );

    test('cerâmica interna: AC-I', () {
      expect(CalculadoraArgamassa.tipoArgamassa(base), 'AC-I');
    });

    test('cerâmica externa: AC-II', () {
      const e = EntradaArgamassa(
        larguraPecaCm: 45,
        comprimentoPecaCm: 45,
        areaM2: 10,
        local: LocalAplicacao.externo,
      );
      expect(CalculadoraArgamassa.tipoArgamassa(e), 'AC-II');
    });

    test('porcelanato ou peça com lado de 60 cm: AC-III', () {
      const porcelanato = EntradaArgamassa(
        larguraPecaCm: 45,
        comprimentoPecaCm: 45,
        areaM2: 10,
        tipoPeca: TipoPeca.porcelanato,
      );
      const grande = EntradaArgamassa(
        larguraPecaCm: 20,
        comprimentoPecaCm: 60,
        areaM2: 10,
      );
      expect(CalculadoraArgamassa.tipoArgamassa(porcelanato), 'AC-III');
      expect(CalculadoraArgamassa.tipoArgamassa(grande), 'AC-III');
    });
  });
}
