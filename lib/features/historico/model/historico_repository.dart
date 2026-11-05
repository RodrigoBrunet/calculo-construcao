import '../../../core/utils/result.dart';
import 'calculo_salvo.dart';

abstract interface class HistoricoRepository {
  Future<Result<List<CalculoSalvo>>> listar();
  Future<Result<CalculoSalvo>> salvar(CalculoSalvo calculo);
  Future<Result<void>> apagar(int id);
}
