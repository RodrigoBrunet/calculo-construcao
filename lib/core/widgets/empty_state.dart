import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Mensagem centralizada para listas vazias ou erros.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icone,
    required this.mensagem,
    this.acao,
  });

  final IconData icone;
  final String mensagem;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.espacoGG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 72, color: cor),
            const SizedBox(height: AppDimens.espacoM),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: cor),
            ),
            if (acao != null) ...[
              const SizedBox(height: AppDimens.espacoG),
              acao!,
            ],
          ],
        ),
      ),
    );
  }
}
