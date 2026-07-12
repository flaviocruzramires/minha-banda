import 'package:equatable/equatable.dart';

class SetlistEntry extends Equatable {
  const SetlistEntry({
    required this.musicaId,
    required this.titulo,
    this.artistaOriginal,
    this.duracaoSeg,
    required this.posicao,
  });

  final String musicaId;
  final String titulo;
  final String? artistaOriginal;
  final int? duracaoSeg;
  final int posicao;

  @override
  List<Object?> get props => [musicaId, titulo, artistaOriginal, duracaoSeg, posicao];
}
