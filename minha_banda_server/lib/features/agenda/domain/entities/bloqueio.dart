class Bloqueio {
  const Bloqueio({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.dataHoraInicio,
    required this.dataHoraFim,
    required this.criadoEm,
  });

  final String id;
  final String userId;
  final String titulo;
  final DateTime dataHoraInicio;
  final DateTime dataHoraFim;
  final DateTime criadoEm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'titulo': titulo,
        'dataHoraInicio': dataHoraInicio.toIso8601String(),
        'dataHoraFim': dataHoraFim.toIso8601String(),
        'criadoEm': criadoEm.toIso8601String(),
      };
}
