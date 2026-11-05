import 'package:calculo_construcao/core/utils/result.dart';
import 'package:calculo_construcao/features/historico/model/calculo_salvo.dart';
import 'package:calculo_construcao/features/historico/model/historico_repository.dart';
import 'package:calculo_construcao/features/historico/presenter/historico_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoricoRepository extends Mock implements HistoricoRepository {}

void main() {
  late MockHistoricoRepository repository;
  late HistoricoPresenter presenter;

  final calculo1 = CalculoSalvo(
    id: 1,
    tipo: 'teste',
    titulo: 'Parede',
    entradas: const {},
    resultado: const {},
    criadoEm: DateTime(2026, 1, 1),
  );
  final calculo2 = calculo1.copyWith(id: 2);

  setUp(() {
    repository = MockHistoricoRepository();
    presenter = HistoricoPresenter(repository);
  });

  tearDown(() => presenter.dispose());

  test('começa carregando', () {
    expect(presenter.state.status, HistoricoStatus.carregando);
  });

  group('carregar', () {
    test('mostra a lista quando o repositório responde', () async {
      when(() => repository.listar())
          .thenAnswer((_) async => Success([calculo1, calculo2]));

      await presenter.carregar();

      expect(presenter.state.status, HistoricoStatus.pronto);
      expect(presenter.state.itens, [calculo1, calculo2]);
      expect(presenter.state.vazio, isFalse);
    });

    test('marca como vazio quando não há itens', () async {
      when(() => repository.listar())
          .thenAnswer((_) async => const Success([]));

      await presenter.carregar();

      expect(presenter.state.vazio, isTrue);
    });

    test('mostra o erro quando o repositório falha', () async {
      when(() => repository.listar())
          .thenAnswer((_) async => const Failure('falhou'));

      await presenter.carregar();

      expect(presenter.state.status, HistoricoStatus.erro);
      expect(presenter.state.erro, 'falhou');
    });

    test('avisa a view a cada mudança de estado', () async {
      when(() => repository.listar())
          .thenAnswer((_) async => const Success([]));
      var avisos = 0;
      presenter.addListener(() => avisos++);

      await presenter.carregar();

      expect(avisos, 2); // carregando -> pronto
    });
  });

  group('apagar', () {
    setUp(() async {
      when(() => repository.listar())
          .thenAnswer((_) async => Success([calculo1, calculo2]));
      await presenter.carregar();
    });

    test('remove o item da lista e mostra aviso', () async {
      when(() => repository.apagar(1))
          .thenAnswer((_) async => const Success(null));

      await presenter.apagar(calculo1);

      expect(presenter.state.itens, [calculo2]);
      expect(presenter.state.mensagem, 'Cálculo apagado.');
      verify(() => repository.apagar(1)).called(1);
    });

    test('mantém a lista e mostra o erro quando falha', () async {
      when(() => repository.apagar(1))
          .thenAnswer((_) async => const Failure('não apagou'));

      await presenter.apagar(calculo1);

      expect(presenter.state.itens, [calculo1, calculo2]);
      expect(presenter.state.mensagem, 'não apagou');
    });

    test('mensagemExibida limpa o aviso sem avisar a view', () async {
      when(() => repository.apagar(1))
          .thenAnswer((_) async => const Success(null));
      await presenter.apagar(calculo1);
      var avisos = 0;
      presenter.addListener(() => avisos++);

      presenter.mensagemExibida();

      expect(presenter.state.mensagem, isNull);
      expect(avisos, 0);
    });
  });
}
