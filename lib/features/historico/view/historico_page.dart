import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/empty_state.dart';
import '../model/calculo_salvo.dart';
import '../presenter/historico_presenter.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  final _presenter = GetIt.I<HistoricoPresenter>();
  final _formatoData = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_mostrarMensagem);
    _presenter.carregar();
  }

  @override
  void dispose() {
    _presenter.removeListener(_mostrarMensagem);
    _presenter.dispose();
    super.dispose();
  }

  void _mostrarMensagem() {
    final mensagem = _presenter.state.mensagem;
    if (mensagem == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
    _presenter.mensagemExibida();
  }

  Future<void> _confirmarApagar(CalculoSalvo calculo) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar cálculo?'),
        content: Text('"${calculo.titulo}" será removido do histórico.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmou == true) await _presenter.apagar(calculo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: ListenableBuilder(
        listenable: _presenter,
        builder: (context, _) {
          final state = _presenter.state;

          return switch (state.status) {
            HistoricoStatus.carregando => const Center(
              child: CircularProgressIndicator(),
            ),
            HistoricoStatus.erro => EmptyState(
              icone: Icons.error_outline,
              mensagem: state.erro ?? 'Algo deu errado.',
              acao: OutlinedButton.icon(
                onPressed: _presenter.carregar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar de novo'),
              ),
            ),
            HistoricoStatus.pronto when state.vazio => const EmptyState(
              icone: Icons.history,
              mensagem: 'Nenhum cálculo salvo ainda.',
            ),
            HistoricoStatus.pronto => ListView.separated(
              padding: const EdgeInsets.all(AppDimens.espacoM),
              itemCount: state.itens.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimens.espacoP),
              itemBuilder: (context, index) {
                final calculo = state.itens[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.espacoM,
                      vertical: AppDimens.espacoP,
                    ),
                    title: Text(
                      calculo.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(_formatoData.format(calculo.criadoEm)),
                    trailing: IconButton(
                      iconSize: 28,
                      tooltip: 'Apagar',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmarApagar(calculo),
                    ),
                  ),
                );
              },
            ),
          };
        },
      ),
    );
  }
}
