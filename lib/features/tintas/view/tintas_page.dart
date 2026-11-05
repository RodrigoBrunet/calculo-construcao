import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/area_input.dart';
import '../../../core/widgets/controladores_campos.dart';
import '../../../core/widgets/number_input_field.dart';
import '../../../core/widgets/opcao_selector.dart';
import '../../../core/widgets/painel_resultado.dart';
import '../model/constantes_tintas.dart';
import '../presenter/tintas_presenter.dart';

class TintasPage extends StatefulWidget {
  const TintasPage({super.key});

  @override
  State<TintasPage> createState() => _TintasPageState();
}

class _TintasPageState extends State<TintasPage>
    with ControladoresCampos<CampoTintas, TintasPage> {
  final _presenter = GetIt.I<TintasPresenter>();

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

  void _calcular() {
    FocusScope.of(context).unfocus();
    _presenter.calcular();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tintas e seladores')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _presenter,
          builder: (context, _) {
            final state = _presenter.state;
            const espaco = SizedBox(height: AppDimens.espacoG);

            return ListView(
              padding: const EdgeInsets.all(AppDimens.espacoM),
              children: [
                OpcaoSelector<SuperficiePintura>(
                  titulo: 'Tipo de superfície',
                  opcoes: SuperficiePintura.values,
                  selecionada: state.superficie,
                  rotulo: (s) => s.rotulo,
                  onChanged: _presenter.selecionarSuperficie,
                ),
                espaco,
                AreaInput(
                  titulo: 'Área a pintar',
                  modo: state.modoArea,
                  onModoChanged: _presenter.alterarModoArea,
                  largura: controlador(CampoTintas.largura, state.textos),
                  comprimento: controlador(
                    CampoTintas.comprimento,
                    state.textos,
                  ),
                  area: controlador(CampoTintas.area, state.textos),
                  onLarguraChanged: (t) =>
                      _presenter.alterar(CampoTintas.largura, t),
                  onComprimentoChanged: (t) =>
                      _presenter.alterar(CampoTintas.comprimento, t),
                  onAreaChanged: (t) => _presenter.alterar(CampoTintas.area, t),
                  erroLargura: state.erros[CampoTintas.largura],
                  erroComprimento: state.erros[CampoTintas.comprimento],
                  erroArea: state.erros[CampoTintas.area],
                ),
                const SizedBox(height: AppDimens.espacoM),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: NumberInputField(
                        label: 'Demãos de tinta',
                        controller: controlador(
                          CampoTintas.demaos,
                          state.textos,
                        ),
                        erro: state.erros[CampoTintas.demaos],
                        onChanged: (t) =>
                            _presenter.alterar(CampoTintas.demaos, t),
                      ),
                    ),
                    const SizedBox(width: AppDimens.espacoM),
                    Expanded(
                      child: NumberInputField(
                        label: 'Perda',
                        unidade: '%',
                        controller: controlador(
                          CampoTintas.perda,
                          state.textos,
                        ),
                        erro: state.erros[CampoTintas.perda],
                        onChanged: (t) =>
                            _presenter.alterar(CampoTintas.perda, t),
                      ),
                    ),
                  ],
                ),
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
