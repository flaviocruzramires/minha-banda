import '../../../core/exceptions/app_exception.dart';
import '../data/repositories/integrantes_repository.dart';

class IntegrantesService {
  const IntegrantesService(this._repo);
  final IntegrantesRepository _repo;

  Future<List<Map<String, dynamic>>> listar(String bandaId) =>
      _repo.listByBanda(bandaId);

  Future<Map<String, dynamic>> buscarMembro({
    required String bandaId,
    required String userId,
  }) async {
    final membro = await _repo.findMembro(bandaId: bandaId, userId: userId);
    if (membro == null) throw const NotFoundException('Integrante não encontrado.');
    return membro;
  }

  Future<void> atualizar({
    required String bandaId,
    required String userId,
    String? instrumento,
    String? apelido,
    String? telefone,
    String? papel,
  }) async {
    await buscarMembro(bandaId: bandaId, userId: userId);
    await _repo.updateMembro(
      bandaId: bandaId,
      userId: userId,
      instrumento: instrumento,
      apelido: apelido,
      telefone: telefone,
      papel: papel,
    );
  }

  Future<void> remover({
    required String bandaId,
    required String userId,
  }) async {
    await buscarMembro(bandaId: bandaId, userId: userId);
    await _repo.removerMembro(bandaId: bandaId, userId: userId);
  }
}
