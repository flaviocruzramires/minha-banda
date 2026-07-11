class Musica {
  const Musica({
    required this.id,
    required this.bandaId,
    required this.titulo,
    this.artistaOriginal,
    this.tonalidade,
    this.bpm,
    this.duracaoSeg,
    required this.tags,
    this.letra,
    this.cifra,
    this.linkReferencia,
    this.notasArranjo,
    required this.status,
    required this.criadoPor,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  final String id;
  final String bandaId;
  final String titulo;
  final String? artistaOriginal;
  final String? tonalidade;
  final int? bpm;
  final int? duracaoSeg;
  final List<String> tags;
  final String? letra;
  final String? cifra;
  final String? linkReferencia;
  final String? notasArranjo;
  final String status;
  final String criadoPor;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bandaId': bandaId,
        'titulo': titulo,
        'artistaOriginal': artistaOriginal,
        'tonalidade': tonalidade,
        'bpm': bpm,
        'duracaoSeg': duracaoSeg,
        'tags': tags,
        'letra': letra,
        'cifra': cifra,
        'linkReferencia': linkReferencia,
        'notasArranjo': notasArranjo,
        'status': status,
        'criadoPor': criadoPor,
        'criadoEm': criadoEm.toIso8601String(),
        'atualizadoEm': atualizadoEm.toIso8601String(),
      };
}
