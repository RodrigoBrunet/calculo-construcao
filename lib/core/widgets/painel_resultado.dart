import 'package:flutter/material.dart';

import '../calculo/resultado_calculo.dart';
import '../theme/app_dimens.dart';
import 'resultado_calculo_view.dart';

/// Resultado de um cálculo + botão "Salvar no histórico".
class PainelResultado extends StatelessWidget {
  const PainelResultado({
    super.key,
    required this.resultado,
    required this.salvo,
    required this.onSalvar,
  });

  final ResultadoCalculo resultado;
  final bool salvo;
  final VoidCallback onSalvar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Você vai precisar de',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppDimens.espacoM),
        ResultadoCalculoView(resultado: resultado),
        const SizedBox(height: AppDimens.espacoG),
        OutlinedButton.icon(
          onPressed: salvo ? null : onSalvar,
          icon: Icon(salvo ? Icons.check : Icons.save_outlined),
          label: Text(salvo ? 'Salvo no histórico' : 'Salvar no histórico'),
        ),
      ],
    );
  }
}
