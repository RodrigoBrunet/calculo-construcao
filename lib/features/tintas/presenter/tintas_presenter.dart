import '../../../core/calculo/area.dart';
import '../../../core/calculo/calculadora.dart';
import '../../../core/calculo/leitor_campos.dart';
import '../../../core/calculo/resultado_calculo.dart';
import '../../../core/mvp/base_presenter.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/result.dart';
import '../../historico/model/calculo_salvo.dart';
import '../../historico/model/historico_repository.dart';
import '../model/constantes_tintas.dart';
import '../model/entrada_tintas.dart';

enum CampoTintas { largura, comprimento, area, demaos, perda }

class TintasState {
  const TintasState({
    this.superficie = SuperficiePintura.rebocoNovo,
    this.modoArea = ModoArea.total,
    this.textos = const {
      CampoTintas.demaos: '${ConstantesTintas.demaosPadrao}',
      CampoTintas.perda: '10',
    },
    this.erros = const {},
    this.resultado,
    this.salvo = false,
    this.mensagem,
  });

  final SuperficiePintura superficie;
  final ModoArea modoArea;
  final Map<CampoTintas, String> textos;
  final Map<CampoTintas, String> erros;
  final ResultadoCalculo? resultado;
  final bool salvo;

  /// Aviso de uma vez só (snackbar). A view chama [TintasPresenter.mensagemExibida].
  final String? mensagem;

  TintasState copyWith({
    SuperficiePintura? superficie,
    ModoArea? modoArea,
    Map<CampoTintas, String>? textos,
    Map<CampoTintas, String>? erros,
    ResultadoCalculo? resultado,
    bool limparResultado = false,
    bool? salvo,
    String? mensagem,
  }) => TintasState(
    superficie: superficie ?? this.superficie,
    modoArea: modoArea ?? this.modoArea,
    textos: textos ?? this.textos,
    erros: erros ?? this.erros,
    resultado: limparResultado ? null : resultado ?? this.resultado,
    salvo: salvo ?? (limparResultado ? false : this.salvo),
    mensagem: mensagem,
  );
}

class TintasPresenter extends BasePresenter<TintasState> {
  TintasPresenter(
    this._calculadora,
    this._historico, {
    DateTime Function()? agora,
  }) : _agora = agora ?? DateTime.now,
       super(const TintasState());

  final Calculadora<EntradaTintas, ResultadoCalculo> _calculadora;
  final HistoricoRepository _historico;
  final DateTime Function() _agora;

  EntradaTintas? _entrada;

  void selecionarSuperficie(SuperficiePintura superficie) {
    emit(state.copyWith(superficie: superficie, limparResultado: true));
  }

  void alterarModoArea(ModoArea modo) {
    emit(
      state.copyWith(
        modoArea: modo,
        erros: Map.of(state.erros)
          ..remove(CampoTintas.largura)
          ..remove(CampoTintas.comprimento)
          ..remove(CampoTintas.area),
        limparResultado: true,
      ),
    );
  }

  /// O usuário digitou num campo. Só redesenha se precisar tirar erro ou resultado.
  void alterar(CampoTintas campo, String texto) {
    final textos = {...state.textos, campo: texto};
    if (state.erros.containsKey(campo) || state.resultado != null) {
      emit(
        state.copyWith(
          textos: textos,
          erros: Map.of(state.erros)..remove(campo),
          limparResultado: true,
        ),
      );
    } else {
      emitSilencioso(state.copyWith(textos: textos));
    }
  }

  void calcular() {
    final leitor = LeitorCampos<CampoTintas>(state.textos);

    final area = switch (state.modoArea) {
      ModoArea.medidas => calcularArea(
        ModoArea.medidas,
        largura: leitor.positivo(CampoTintas.largura),
        comprimento: leitor.positivo(CampoTintas.comprimento),
      ),
      ModoArea.total => leitor.positivo(CampoTintas.area),
    };
    final demaos = leitor.positivo(CampoTintas.demaos);
    if (demaos > 0 && demaos != demaos.roundToDouble()) {
      leitor.erro(CampoTintas.demaos, 'Use um número inteiro');
    }
    final perda = leitor.naoNegativo(CampoTintas.perda);

    if (!leitor.valido) {
      _entrada = null;
      emit(state.copyWith(erros: leitor.erros, limparResultado: true));
      return;
    }

    final entrada = EntradaTintas(
      areaM2: area,
      superficie: state.superficie,
      demaos: demaos.round(),
      perdaPct: perda,
    );
    _entrada = entrada;
    emit(
      state.copyWith(
        erros: const {},
        resultado: _calculadora.calcular(entrada),
        salvo: false,
      ),
    );
  }

  Future<void> salvar() async {
    final entrada = _entrada;
    final resultado = state.resultado;
    if (entrada == null || resultado == null || state.salvo) return;

    final calculo = CalculoSalvo(
      tipo: 'tintas',
      titulo:
          'Pintura · ${entrada.superficie.rotulo} · '
          '${NumberFormatter.format(entrada.areaM2)} m²',
      entradas: entrada.toMap(),
      resultado: resultado.toMap(),
      criadoEm: _agora(),
    );

    switch (await _historico.salvar(calculo)) {
      case Success():
        emit(
          state.copyWith(salvo: true, mensagem: 'Cálculo salvo no histórico.'),
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
