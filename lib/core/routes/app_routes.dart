import 'package:flutter/material.dart';

import '../../features/argamassa/view/argamassa_page.dart';
import '../../features/historico/view/historico_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/materiais/view/materiais_page.dart';
import '../../features/tintas/view/tintas_page.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const materiais = '/materiais';
  static const tintas = '/tintas';
  static const argamassa = '/argamassa';
  static const historico = '/historico';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      home => const HomePage(),
      materiais => const MateriaisPage(),
      tintas => const TintasPage(),
      argamassa => const ArgamassaPage(),
      historico => const HistoricoPage(),
      _ => const HomePage(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
