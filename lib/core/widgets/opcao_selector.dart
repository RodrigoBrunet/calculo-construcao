import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Escolha de uma opção entre poucas, com chips grandes (fáceis de tocar na obra).
class OpcaoSelector<T> extends StatelessWidget {
  const OpcaoSelector({
    super.key,
    required this.opcoes,
    required this.selecionada,
    required this.rotulo,
    required this.onChanged,
    this.titulo,
  });

  final List<T> opcoes;
  final T selecionada;
  final String Function(T) rotulo;
  final ValueChanged<T> onChanged;
  final String? titulo;

  @override
  Widget build(BuildContext context) {
    final chips = Wrap(
      spacing: AppDimens.espacoP,
      runSpacing: AppDimens.espacoP,
      children: [
        for (final opcao in opcoes)
          ChoiceChip(
            label: Text(rotulo(opcao)),
            selected: opcao == selecionada,
            onSelected: (_) => onChanged(opcao),
            labelStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.espacoM,
              vertical: 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.raio),
            ),
          ),
      ],
    );

    if (titulo == null) return chips;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppDimens.espacoP),
        chips,
      ],
    );
  }
}
