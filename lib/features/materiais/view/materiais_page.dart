import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/area_input.dart';
import '../../../core/widgets/controladores_campos.dart';
import '../../../core/widgets/number_input_field.dart';
import '../../../core/widgets/opcao_selector.dart';
import '../../../core/widgets/painel_resultado.dart';
import '../model/constantes_materiais.dart';
import '../presenter/materiais_presenter.dart';

class MateriaisPage extends StatefulWidget {
  const MateriaisPage({super.key});

  @override
  State<MateriaisPage> createState() => _MateriaisPageState();
}

class _MateriaisPageState extends State<MateriaisPage>
    with ControladoresCampos<CampoMateriais, MateriaisPage> {
  final _presenter = GetIt.I<MateriaisPresenter>();

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
    MateriaisState state,
    CampoMateriais campo,
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

  void _calcular() {
    FocusScope.of(context).unfocus();
    _presenter.calcular();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materiais por metragem')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _presenter,
          builder: (context, _) {
            final state = _presenter.state;
            final servico = state.servico;
            const espaco = SizedBox(height: AppDimens.espacoG);

            return ListView(
              padding: const EdgeInsets.all(AppDimens.espacoM),
              children: [
                OpcaoSelector<ServicoMateriais>(
                  titulo: 'O que você vai fazer?',
                  opcoes: ServicoMateriais.values,
                  selecionada: servico,
                  rotulo: (s) => s.rotulo,
                  onChanged: _presenter.selecionarServico,
                ),
                espaco,
                if (servico == ServicoMateriais.alvenaria) ...[
                  OpcaoSelector<TipoTijolo>(
                    titulo: 'Tijolo ou bloco',
                    opcoes: TipoTijolo.values,
                    selecionada: state.tipoTijolo,
                    rotulo: (t) => t.rotulo,
                    onChanged: _presenter.selecionarTijolo,
                  ),
                  espaco,
                ],
                if (servico == ServicoMateriais.telhado) ...[
                  OpcaoSelector<TipoTelha>(
                    titulo: 'Tipo de telha',
                    opcoes: TipoTelha.values,
                    selecionada: state.tipoTelha,
                    rotulo: (t) => t.rotulo,
                    onChanged: _presenter.selecionarTelha,
                  ),
                  espaco,
                ],
                AreaInput(
                  titulo: switch (servico) {
                    ServicoMateriais.alvenaria ||
                    ServicoMateriais.reboco => 'Tamanho da parede',
                    ServicoMateriais.telhado =>
                      'Área do telhado (vista de cima)',
                    _ => 'Área do piso',
                  },
                  modo: state.modoArea,
                  onModoChanged: _presenter.alterarModoArea,
                  largura: controlador(CampoMateriais.largura, state.textos),
                  comprimento: controlador(
                    CampoMateriais.comprimento,
                    state.textos,
                  ),
                  area: controlador(CampoMateriais.area, state.textos),
                  onLarguraChanged: (t) =>
                      _presenter.alterar(CampoMateriais.largura, t),
                  onComprimentoChanged: (t) =>
                      _presenter.alterar(CampoMateriais.comprimento, t),
                  onAreaChanged: (t) =>
                      _presenter.alterar(CampoMateriais.area, t),
                  erroLargura: state.erros[CampoMateriais.largura],
                  erroComprimento: state.erros[CampoMateriais.comprimento],
                  erroArea: state.erros[CampoMateriais.area],
                ),
                const SizedBox(height: AppDimens.espacoM),
                if (servico.descontaVaos) ...[
                  _campo(
                    state,
                    CampoMateriais.vaos,
                    'Portas e janelas (descontar)',
                    'm²',
                  ),
                  const SizedBox(height: AppDimens.espacoM),
                ],
                if (servico.usaEspessura) ...[
                  _campo(state, CampoMateriais.espessura, 'Espessura', 'cm'),
                  const SizedBox(height: AppDimens.espacoM),
                ],
                if (servico == ServicoMateriais.telhado) ...[
                  _campo(state, CampoMateriais.inclinacao, 'Inclinação', '%'),
                  const SizedBox(height: AppDimens.espacoM),
                ],
                _campo(state, CampoMateriais.perda, 'Margem de perda', '%'),
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
