import 'package:get_it/get_it.dart';

import '../../features/argamassa/model/calculadora_argamassa.dart';
import '../../features/argamassa/model/entrada_argamassa.dart';
import '../../features/argamassa/presenter/argamassa_presenter.dart';
import '../../features/historico/model/historico_repository.dart';
import '../../features/historico/model/historico_repository_impl.dart';
import '../../features/historico/presenter/historico_presenter.dart';
import '../../features/materiais/model/calculadora_materiais.dart';
import '../../features/materiais/model/entrada_materiais.dart';
import '../../features/materiais/presenter/materiais_presenter.dart';
import '../../features/tintas/model/calculadora_tintas.dart';
import '../../features/tintas/model/entrada_tintas.dart';
import '../../features/tintas/presenter/tintas_presenter.dart';
import '../calculo/calculadora.dart';
import '../calculo/resultado_calculo.dart';
import '../database/app_database.dart';

final getIt = GetIt.instance;

/// Registra as dependências do app. Chamado uma vez no `main`.
///
/// - Banco: singleton (abre uma vez).
/// - Repositórios e calculadoras: lazy singleton, registrados pela interface.
/// - Presenters: factory (um novo por tela, descartado no dispose da view).
Future<void> setupInjection() async {
  getIt.registerSingletonAsync<AppDatabase>(AppDatabase.open);

  // Repositórios
  getIt.registerLazySingleton<HistoricoRepository>(
    () => HistoricoRepositoryImpl(getIt<AppDatabase>()),
  );

  // Calculadoras
  getIt.registerLazySingleton<Calculadora<EntradaMateriais, ResultadoCalculo>>(
    () => const CalculadoraMateriais(),
  );
  getIt.registerLazySingleton<Calculadora<EntradaTintas, ResultadoCalculo>>(
    () => const CalculadoraTintas(),
  );
  getIt.registerLazySingleton<Calculadora<EntradaArgamassa, ResultadoCalculo>>(
    () => const CalculadoraArgamassa(),
  );

  // Presenters
  getIt.registerFactory<HistoricoPresenter>(
    () => HistoricoPresenter(getIt<HistoricoRepository>()),
  );
  getIt.registerFactory<MateriaisPresenter>(
    () => MateriaisPresenter(getIt(), getIt<HistoricoRepository>()),
  );
  getIt.registerFactory<TintasPresenter>(
    () => TintasPresenter(getIt(), getIt<HistoricoRepository>()),
  );
  getIt.registerFactory<ArgamassaPresenter>(
    () => ArgamassaPresenter(getIt(), getIt<HistoricoRepository>()),
  );

  await getIt.allReady();
}
