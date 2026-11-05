import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/area_input.dart';
import '../../../core/widgets/controladores_campos.dart';
import '../../../core/widgets/number_input_field.dart';
import '../../../core/widgets/opcao_selector.dart';
import '../../../core/widgets/painel_resultado.dart';
import '../model/constantes_argamassa.dart';
import '../presenter/argamassa_presenter.dart';

class ArgamassaPage extends StatefulWidget {
  const ArgamassaPage({super.key});

  @override
  State<ArgamassaPage> createState() => _ArgamassaPageState();
}

class _ArgamassaPageState extends State<ArgamassaPage>
    with ControladoresCampos<CampoArgamassa, ArgamassaPage> {
  final _presenter = GetIt.I<ArgamassaPresenter>();

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_aoMudarEstado);
  }

  @override
  void dispose() {
    _presenter.removeListener(_aoMudarEstado);
    _presenter.dispose();
    descartarCampos();
    super.dispose();
  }

  void _aoMudarEstado() {
    final state = _presenter.state;
    sincronizarCampos(state.textos);

    final mensagem = state.mensagem;
    if (mensagem == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
    _presenter.mensagemExibida();
  }

  Widget _campo(
    ArgamassaState state,
    CampoArgamassa campo,
    String label,
    String unidade,
  ) {
    return NumberInputField(
      label: label,
      unidade: unidade,
      controller: controlador(campo, state.textos),
      erro: state.erros[campo],
      onChanged: (t) => _presenter.alterar(campo, t),
    );
  }

  /// Dois campos lado a lado.
  Widget _dupla(Widget a, Widget b) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: a),
      const SizedBox(width: AppDimens.espacoM),
      Expanded(child: b),
    ],
  );

  void _calcular() {
    FocusScope.of(context).unfocus();
    _presenter.calcular();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Argamassa e rejunte')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _presenter,
          builder: (context, _) {
            final state = _presenter.state;
            const espaco = SizedBox(height: AppDimens.espacoG);

            return ListView(
              padding: const EdgeInsets.all(AppDimens.espacoM),
              children: [
                OpcaoSelector<TipoPeca>(
                  titulo: 'Tipo de piso',
                  opcoes: TipoPeca.values,
                  selecionada: state.tipoPeca,
                  rotulo: (t) => t.rotulo,
                  onChanged: _presenter.selecionarTipoPeca,
                ),
                espaco,
                OpcaoSelector<TamanhoPeca>(
                  titulo: 'Tamanho da peça (cm)',
                  opcoes: TamanhoPeca.values,
                  selecionada: state.tamanho,
                  rotulo: (t) => t.rotulo,
                  onChanged: _presenter.selecionarTamanho,
                ),
                if (state.tamanho == TamanhoPeca.personalizado) ...[
                  const SizedBox(height: AppDimens.espacoM),
                  _dupla(
                    _campo(state, CampoArgamassa.pecaLargura, 'Largura', 'cm'),
                    _campo(
                      state,
                      CampoArgamassa.pecaComprimento,
                      'Comprimento',
                      'cm',
                    ),
                  ),
                ],
                espaco,
                OpcaoSelector<LocalAplicacao>(
                  titulo: 'Onde vai assentar',
                  opcoes: LocalAplicacao.values,
                  selecionada: state.local,
                  rotulo: (l) => l.rotulo,
                  onChanged: _presenter.selecionarLocal,
                ),
                espaco,
                AreaInput(
                  titulo: 'Área do piso ou parede',
                  modo: state.modoArea,
                  onModoChanged: _presenter.alterarModoArea,
                  largura: controlador(CampoArgamassa.largura, state.textos),
                  comprimento: controlador(
                    CampoArgamassa.comprimento,
                    state.textos,
                  ),
                  area: controlador(CampoArgamassa.area, state.textos),
                  onLarguraChanged: (t) =>
                      _presenter.alterar(CampoArgamassa.largura, t),
                  onComprimentoChanged: (t) =>
                      _presenter.alterar(CampoArgamassa.comprimento, t),
                  onAreaChanged: (t) =>
                      _presenter.alterar(CampoArgamassa.area, t),
                  erroLargura: state.erros[CampoArgamassa.largura],
                  erroComprimento: state.erros[CampoArgamassa.comprimento],
                  erroArea: state.erros[CampoArgamassa.area],
                ),
                const SizedBox(height: AppDimens.espacoM),
                _dupla(
                  _campo(
                    state,
                    CampoArgamassa.espessura,
                    'Espessura da peça',
                    'mm',
                  ),
                  _campo(state, CampoArgamassa.junta, 'Junta', 'mm'),
                ),
                const SizedBox(height: AppDimens.espacoM),
                _campo(state, CampoArgamassa.perda, 'Margem de perda', '%'),
                espaco,
                FilledButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calcular'),
                ),
                if (state.resultado case final resultado?) ...[
                  const SizedBox(height: AppDimens.espacoGG),
                  PainelResultado(
                    resultado: resultado,
                    salvo: state.salvo,
                    onSalvar: _presenter.salvar,
                  ),
                ],
                espaco,
              ],
            );
          },
        ),
      ),
    );
  }
}
