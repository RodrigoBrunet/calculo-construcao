import 'package:flutter/widgets.dart';

/// Guarda um [TextEditingController] por campo do formulário.
///
/// O texto "oficial" fica no estado do presenter; [sincronizarCampos] copia para
/// os campos quando o presenter troca um valor (ex.: espessura padrão do serviço).
mixin ControladoresCampos<C, W extends StatefulWidget> on State<W> {
  final _controladores = <C, TextEditingController>{};

  TextEditingController controlador(C campo, Map<C, String> textos) =>
      _controladores.putIfAbsent(
        campo,
        () => TextEditingController(text: textos[campo] ?? ''),
      );

  /// Chamar fora do build (ex.: num listener do presenter).
  void sincronizarCampos(Map<C, String> textos) {
    _controladores.forEach((campo, controller) {
      final texto = textos[campo] ?? '';
      if (controller.text != texto) controller.text = texto;
    });
  }

  void descartarCampos() {
    for (final c in _controladores.values) {
      c.dispose();
    }
    _controladores.clear();
  }
}
