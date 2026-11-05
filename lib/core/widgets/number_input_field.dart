import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo numérico grande com teclado decimal. Aceita vírgula ou ponto.
class NumberInputField extends StatelessWidget {
  const NumberInputField({
    super.key,
    required this.label,
    required this.onChanged,
    this.controller,
    this.unidade,
    this.erro,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String? unidade;
  final String? erro;
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unidade,
        suffixStyle: const TextStyle(fontSize: 18),
        errorText: erro,
      ),
    );
  }
}
