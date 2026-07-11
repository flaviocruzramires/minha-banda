import 'package:equatable/equatable.dart';

class Musica extends Equatable {
  const Musica({
    required this.id,
    required this.bandaId,
    required this.titulo,
    this.artistaOriginal,
    this.tonalidade,
    this.bpm,
    this.duracaoSeg,
    this.tags = const [],
    this.letra,
    this.cifra,
    this.linkReferencia,
    this.notasArranjo,
    required this.status,
  });

  final String id, bandaId, titulo, status;
  final String? artistaOriginal, tonalidade, letra, cifra, linkReferencia, notasArranjo;
  final int? bpm, duracaoSeg;
  final List<String> tags;

  factory Musica.fromJson(Map<String, dynamic> j) => Musica(
        id: j['id'] as String,
        bandaId: j['bandaId'] as String,
        titulo: j['titulo'] as String,
        status: (j['status'] as String?) ?? 'em_aprendizado',
        artistaOriginal: j['artistaOriginal'] as String?,
        tonalidade: j['tonalidade'] as String?,
        bpm: j['bpm'] as int?,
        duracaoSeg: j['duracaoSeg'] as int?,
        tags: (j['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        letra: j['letra'] as String?,
        cifra: j['cifra'] as String?,
        linkReferencia: j['linkReferencia'] as String?,
        notasArranjo: j['notasArranjo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bandaId': bandaId,
        'titulo': titulo,
        'status': status,
        'artistaOriginal': artistaOriginal,
        'tonalidade': tonalidade,
        'bpm': bpm,
        'duracaoSeg': duracaoSeg,
        'tags': tags,
        'letra': letra,
        'cifra': cifra,
        'linkReferencia': linkReferencia,
        'notasArranjo': notasArranjo,
      };

  @override
  List<Object?> get props => [
        id, bandaId, titulo, status, artistaOriginal,
        tonalidade, bpm, duracaoSeg, tags, letra,
        cifra, linkReferencia, notasArranjo,
      ];
}
