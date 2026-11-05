import '../../../core/calculo/area.dart';
import '../../../core/calculo/calculadora.dart';
import '../../../core/calculo/leitor_campos.dart';
import '../../../core/calculo/resultado_calculo.dart';
import '../../../core/mvp/base_presenter.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/result.dart';
import '../../historico/model/calculo_salvo.dart';
import '../../historico/model/historico_repository.dart';
import '../model/constantes_materiais.dart';
import '../model/entrada_materiais.dart';

enum CampoMateriais {
  largura,
  comprimento,
  area,
  vaos,
  espessura,
  inclinacao,
  perda,
}

class MateriaisState {
  const MateriaisState({
    required this.servico,
    required this.textos,
    this.modoArea = ModoArea.medidas,
    this.tipoTijolo = TipoTijolo.blocoCeramico,
    this.tipoTelha = TipoTelha.romana,
    this.erros = const {},
    this.resultado,
    this.salvo = false,
    this.mensagem,
  });

  factory MateriaisState.inicial() {
    const servico = ServicoMateriais.alvenaria;
    return MateriaisState(
      servico: servico,
      textos: {
        CampoMateriais.perda: NumberFormatter.format(servico.perdaPadrao),
        CampoMateriais.inclinacao: NumberFormatter.format(
          TipoTelha.romana.inclinacaoPadrao,
        ),
      },
    );
  }

  final ServicoMateriais servico;
  final ModoArea modoArea;
  final TipoTijolo tipoTijolo;
  final TipoTelha tipoTelha;

  /// Texto de cada campo, como o usuário digitou.
  final Map<CampoMateriais, String> textos;
  final Map<CampoMateriais, String> erros;

  final ResultadoCalculo? resultado;

  /// Se o [resultado] atual já foi salvo no histórico.
  final bool salvo;

  /// Aviso de uma vez só (snackbar). A view chama [MateriaisPresenter.mensagemExibida].
  final String? mensagem;

  MateriaisState copyWith({
    ServicoMateriais? servico,
    ModoArea? modoArea,
    TipoTijolo? tipoTijolo,
    TipoTelha? tipoTelha,
    Map<CampoMateriais, String>? textos,
    Map<CampoMateriais, String>? erros,
    ResultadoCalculo? resultado,
    bool limparResultado = false,
    bool? salvo,
    String? mensagem,
  }) => MateriaisState(
    servico: servico ?? this.servico,
    modoArea: modoArea ?? this.modoArea,
    tipoTijolo: tipoTijolo ?? this.tipoTijolo,
    tipoTelha: tipoTelha ?? this.tipoTelha,
    textos: textos ?? this.textos,
    erros: erros ?? this.erros,
    resultado: limparResultado ? null : resultado ?? this.resultado,
    salvo: salvo ?? (limparResultado ? false : this.salvo),
    mensagem: mensagem,
  );
}

class MateriaisPresenter extends BasePresenter<MateriaisState> {
  MateriaisPresenter(
    this._calculadora,
    this._historico, {
    DateTime Function()? agora,
  }) : _agora = agora ?? DateTime.now,
       super(MateriaisState.inicial());

  final Calculadora<EntradaMateriais, ResultadoCalculo> _calculadora;
  final HistoricoRepository _historico;
  final DateTime Function() _agora;

  /// Entrada do último cálculo, para salvar no histórico.
  EntradaMateriais? _entrada;

  void selecionarServico(ServicoMateriais servico) {
    if (servico == state.servico) return;
    emit(
      state.copyWith(
        servico: servico,
        textos: {
          ...state.textos,
          CampoMateriais.espessura: servico.usaEspessura
              ? NumberFormatter.format(servico.espessuraPadraoCm)
              : '',
          CampoMateriais.perda: NumberFormatter.format(servico.perdaPadrao),
        },
        erros: const {},
        limparResultado: true,
      ),
    );
  }

  void selecionarTijolo(TipoTijolo tipo) {
    emit(state.copyWith(tipoTijolo: tipo, limparResultado: true));
  }

  void selecionarTelha(TipoTelha tipo) {
    emit(
      state.copyWith(
        tipoTelha: tipo,
        textos: {
          ...state.textos,
          CampoMateriais.inclinacao: NumberFormatter.format(
            tipo.inclinacaoPadrao,
          ),
        },
        erros: Map.of(state.erros)..remove(CampoMateriais.inclinacao),
        limparResultado: true,
      ),
    );
  }

  void alterarModoArea(ModoArea modo) {
    emit(
      state.copyWith(
        modoArea: modo,
        erros: Map.of(state.erros)
          ..remove(CampoMateriais.largura)
          ..remove(CampoMateriais.comprimento)
          ..remove(CampoMateriais.area),
        limparResultado: true,
      ),
    );
  }

  /// O usuário digitou num campo. Só redesenha se precisar tirar erro ou resultado.
  void alterar(CampoMateriais campo, String texto) {
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
    final leitor = LeitorCampos<CampoMateriais>(state.textos);
    final servico = state.servico;

    final area = switch (state.modoArea) {
      ModoArea.medidas => calcularArea(
        ModoArea.medidas,
        largura: leitor.positivo(CampoMateriais.largura),
        comprimento: leitor.positivo(CampoMateriais.comprimento),
      ),
      ModoArea.total => leitor.positivo(CampoMateriais.area),
    };

    var vaos = 0.0;
    if (servico.descontaVaos) {
      vaos = leitor.naoNegativo(CampoMateriais.vaos);
      if (leitor.valido && vaos >= area) {
        leitor.erro(CampoMateriais.vaos, 'Maior que a área da parede');
      }
    }
    final espessura = servico.usaEspessura
        ? leitor.positivo(CampoMateriais.espessura)
        : 0.0;
    final inclinacao = servico == ServicoMateriais.telhado
        ? leitor.naoNegativo(CampoMateriais.inclinacao)
        : 0.0;
    final perda = leitor.naoNegativo(CampoMateriais.perda);

    if (!leitor.valido) {
      _entrada = null;
      emit(state.copyWith(erros: leitor.erros, limparResultado: true));
      return;
    }

    final entrada = EntradaMateriais(
      servico: servico,
      areaM2: area,
      vaosM2: vaos,
      espessuraCm: espessura,
      tipoTijolo: state.tipoTijolo,
      tipoTelha: state.tipoTelha,
      inclinacaoPct: inclinacao,
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
      tipo: 'materiais',
      titulo:
          '${entrada.servico.rotulo} · '
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
