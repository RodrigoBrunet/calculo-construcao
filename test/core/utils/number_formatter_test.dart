import 'package:calculo_construcao/core/utils/number_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberFormatter.parse', () {
    test('lê vírgula como decimal', () {
      expect(NumberFormatter.parse('2,5'), 2.5);
    });

    test('lê ponto como decimal quando não há vírgula', () {
      expect(NumberFormatter.parse('2.5'), 2.5);
    });

    test('ignora ponto de milhar no formato brasileiro', () {
      expect(NumberFormatter.parse('1.234,56'), 1234.56);
    });

    test('ignora espaços', () {
      expect(NumberFormatter.parse(' 3,2 '), 3.2);
    });

    test('retorna null para texto inválido ou vazio', () {
      expect(NumberFormatter.parse(''), isNull);
      expect(NumberFormatter.parse(null), isNull);
      expect(NumberFormatter.parse('abc'), isNull);
      expect(NumberFormatter.parse('1,2,3'), isNull);
    });
  });

  group('NumberFormatter.format', () {
    test('usa vírgula e remove zeros sobrando', () {
      expect(NumberFormatter.format(2.5), '2,5');
      expect(NumberFormatter.format(3), '3');
    });

    test('arredonda nas casas pedidas e usa ponto de milhar', () {
      expect(NumberFormatter.format(1234.567), '1.234,57');
      expect(NumberFormatter.format(1.23456, casas: 3), '1,235');
    });
  });
}
