import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Card grande com ícone e texto, usado na grade da home.
class BigActionButton extends StatelessWidget {
  const BigActionButton({
    super.key,
    required this.icone,
    required this.titulo,
    required this.onPressed,
    this.subtitulo,
  });

  final IconData icone;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.espacoM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppDimens.raio),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.espacoM),
                  child: Icon(
                    icone,
                    size: AppDimens.icone,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.espacoM),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitulo != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitulo!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
