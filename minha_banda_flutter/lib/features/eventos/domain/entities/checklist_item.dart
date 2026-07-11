import 'package:equatable/equatable.dart';

class ChecklistItem extends Equatable {
  const ChecklistItem({
    required this.id,
    required this.eventoId,
    required this.descricao,
    this.concluido = false,
  });

  final String id, eventoId, descricao;
  final bool concluido;

  factory ChecklistItem.fromJson(Map<String, dynamic> j) => ChecklistItem(
        id: j['id'] as String,
        eventoId: j['eventoId'] as String,
        descricao: j['descricao'] as String,
        concluido: (j['concluido'] as bool?) ?? false,
      );

  ChecklistItem copyWith({bool? concluido}) => ChecklistItem(
        id: id,
        eventoId: eventoId,
        descricao: descricao,
        concluido: concluido ?? this.concluido,
      );

  @override
  List<Object?> get props => [id, eventoId, descricao, concluido];
}
