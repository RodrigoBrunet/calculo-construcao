import 'package:calculo_construcao/features/tintas/model/calculadora_tintas.dart';
import 'package:calculo_construcao/features/tintas/model/constantes_tintas.dart';
import 'package:calculo_construcao/features/tintas/model/entrada_tintas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculadora = CalculadoraTintas();

  group('embalagensPara', () {
    test('latas cheias e o resto em galões', () {
      expect(CalculadoraTintas.embalagensPara(18), (latas: 1, galoes: 0));
      expect(CalculadoraTintas.embalagensPara(18.4), (latas: 1, galoes: 1));
      expect(CalculadoraTintas.embalagensPara(36.1), (latas: 2, galoes: 1));
      expect(CalculadoraTintas.embalagensPara(7), (latas: 0, galoes: 2));
    });

    test('5 galões ou mais viram uma lata', () {
      expect(CalculadoraTintas.embalagensPara(15), (latas: 1, galoes: 0));
      expect(CalculadoraTintas.embalagensPara(14.4), (latas: 0, galoes: 4));
    });
  });

  test('repintura de 100 m² em 2 demãos: 1 lata + 1 galão, sem fundo', () {
    // 100 × 2 / 12 × 1,1 = 18,33 L
    final r = calculadora.calcular(
      const EntradaTintas(areaM2: 100, superficie: SuperficiePintura.repintura),
    );

    expect(r.item('Tinta acrílica (total)')?.quantidade, 18.4);
    expect(r.item('Tinta acrílica – lata 18 L')?.quantidade, 1);
    expect(r.item('Tinta acrílica – galão 3,6 L')?.quantidade, 1);
    expect(r.itens.where((i) => i.rotulo.startsWith('Selador')), isEmpty);
  });

  test('reboco novo leva selador acrílico', () {
    // tinta: 60 × 2 / 12 × 1,1 = 11 L; selador: 60 / 6 × 1,1 = 11 L
    final r = calculadora.calcular(
      const EntradaTintas(areaM2: 60, superficie: SuperficiePintura.rebocoNovo),
    );

    expect(r.item('Tinta acrílica (total)')?.quantidade, 11);
    expect(r.item('Tinta acrílica – galão 3,6 L')?.quantidade, 4);
    expect(r.item('Tinta acrílica – lata 18 L'), isNull);
    expect(r.item('Selador acrílico (total)')?.quantidade, 11);
    expect(r.item('Selador acrílico – galão 3,6 L')?.quantidade, 4);
  });

  test('gesso leva fundo preparador', () {
    // 50 / 10 × 1,1 = 5,5 L
    final r = calculadora.calcular(
      const EntradaTintas(
        areaM2: 50,
        superficie: SuperficiePintura.gesso,
        demaos: 3,
      ),
    );

    expect(r.item('Fundo preparador para gesso (total)')?.quantidade, 5.5);
    expect(r.item('Fundo preparador para gesso – galão 3,6 L')?.quantidade, 2);
    // 50 × 3 / 12 × 1,1 = 13,75 L
    expect(r.item('Tinta acrílica (total)')?.quantidade, 13.8);
  });
}
