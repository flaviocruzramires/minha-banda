import 'package:equatable/equatable.dart';

class EventoConfirmacao extends Equatable {
  const EventoConfirmacao({
    required this.id,
    required this.eventoId,
    required this.userId,
    required this.status,
  });

  final String id, eventoId, userId, status;

  factory EventoConfirmacao.fromJson(Map<String, dynamic> j) => EventoConfirmacao(
        id: j['id'] as String,
        eventoId: j['eventoId'] as String,
        userId: j['userId'] as String,
        status: j['status'] as String,
      );

  @override
  List<Object?> get props => [id, eventoId, userId, status];
}
