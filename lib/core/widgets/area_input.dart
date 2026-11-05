import 'package:flutter/material.dart';

import '../calculo/area.dart';
import '../theme/app_dimens.dart';
import 'number_input_field.dart';
import 'opcao_selector.dart';

/// Entrada da área: largura × comprimento ou área total em m².
class AreaInput extends StatelessWidget {
  const AreaInput({
    super.key,
    required this.modo,
    required this.onModoChanged,
    required this.largura,
    required this.comprimento,
    required this.area,
    required this.onLarguraChanged,
    required this.onComprimentoChanged,
    required this.onAreaChanged,
    this.erroLargura,
    this.erroComprimento,
    this.erroArea,
    this.titulo = 'Área',
  });

  final ModoArea modo;
  final ValueChanged<ModoArea> onModoChanged;
  final TextEditingController largura;
  final TextEditingController comprimento;
  final TextEditingController area;
  final ValueChanged<String> onLarguraChanged;
  final ValueChanged<String> onComprimentoChanged;
  final ValueChanged<String> onAreaChanged;
  final String? erroLargura;
  final String? erroComprimento;
  final String? erroArea;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OpcaoSelector<ModoArea>(
          titulo: titulo,
          opcoes: ModoArea.values,
          selecionada: modo,
          rotulo: (m) => m.rotulo,
          onChanged: onModoChanged,
        ),
        const SizedBox(height: AppDimens.espacoM),
        if (modo == ModoArea.medidas)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: NumberInputField(
                  label: 'Largura',
                  unidade: 'm',
                  controller: largura,
                  erro: erroLargura,
                  onChanged: onLarguraChanged,
                ),
              ),
              const SizedBox(width: AppDimens.espacoM),
              Expanded(
                child: NumberInputField(
                  label: 'Comprimento',
                  unidade: 'm',
                  controller: comprimento,
                  erro: erroComprimento,
                  onChanged: onComprimentoChanged,
                ),
              ),
            ],
          )
        else
          NumberInputField(
            label: 'Área total',
            unidade: 'm²',
            controller: area,
            erro: erroArea,
            onChanged: onAreaChanged,
          ),
      ],
    );
  }
}
