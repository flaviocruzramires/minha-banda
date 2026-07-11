class Evento {
  const Evento({
    required this.id,
    required this.bandaId,
    required this.tipo,
    required this.titulo,
    required this.dataHoraInicio,
    this.dataHoraFim,
    this.localId,
    required this.status,
    this.notas,
    required this.criadoPor,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  final String id;
  final String bandaId;
  final String tipo;
  final String titulo;
  final DateTime dataHoraInicio;
  final DateTime? dataHoraFim;
  final String? localId;
  final String status;
  final String? notas;
  final String criadoPor;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bandaId': bandaId,
        'tipo': tipo,
        'titulo': titulo,
        'dataHoraInicio': dataHoraInicio.toIso8601String(),
        'dataHoraFim': dataHoraFim?.toIso8601String(),
        'localId': localId,
        'status': status,
        'notas': notas,
        'criadoPor': criadoPor,
        'criadoEm': criadoEm.toIso8601String(),
        'atualizadoEm': atualizadoEm.toIso8601String(),
      };
}

class EventoConfirmacao {
  const EventoConfirmacao({
    required this.id,
    required this.eventoId,
    required this.userId,
    required this.status,
  });

  final String id;
  final String eventoId;
  final String userId;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventoId': eventoId,
        'userId': userId,
        'status': status,
      };
}

class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.eventoId,
    required this.descricao,
    required this.concluido,
  });

  final String id;
  final String eventoId;
  final String descricao;
  final bool concluido;

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventoId': eventoId,
        'descricao': descricao,
        'concluido': concluido,
      };
}
