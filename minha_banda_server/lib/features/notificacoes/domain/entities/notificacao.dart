class Notificacao {
  const Notificacao({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    required this.corpo,
    this.payload,
    required this.lida,
    required this.criadaEm,
  });

  final String id;
  final String usuarioId;
  final String tipo;
  final String titulo;
  final String corpo;
  final Map<String, dynamic>? payload;
  final bool lida;
  final DateTime criadaEm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuarioId': usuarioId,
        'tipo': tipo,
        'titulo': titulo,
        'corpo': corpo,
        'payload': payload,
        'lida': lida,
        'criadaEm': criadaEm.toIso8601String(),
      };
}
