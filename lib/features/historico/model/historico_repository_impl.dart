import '../../../core/database/app_database.dart';
import '../../../core/utils/result.dart';
import 'calculo_salvo.dart';
import 'historico_repository.dart';

class HistoricoRepositoryImpl implements HistoricoRepository {
  HistoricoRepositoryImpl(this._database);

  static const _tabela = 'calculos';
  final AppDatabase _database;

  @override
  Future<Result<List<CalculoSalvo>>> listar() async {
    try {
      final linhas = await _database.db.query(
        _tabela,
        orderBy: 'criado_em DESC',
      );
      return Success(linhas.map(CalculoSalvo.fromMap).toList());
    } catch (e) {
      return Failure('Não foi possível carregar o histórico.', e);
    }
  }

  @override
  Future<Result<CalculoSalvo>> salvar(CalculoSalvo calculo) async {
    try {
      final id = await _database.db.insert(_tabela, calculo.toMap());
      return Success(calculo.copyWith(id: id));
    } catch (e) {
      return Failure('Não foi possível salvar o cálculo.', e);
    }
  }

  @override
  Future<Result<void>> apagar(int id) async {
    try {
      await _database.db.delete(_tabela, where: 'id = ?', whereArgs: [id]);
      return const Success(null);
    } catch (e) {
      return Failure('Não foi possível apagar o cálculo.', e);
    }
  }
}
