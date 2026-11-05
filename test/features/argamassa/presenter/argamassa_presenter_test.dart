import 'package:calculo_construcao/core/utils/result.dart';
import 'package:calculo_construcao/features/argamassa/model/calculadora_argamassa.dart';
import 'package:calculo_construcao/features/argamassa/model/constantes_argamassa.dart';
import 'package:calculo_construcao/features/argamassa/presenter/argamassa_presenter.dart';
import 'package:calculo_construcao/features/historico/model/calculo_salvo.dart';
import 'package:calculo_construcao/features/historico/model/historico_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoricoRepository extends Mock implements HistoricoRepository {}

void main() {
  late MockHistoricoRepository historico;
  late ArgamassaPresenter presenter;

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
    presenter = ArgamassaPresenter(const CalculadoraArgamassa(), historico);
  });

  tearDown(() => presenter.dispose());

  test('começa com 60×60 cerâmica e padrões preenchidos', () {
    final state = presenter.state;
    expect(state.tamanho, TamanhoPeca.p60x60);
    expect(state.textos[CampoArgamassa.espessura], '8');
    expect(state.textos[CampoArgamassa.junta], '3');
    expect(state.textos[CampoArgamassa.perda], '10');
  });

  test('porcelanato troca junta e espessura padrão', () {
    presenter.selecionarTipoPeca(TipoPeca.porcelanato);

    expect(presenter.state.textos[CampoArgamassa.espessura], '9');
    expect(presenter.state.textos[CampoArgamassa.junta], '2');
  });

  test('calcula 60×60 porcelanato em 20 m²', () {
    presenter
      ..selecionarTipoPeca(TipoPeca.porcelanato)
      ..alterar(CampoArgamassa.area, '20')
      ..calcular();

    final r = presenter.state.resultado!;
    expect(r.item('Argamassa AC-III (saco 20 kg)')?.quantidade, 9);
    expect(r.item('Rejunte (saco 1 kg)')?.quantidade, 3);
  });

  test('tamanho personalizado pede as medidas da peça', () {
    presenter
      ..selecionarTamanho(TamanhoPeca.personalizado)
      ..alterar(CampoArgamassa.area, '20')
      ..calcular();

    expect(
      presenter.state.erros.keys,
      containsAll([CampoArgamassa.pecaLargura, CampoArgamassa.pecaComprimento]),
    );

    presenter
      ..alterar(CampoArgamassa.pecaLargura, '20')
      ..alterar(CampoArgamassa.pecaComprimento, '20')
      ..calcular();

    expect(presenter.state.erros, isEmpty);
    expect(
      presenter.state.resultado
          ?.item('Argamassa AC-I (saco 20 kg)')
          ?.quantidade,
      5, // 20 × 4 × 1,1 = 88 kg
    );
  });

  test('salva com o tamanho da peça no título', () async {
    when(() => historico.salvar(any())).thenAnswer(
      (i) async => Success(i.positionalArguments.first as CalculoSalvo),
    );
    presenter
      ..alterar(CampoArgamassa.area, '20')
      ..calcular();

    await presenter.salvar();

    final salvo =
        verify(() => historico.salvar(captureAny())).captured.single
            as CalculoSalvo;
    expect(salvo.tipo, 'argamassa');
    expect(salvo.titulo, 'Argamassa · Cerâmica 60×60 · 20 m²');
    expect(presenter.state.mensagem, 'Cálculo salvo no histórico.');
  });
}
