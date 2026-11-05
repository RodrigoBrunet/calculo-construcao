import 'package:calculo_construcao/core/calculo/area.dart';
import 'package:calculo_construcao/core/calculo/arredondamento.dart';
import 'package:calculo_construcao/core/calculo/leitor_campos.dart';
import 'package:calculo_construcao/core/calculo/resultado_calculo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calcularArea', () {
    test('multiplica largura e comprimento no modo medidas', () {
      expect(
        calcularArea(ModoArea.medidas, largura: 3, comprimento: 2.5, area: 99),
        7.5,
      );
    });

    test('usa a área digitada no modo total', () {
      expect(
        calcularArea(ModoArea.total, largura: 3, comprimento: 2.5, area: 12),
        12,
      );
    });
  });

  group('arredondamento', () {
    test('ignora erro de ponto flutuante', () {
      expect(inteiroParaCima(250 * 1.1), 275);
      expect(arredondarParaCima(1.05 * 0.8, casas: 2), 0.84);
    });

    test('arredonda para cima', () {
      expect(inteiroParaCima(8.01), 9);
      expect(arredondarParaCima(0.0957, casas: 2), 0.1);
      expect(inteiroParaBaixo(17.99), 17);
    });
  });

  group('LeitorCampos', () {
    test('lê número com vírgula', () {
      final leitor = LeitorCampos<String>({'a': '2,5'});
      expect(leitor.positivo('a'), 2.5);
      expect(leitor.valido, isTrue);
    });

    test('registra erro de campo vazio, inválido ou zero', () {
      final leitor = LeitorCampos<String>({'b': 'x', 'c': '0'});
      leitor
        ..positivo('a')
        ..positivo('b')
        ..positivo('c');
      expect(leitor.erros, {
        'a': 'Informe um valor',
        'b': 'Número inválido',
        'c': 'Deve ser maior que zero',
      });
    });

    test('campo opcional vazio usa o padrão', () {
      final leitor = LeitorCampos<String>({'a': ''});
      expect(leitor.naoNegativo('a', padrao: 3), 3);
      expect(leitor.valido, isTrue);
    });
  });

  group('ItemResultado', () {
    test('usa o plural quando a quantidade passa de 1', () {
      const um = ItemResultado(
        rotulo: 'x',
        quantidade: 1,
        unidade: 'saco',
        unidadePlural: 'sacos',
      );
      const dois = ItemResultado(
        rotulo: 'x',
        quantidade: 2,
        unidade: 'saco',
        unidadePlural: 'sacos',
      );
      expect(um.unidadeExibida, 'saco');
      expect(dois.unidadeExibida, 'sacos');
    });
  });
}
