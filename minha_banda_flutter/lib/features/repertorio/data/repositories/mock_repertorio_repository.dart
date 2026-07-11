import '../../domain/entities/musica.dart';
import '../../domain/repositories/repertorio_repository.dart';

class MockRepertorioRepository implements RepertorioRepository {
  @override
  Future<List<Musica>> listar(String bandaId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      Musica(id: '1', bandaId: bandaId, titulo: 'Bohemian Rhapsody', artistaOriginal: 'Queen', tonalidade: 'Bb', bpm: 72, status: 'pronto_para_show'),
      Musica(id: '2', bandaId: bandaId, titulo: 'Hotel California', artistaOriginal: 'Eagles', tonalidade: 'Bm', bpm: 75, status: 'em_aprendizado'),
      Musica(id: '3', bandaId: bandaId, titulo: 'Stairway to Heaven', artistaOriginal: 'Led Zeppelin', tonalidade: 'Am', bpm: 82, status: 'pronto_para_show'),
    ];
  }

  @override
  Future<Musica> criar({
    required String bandaId,
    required String titulo,
    String? artistaOriginal,
    String? tonalidade,
    int? bpm,
    int? duracaoSeg,
    List<String> tags = const [],
    String? letra,
    String? cifra,
    String? linkReferencia,
    String? notasArranjo,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Musica(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bandaId: bandaId,
      titulo: titulo,
      artistaOriginal: artistaOriginal,
      tonalidade: tonalidade,
      bpm: bpm,
      duracaoSeg: duracaoSeg,
      tags: tags,
      letra: letra,
      cifra: cifra,
      linkReferencia: linkReferencia,
      notasArranjo: notasArranjo,
      status: status,
    );
  }

  @override
  Future<Musica> atualizar(Musica musica) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return musica;
  }

  @override
  Future<void> deletar(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
