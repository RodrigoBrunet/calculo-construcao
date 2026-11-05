import 'package:calculo_construcao/core/utils/result.dart';
import 'package:calculo_construcao/features/historico/model/calculo_salvo.dart';
import 'package:calculo_construcao/features/historico/model/historico_repository.dart';
import 'package:calculo_construcao/features/tintas/model/calculadora_tintas.dart';
import 'package:calculo_construcao/features/tintas/model/constantes_tintas.dart';
import 'package:calculo_construcao/features/tintas/presenter/tintas_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoricoRepository extends Mock implements HistoricoRepository {}

void main() {
  late MockHistoricoRepository historico;
  late TintasPresenter presenter;

  setUpAll(() {
    registerFallbackValue(
      CalculoSalvo(
        tipo: '',
        titulo: '',
        entradas: const {},
        resultado: const {},
        criadoEm: DateTime(2026),
      ),
    );
  });

  setUp(() {
    historico = MockHistoricoRepository();
    presenter = TintasPresenter(const CalculadoraTintas(), historico);
  });

  tearDown(() => presenter.dispose());

  test('começa com 2 demãos e área total', () {
    expect(presenter.state.textos[CampoTintas.demaos], '2');
    expect(presenter.state.superficie, SuperficiePintura.rebocoNovo);
  });

  test('pede a área', () {
    presenter.calcular();

    expect(presenter.state.erros.keys, [CampoTintas.area]);
  });

  test('demãos precisam ser inteiras', () {
    presenter
      ..alterar(CampoTintas.area, '100')
      ..alterar(CampoTintas.demaos, '2,5')
      ..calcular();

    expect(presenter.state.erros[CampoTintas.demaos], 'Use um número inteiro');
  });

  test('calcula repintura', () {
    presenter
      ..selecionarSuperficie(SuperficiePintura.repintura)
      ..alterar(CampoTintas.area, '100')
      ..calcular();

    final r = presenter.state.resultado!;
    expect(r.item('Tinta acrílica – lata 18 L')?.quantidade, 1);
    expect(r.item('Tinta acrílica – galão 3,6 L')?.quantidade, 1);
  });

  test('trocar a superfície limpa o resultado', () {
    presenter
      ..alterar(CampoTintas.area, '100')
      ..calcular()
      ..selecionarSuperficie(SuperficiePintura.gesso);

    expect(presenter.state.resultado, isNull);
  });

  test('salva com título da superfície e área', () async {
    when(() => historico.salvar(any())).thenAnswer(
      (i) async => Success(i.positionalArguments.first as CalculoSalvo),
    );
    presenter
      ..alterar(CampoTintas.area, '40,5')
      ..calcular();

    await presenter.salvar();

    final salvo =
        verify(() => historico.salvar(captureAny())).captured.single
            as CalculoSalvo;
    expect(salvo.tipo, 'tintas');
    expect(salvo.titulo, 'Pintura · Reboco novo · 40,5 m²');
    expect(presenter.state.salvo, isTrue);
  });
}
