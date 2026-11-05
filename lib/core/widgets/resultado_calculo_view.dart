import 'package:flutter/material.dart';

import '../calculo/resultado_calculo.dart';
import '../theme/app_dimens.dart';
import '../utils/number_formatter.dart';
import 'result_card.dart';

/// Mostra os itens de um [ResultadoCalculo] em cards grandes, mais as observações.
class ResultadoCalculoView extends StatelessWidget {
  const ResultadoCalculoView({super.key, required this.resultado});

  final ResultadoCalculo resultado;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in resultado.itens) ...[
          ResultCard(
            label: item.rotulo,
            valor: NumberFormatter.format(item.quantidade, casas: item.casas),
            unidade: item.unidadeExibida,
          ),
          const SizedBox(height: AppDimens.espacoP),
        ],
        for (final obs in resultado.observacoes)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.espacoP),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: AppDimens.espacoP),
                Expanded(
                  child: Text(obs, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
