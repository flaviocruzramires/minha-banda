import 'package:equatable/equatable.dart';

class EventoConflitante extends Equatable {
  const EventoConflitante({
    required this.id,
    required this.bandaId,
    required this.titulo,
    required this.dataHoraInicio,
  });

  final String id, bandaId, titulo;
  final DateTime dataHoraInicio;

  factory EventoConflitante.fromJson(Map<String, dynamic> j) => EventoConflitante(
        id: j['id'] as String,
        bandaId: j['bandaId'] as String,
        titulo: j['titulo'] as String,
        dataHoraInicio: DateTime.parse(j['dataHoraInicio'] as String),
      );

  @override
  List<Object?> get props => [id, bandaId, titulo, dataHoraInicio];
}

class Conflito extends Equatable {
  const Conflito({
    required this.userId,
    required this.eventosConflitantes,
    required this.bloqueiosConflitantes,
  });

  final String userId;
  final List<EventoConflitante> eventosConflitantes;
  final List<String> bloqueiosConflitantes;

  factory Conflito.fromJson(Map<String, dynamic> j) => Conflito(
        userId: j['userId'] as String,
        eventosConflitantes: ((j['eventosConflitantes'] as List<dynamic>?) ?? [])
            .map((e) => EventoConflitante.fromJson(e as Map<String, dynamic>))
            .toList(),
        bloqueiosConflitantes: ((j['bloqueiosConflitantes'] as List<dynamic>?) ?? [])
            .map((b) => (b as Map<String, dynamic>)['titulo'] as String? ?? 'Bloqueio pessoal')
            .toList(),
      );

  bool get temConflito => eventosConflitantes.isNotEmpty || bloqueiosConflitantes.isNotEmpty;

  @override
  List<Object?> get props => [userId, eventosConflitantes, bloqueiosConflitantes];
}
