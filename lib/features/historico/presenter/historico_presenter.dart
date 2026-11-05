import '../../../core/mvp/base_presenter.dart';
import '../../../core/utils/result.dart';
import '../model/calculo_salvo.dart';
import '../model/historico_repository.dart';

enum HistoricoStatus { carregando, pronto, erro }

class HistoricoState {
  const HistoricoState({
    this.status = HistoricoStatus.carregando,
    this.itens = const [],
    this.erro,
    this.mensagem,
  });

  final HistoricoStatus status;
  final List<CalculoSalvo> itens;

  /// Erro que impede mostrar a lista.
  final String? erro;

  /// Aviso de uma vez só (snackbar). A view chama [HistoricoPresenter.mensagemExibida].
  final String? mensagem;

  bool get vazio => status == HistoricoStatus.pronto && itens.isEmpty;

  HistoricoState copyWith({
    HistoricoStatus? status,
    List<CalculoSalvo>? itens,
    String? erro,
    String? mensagem,
  }) => HistoricoState(
    status: status ?? this.status,
    itens: itens ?? this.itens,
    erro: erro,
    mensagem: mensagem,
  );
}

class HistoricoPresenter extends BasePresenter<HistoricoState> {
  HistoricoPresenter(this._repository) : super(const HistoricoState());

  final HistoricoRepository _repository;

  Future<void> carregar() async {
    emit(state.copyWith(status: HistoricoStatus.carregando));

    switch (await _repository.listar()) {
      case Success(:final value):
        emit(state.copyWith(status: HistoricoStatus.pronto, itens: value));
      case Failure(:final message):
        emit(state.copyWith(status: HistoricoStatus.erro, erro: message));
    }
  }

  Future<void> apagar(CalculoSalvo calculo) async {
    final id = calculo.id;
    if (id == null) return;

    switch (await _repository.apagar(id)) {
      case Success():
        emit(
          state.copyWith(
            itens: state.itens.where((c) => c.id != id).toList(),
            mensagem: 'Cálculo apagado.',
          ),
        );
      case Failure(:final message):
        emit(state.copyWith(mensagem: message));
    }
  }

  /// Limpa a mensagem depois que a view mostrou, sem redesenhar a tela.
  void mensagemExibida() {
    if (state.mensagem == null) return;
    emitSilencioso(state.copyWith());
  }
}
