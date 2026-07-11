import 'package:equatable/equatable.dart';

class Evento extends Equatable {
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
  });

  final String id, bandaId, tipo, titulo, status;
  final DateTime dataHoraInicio;
  final DateTime? dataHoraFim;
  final String? localId, notas;

  factory Evento.fromJson(Map<String, dynamic> j) => Evento(
        id: j['id'] as String,
        bandaId: j['bandaId'] as String,
        tipo: j['tipo'] as String,
        titulo: j['titulo'] as String,
        status: (j['status'] as String?) ?? 'agendado',
        dataHoraInicio: DateTime.parse(j['dataHoraInicio'] as String),
        dataHoraFim: j['dataHoraFim'] != null
            ? DateTime.parse(j['dataHoraFim'] as String)
            : null,
        localId: j['localId'] as String?,
        notas: j['notas'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bandaId': bandaId,
        'tipo': tipo,
        'titulo': titulo,
        'status': status,
        'dataHoraInicio': dataHoraInicio.toIso8601String(),
        'dataHoraFim': dataHoraFim?.toIso8601String(),
        'localId': localId,
        'notas': notas,
      };

  @override
  List<Object?> get props => [id, bandaId, tipo, titulo, status, dataHoraInicio, dataHoraFim, localId, notas];
}
