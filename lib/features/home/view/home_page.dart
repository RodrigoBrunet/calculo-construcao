import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/big_action_button.dart';

/// Um botão da home. Cada novo cálculo entra nesta lista.
class _ItemHome {
  const _ItemHome(this.icone, this.titulo, this.rota, [this.subtitulo]);
  final IconData icone;
  final String titulo;
  final String rota;
  final String? subtitulo;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _itens = <_ItemHome>[
    _ItemHome(
      Icons.foundation,
      'Materiais',
      AppRoutes.materiais,
      'Tijolo, reboco, concreto, telha',
    ),
    _ItemHome(Icons.format_paint, 'Tintas', AppRoutes.tintas, 'Latas e galões'),
    _ItemHome(
      Icons.grid_on,
      'Argamassa',
      AppRoutes.argamassa,
      'Argamassa e rejunte',
    ),
    _ItemHome(
      Icons.history,
      'Histórico',
      AppRoutes.historico,
      'Cálculos salvos',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    final colunas = largura >= 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Cálculo Construção')),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(AppDimens.espacoM),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colunas,
            mainAxisSpacing: AppDimens.espacoM,
            crossAxisSpacing: AppDimens.espacoM,
            childAspectRatio: 0.9,
          ),
          itemCount: _itens.length,
          itemBuilder: (context, index) {
            final item = _itens[index];
            return BigActionButton(
              icone: item.icone,
              titulo: item.titulo,
              subtitulo: item.subtitulo,
              onPressed: () => Navigator.pushNamed(context, item.rota),
            );
          },
        ),
      ),
    );
  }
}
