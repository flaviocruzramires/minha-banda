import '../../../core/exceptions/app_exception.dart';
import '../data/repositories/musica_repository.dart';
import '../domain/entities/musica.dart';
import '../domain/entities/setlist_item.dart';

class MusicaService {
  const MusicaService(this._repo);
  final MusicaRepository _repo;

  Future<List<Musica>> listarByBanda(String bandaId) =>
      _repo.listByBanda(bandaId);

  Future<Musica> buscarPorId(String id) async {
    final musica = await _repo.findById(id);
    if (musica == null) throw const NotFoundException('Música não encontrada.');
    return musica;
  }

  Future<Musica> criar({
    required String bandaId,
    required String titulo,
    required String userId,
    String? artistaOriginal,
    String? tonalidade,
    int? bpm,
    int? duracaoSeg,
    List<String> tags = const [],
    String? letra,
    String? cifra,
    String? linkReferencia,
    String? notasArranjo,
    String status = 'em_aprendizado',
  }) async {
    if (titulo.trim().isEmpty) {
      throw const ValidationException('Título da música é obrigatório.');
    }
    return _repo.create(
      bandaId: bandaId,
      titulo: titulo,
      criadoPor: userId,
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

  Future<Musica> atualizar({
    required String id,
    required String userId,
    String? titulo,
    String? artistaOriginal,
    String? tonalidade,
    int? bpm,
    int? duracaoSeg,
    List<String>? tags,
    String? letra,
    String? cifra,
    String? linkReferencia,
    String? notasArranjo,
    String? status,
  }) async {
    await buscarPorId(id);
    if (titulo != null && titulo.trim().isEmpty) {
      throw const ValidationException('Título da música não pode ser vazio.');
    }
    return _repo.update(
      id: id,
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

  Future<void> deletar({
    required String id,
    required String userId,
  }) async {
    await buscarPorId(id);
    await _repo.delete(id);
  }

  Future<List<SetlistItem>> getSetlist(String eventoId) =>
      _repo.getSetlist(eventoId);

  Future<void> setSetlist({
    required String eventoId,
    required List<String> musicaIds,
    required String userId,
  }) =>
      _repo.setSetlist(eventoId: eventoId, musicaIds: musicaIds);
}
