import 'package:equatable/equatable.dart';

class Bloqueio extends Equatable {
  const Bloqueio({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.dataHoraInicio,
    required this.dataHoraFim,
  });

  final String id, userId, titulo;
  final DateTime dataHoraInicio, dataHoraFim;

  factory Bloqueio.fromJson(Map<String, dynamic> j) => Bloqueio(
        id: j['id'] as String,
        userId: j['userId'] as String,
        titulo: j['titulo'] as String,
        dataHoraInicio: DateTime.parse(j['dataHoraInicio'] as String),
        dataHoraFim: DateTime.parse(j['dataHoraFim'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'titulo': titulo,
        'dataHoraInicio': dataHoraInicio.toIso8601String(),
        'dataHoraFim': dataHoraFim.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, userId, titulo, dataHoraInicio, dataHoraFim];
}
