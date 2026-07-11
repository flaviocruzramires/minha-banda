import 'package:equatable/equatable.dart';

class MusicaTeleprompter extends Equatable {
  const MusicaTeleprompter({
    required this.titulo,
    this.artistaOriginal,
    this.letra,
    this.cifra,
    required this.posicao,
  });

  final String titulo;
  final String? artistaOriginal, letra, cifra;
  final int posicao;

  factory MusicaTeleprompter.fromJson(Map<String, dynamic> j) => MusicaTeleprompter(
        titulo: j['titulo'] as String,
        artistaOriginal: j['artistaOriginal'] as String?,
        letra: j['letra'] as String?,
        cifra: j['cifra'] as String?,
        posicao: j['posicao'] as int,
      );

  @override
  List<Object?> get props => [titulo, artistaOriginal, letra, cifra, posicao];
}
