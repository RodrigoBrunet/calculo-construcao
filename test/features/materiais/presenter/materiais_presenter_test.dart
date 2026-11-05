import 'package:calculo_construcao/core/calculo/area.dart';
import 'package:calculo_construcao/core/utils/result.dart';
import 'package:calculo_construcao/features/historico/model/calculo_salvo.dart';
import 'package:calculo_construcao/features/historico/model/historico_repository.dart';
import 'package:calculo_construcao/features/materiais/model/calculadora_materiais.dart';
import 'package:calculo_construcao/features/materiais/model/constantes_materiais.dart';
import 'package:calculo_construcao/features/materiais/presenter/materiais_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoricoRepository extends Mock implements HistoricoRepository {}

void main() {
  late MockHistoricoRepository historico;
  late MateriaisPresenter presenter;
  final agora = DateTime(2026, 11, 4, 10);

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
    presenter = MateriaisPresenter(
      const CalculadoraMateriais(),
      historico,
      agora: () => agora,
    );
  });

  tearDown(() => presenter.dispose());

  void preencherParede() {
    presenter
      ..alterar(CampoMateriais.largura, '4')
      ..alterar(CampoMateriais.comprimento, '2,5');
  }

  test('começa em alvenaria com perda de 10%', () {
    expect(presenter.state.servico, ServicoMateriais.alvenaria);
    expect(presenter.state.textos[CampoMateriais.perda], '10');
    expect(presenter.state.resultado, isNull);
  });

  group('calcular', () {
    test('mostra erro nos campos vazios', () {
      presenter.calcular();

      expect(
        presenter.state.erros.keys,
        containsAll([CampoMateriais.largura, CampoMateriais.comprimento]),
      );
      expect(presenter.state.resultado, isNull);
    });

    test('calcula com largura × comprimento', () {
      preencherParede();

      presenter.calcular();

      expect(presenter.state.erros, isEmpty);
      expect(
        presenter.state.resultado?.item('Bloco cerâmico 9×19×19')?.quantidade,
        275,
      );
    });

    test('calcula com a área total', () {
      presenter
        ..alterarModoArea(ModoArea.total)
        ..alterar(CampoMateriais.area, '10');

      presenter.calcular();

      expect(
        presenter.state.resultado?.item('Bloco cerâmico 9×19×19')?.quantidade,
        275,
      );
    });

    test('não aceita vãos maiores que a parede', () {
      preencherParede();
      presenter.alterar(CampoMateriais.vaos, '12');

      presenter.calcular();

      expect(presenter.state.erros[CampoMateriais.vaos], isNotNull);
      expect(presenter.state.resultado, isNull);
    });

    test('digitar depois do resultado limpa o resultado', () {
      preencherParede();
      presenter.calcular();

      presenter.alterar(CampoMateriais.largura, '5');

      expect(presenter.state.resultado, isNull);
    });
  });

  group('trocar opções', () {
    test('serviço preenche espessura e perda padrão', () {
      presenter.selecionarServico(ServicoMateriais.concreto);

      expect(presenter.state.textos[CampoMateriais.espessura], '10');
      expect(presenter.state.textos[CampoMateriais.perda], '5');

      presenter.selecionarServico(ServicoMateriais.reboco);

      expect(presenter.state.textos[CampoMateriais.espessura], '2');
      expect(presenter.state.textos[CampoMateriais.perda], '10');
    });

    test('telha preenche a inclinação padrão', () {
      presenter.selecionarTelha(TipoTelha.fibrocimento);

      expect(presenter.state.textos[CampoMateriais.inclinacao], '15');
    });

    test('mantém a área ao trocar de serviço', () {
      preencherParede();

      presenter
        ..selecionarServico(ServicoMateriais.contrapiso)
        ..calcular();

      expect(
        presenter.state.resultado?.item('Cimento (saco 50 kg)'),
        isNotNull,
      );
    });
  });

  group('salvar', () {
    test('grava no histórico e avisa', () async {
      when(() => historico.salvar(any())).thenAnswer(
        (i) async => Success(i.positionalArguments.first as CalculoSalvo),
      );
      preencherParede();
      presenter.calcular();

      await presenter.salvar();

      final salvo =
          verify(() => historico.salvar(captureAny())).captured.single
              as CalculoSalvo;
      expect(salvo.tipo, 'materiais');
      expect(salvo.titulo, 'Alvenaria · 10 m²');
      expect(salvo.criadoEm, agora);
      expect(salvo.entradas['area_m2'], 10);
      expect(presenter.state.salvo, isTrue);
      expect(presenter.state.mensagem, 'Cálculo salvo no histórico.');
    });

    test('mostra o erro quando o histórico falha', () async {
      when(() => historico.salvar(any()))
          .thenAnswer((_) async => const Failure('sem espaço'));
      preencherParede();
      presenter.calcular();

      await presenter.salvar();

      expect(presenter.state.salvo, isFalse);
      expect(presenter.state.mensagem, 'sem espaço');
    });

    test('não faz nada sem resultado', () async {
      await presenter.salvar();

      verifyNever(() => historico.salvar(any()));
    });

    test('mensagemExibida limpa o aviso sem avisar a view', () async {
      when(() => historico.salvar(any())).thenAnswer(
        (i) async => Success(i.positionalArguments.first as CalculoSalvo),
      );
      preencherParede();
      presenter.calcular();
      await presenter.salvar();
      var avisos = 0;
      presenter.addListener(() => avisos++);

      presenter.mensagemExibida();

      expect(presenter.state.mensagem, isNull);
      expect(presenter.state.resultado, isNotNull);
      expect(avisos, 0);
    });
  });
}
