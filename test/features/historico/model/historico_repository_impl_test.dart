import 'package:calculo_construcao/core/database/app_database.dart';
import 'package:calculo_construcao/core/utils/result.dart';
import 'package:calculo_construcao/features/historico/model/calculo_salvo.dart';
import 'package:calculo_construcao/features/historico/model/historico_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase database;
  late HistoricoRepositoryImpl repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    database = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = HistoricoRepositoryImpl(database);
  });

  tearDown(() => database.close());

  CalculoSalvo calculo(String titulo, DateTime data) => CalculoSalvo(
    tipo: 'teste',
    titulo: titulo,
    entradas: {'largura': 2.5},
    resultado: {'area': 10.0},
    criadoEm: data,
  );

  T valor<T>(Result<T> result) => (result as Success<T>).value;

  test('salva e lista com os dados intactos', () async {
    final salvo = valor(
      await repository.salvar(calculo('Parede', DateTime(2026, 1, 1))),
    );

    final lista = valor(await repository.listar());

    expect(salvo.id, isNotNull);
    expect(lista, hasLength(1));
    expect(lista.single.titulo, 'Parede');
    expect(lista.single.entradas, {'largura': 2.5});
    expect(lista.single.resultado, {'area': 10.0});
    expect(lista.single.criadoEm, DateTime(2026, 1, 1));
  });

  test('lista do mais recente para o mais antigo', () async {
    await repository.salvar(calculo('Antigo', DateTime(2026, 1, 1)));
    await repository.salvar(calculo('Novo', DateTime(2026, 2, 1)));

    final lista = valor(await repository.listar());

    expect(lista.map((c) => c.titulo), ['Novo', 'Antigo']);
  });

  test('apaga pelo id', () async {
    final salvo = valor(
      await repository.salvar(calculo('Parede', DateTime(2026, 1, 1))),
    );

    await repository.apagar(salvo.id!);

    expect(valor(await repository.listar()), isEmpty);
  });

  test('retorna Failure quando o banco falha', () async {
    await database.close();

    expect(await repository.listar(), isA<Failure<List<CalculoSalvo>>>());
  });
}
