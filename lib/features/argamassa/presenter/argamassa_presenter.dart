import '../../../core/calculo/area.dart';
import '../../../core/calculo/calculadora.dart';
import '../../../core/calculo/leitor_campos.dart';
import '../../../core/calculo/resultado_calculo.dart';
import '../../../core/mvp/base_presenter.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/result.dart';
import '../../historico/model/calculo_salvo.dart';
import '../../historico/model/historico_repository.dart';
import '../model/constantes_argamassa.dart';
import '../model/entrada_argamassa.dart';

enum CampoArgamassa {
  largura,
  comprimento,
  area,
  pecaLargura,
  pecaComprimento,
  espessura,
  junta,
  perda,
}

class ArgamassaState {
  const ArgamassaState({
    required this.textos,
    this.tamanho = TamanhoPeca.p60x60,
    this.tipoPeca = TipoPeca.ceramica,
    this.local = LocalAplicacao.interno,
    this.modoArea = ModoArea.total,
    this.erros = const {},
    this.resultado,
    this.salvo = false,
    this.mensagem,
  });

  factory ArgamassaState.inicial() => ArgamassaState(
    textos: _padroesDaPeca(TipoPeca.ceramica, {
      CampoArgamassa.perda: NumberFormatter.format(
        ConstantesArgamassa.perdaPadrao,
      ),
    }),
  );

  final TamanhoPeca tamanho;
  final TipoPeca tipoPeca;
  final LocalAplicacao local;
  final ModoArea modoArea;
  final Map<CampoArgamassa, String> textos;
  final Map<CampoArgamassa, String> erros;
  final ResultadoCalculo? resultado;
  final bool salvo;

  /// Aviso de uma vez só (snackbar). A view chama [ArgamassaPresenter.mensagemExibida].
  final String? mensagem;

  ArgamassaState copyWith({
    TamanhoPeca? tamanho,
    TipoPeca? tipoPeca,
    LocalAplicacao? local,
    ModoArea? modoArea,
    Map<CampoArgamassa, String>? textos,
    Map<CampoArgamassa, String>? erros,
    ResultadoCalculo? resultado,
    bool limparResultado = false,
    bool? salvo,
    String? mensagem,
  }) => ArgamassaState(
    tamanho: tamanho ?? this.tamanho,
    tipoPeca: tipoPeca ?? this.tipoPeca,
    local: local ?? this.local,
    modoArea: modoArea ?? this.modoArea,
    textos: textos ?? this.textos,
    erros: erros ?? this.erros,
    resultado: limparResultado ? null : resultado ?? this.resultado,
    salvo: salvo ?? (limparResultado ? false : this.salvo),
    mensagem: mensagem,
  );
}

/// Junta e espessura padrão do tipo de peça.
Map<CampoArgamassa, String> _padroesDaPeca(
  TipoPeca tipo,
  Map<CampoArgamassa, String> textos,
) => {
  ...textos,
  CampoArgamassa.espessura: NumberFormatter.format(tipo.espessuraPadraoMm),
  CampoArgamassa.junta: NumberFormatter.format(tipo.juntaPadraoMm),
};

class ArgamassaPresenter extends BasePresenter<ArgamassaState> {
  ArgamassaPresenter(
    this._calculadora,
    this._historico, {
    DateTime Function()? agora,
  }) : _agora = agora ?? DateTime.now,
       super(ArgamassaState.inicial());

  final Calculadora<EntradaArgamassa, ResultadoCalculo> _calculadora;
  final HistoricoRepository _historico;
  final DateTime Function() _agora;

  EntradaArgamassa? _entrada;

  void selecionarTamanho(TamanhoPeca tamanho) {
    emit(
      state.copyWith(
        tamanho: tamanho,
        erros: Map.of(state.erros)
          ..remove(CampoArgamassa.pecaLargura)
          ..remove(CampoArgamassa.pecaComprimento),
        limparResultado: true,
      ),
    );
  }

  void selecionarTipoPeca(TipoPeca tipo) {
    if (tipo == state.tipoPeca) return;
    emit(
      state.copyWith(
        tipoPeca: tipo,
        textos: _padroesDaPeca(tipo, state.textos),
        erros: Map.of(state.erros)
          ..remove(CampoArgamassa.espessura)
          ..remove(CampoArgamassa.junta),
        limparResultado: true,
      ),
    );
  }

  void selecionarLocal(LocalAplicacao local) {
    emit(state.copyWith(local: local, limparResultado: true));
  }

  void alterarModoArea(ModoArea modo) {
    emit(
      state.copyWith(
        modoArea: modo,
        erros: Map.of(state.erros)
          ..remove(CampoArgamassa.largura)
          ..remove(CampoArgamassa.comprimento)
          ..remove(CampoArgamassa.area),
        limparResultado: true,
      ),
    );
  }

  /// O usuário digitou num campo. Só redesenha se precisar tirar erro ou resultado.
  void alterar(CampoArgamassa campo, String texto) {
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
    final leitor = LeitorCampos<CampoArgamassa>(state.textos);

    final tamanho = state.tamanho;
    final personalizado = tamanho == TamanhoPeca.personalizado;
    final pecaLargura = personalizado
        ? leitor.positivo(CampoArgamassa.pecaLargura)
        : tamanho.larguraCm;
    final pecaComprimento = personalizado
        ? leitor.positivo(CampoArgamassa.pecaComprimento)
        : tamanho.comprimentoCm;

    final area = switch (state.modoArea) {
      ModoArea.medidas => calcularArea(
        ModoArea.medidas,
        largura: leitor.positivo(CampoArgamassa.largura),
        comprimento: leitor.positivo(CampoArgamassa.comprimento),
      ),
      ModoArea.total => leitor.positivo(CampoArgamassa.area),
    };
    final espessura = leitor.positivo(CampoArgamassa.espessura);
    final junta = leitor.positivo(CampoArgamassa.junta);
    final perda = leitor.naoNegativo(CampoArgamassa.perda);

    if (!leitor.valido) {
      _entrada = null;
      emit(state.copyWith(erros: leitor.erros, limparResultado: true));
      return;
    }

    final entrada = EntradaArgamassa(
      larguraPecaCm: pecaLargura,
      comprimentoPecaCm: pecaComprimento,
      areaM2: area,
      tipoPeca: state.tipoPeca,
      local: state.local,
      espessuraPecaMm: espessura,
      juntaMm: junta,
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

    final peca =
        '${NumberFormatter.format(entrada.larguraPecaCm)}×'
        '${NumberFormatter.format(entrada.comprimentoPecaCm)}';
    final calculo = CalculoSalvo(
      tipo: 'argamassa',
      titulo:
          'Argamassa · ${entrada.tipoPeca.rotulo} $peca · '
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
