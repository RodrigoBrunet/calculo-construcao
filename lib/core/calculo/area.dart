/// Como o usuário informa a área: pelas medidas ou pelo total em m².
enum ModoArea {
  medidas('Largura × comprimento'),
  total('Área total');

  const ModoArea(this.rotulo);
  final String rotulo;
}

/// Área em m²: largura × comprimento no modo [ModoArea.medidas], senão [area].
double calcularArea(
  ModoArea modo, {
  double largura = 0,
  double comprimento = 0,
  double area = 0,
}) => switch (modo) {
  ModoArea.medidas => largura * comprimento,
  ModoArea.total => area,
};
