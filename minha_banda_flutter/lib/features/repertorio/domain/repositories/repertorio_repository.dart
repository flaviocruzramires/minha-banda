import '../entities/musica.dart';

abstract interface class RepertorioRepository {
  Future<List<Musica>> listar(String bandaId);
  Future<Musica> criar({
    required String bandaId,
    required String titulo,
    String? artistaOriginal,
    String? tonalidade,
    int? bpm,
    int? duracaoSeg,
    List<String> tags,
    String? letra,
    String? cifra,
    String? linkReferencia,
    String? notasArranjo,
    required String status,
  });
  Future<Musica> atualizar(Musica musica);
  Future<void> deletar(String id);
}
