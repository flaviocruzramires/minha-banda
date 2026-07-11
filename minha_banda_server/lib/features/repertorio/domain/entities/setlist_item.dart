class SetlistItem {
  const SetlistItem({
    required this.id,
    required this.eventoId,
    required this.musicaId,
    required this.posicao,
  });

  final String id;
  final String eventoId;
  final String musicaId;
  final int posicao;

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventoId': eventoId,
        'musicaId': musicaId,
        'posicao': posicao,
      };
}
