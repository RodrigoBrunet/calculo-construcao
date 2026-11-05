import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Destaque de um resultado: rótulo pequeno, valor bem grande e unidade.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.label,
    required this.valor,
    this.unidade,
  });

  final String label;
  final String valor;
  final String? unidade;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.espacoG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: AppDimens.espacoP),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: valor,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (unidade != null)
                    TextSpan(
                      text: ' $unidade',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}
