import 'dart:convert';

/// Um cálculo salvo no histórico.
///
/// [entradas] e [resultado] são mapas livres para que cada tipo de cálculo
/// guarde o que precisar sem mudar a tabela.
class CalculoSalvo {
  const CalculoSalvo({
    this.id,
    required this.tipo,
    required this.titulo,
    required this.entradas,
    required this.resultado,
    required this.criadoEm,
  });

  final int? id;
  final String tipo;
  final String titulo;
  final Map<String, dynamic> entradas;
  final Map<String, dynamic> resultado;
  final DateTime criadoEm;

  factory CalculoSalvo.fromMap(Map<String, Object?> map) => CalculoSalvo(
    id: map['id'] as int?,
    tipo: map['tipo'] as String,
    titulo: map['titulo'] as String,
    entradas:
        jsonDecode(map['entradas_json'] as String) as Map<String, dynamic>,
    resultado:
        jsonDecode(map['resultado_json'] as String) as Map<String, dynamic>,
    criadoEm: DateTime.fromMillisecondsSinceEpoch(map['criado_em'] as int),
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'tipo': tipo,
    'titulo': titulo,
    'entradas_json': jsonEncode(entradas),
    'resultado_json': jsonEncode(resultado),
    'criado_em': criadoEm.millisecondsSinceEpoch,
  };

  CalculoSalvo copyWith({int? id}) => CalculoSalvo(
    id: id ?? this.id,
    tipo: tipo,
    titulo: titulo,
    entradas: entradas,
    resultado: resultado,
    criadoEm: criadoEm,
  );
}
