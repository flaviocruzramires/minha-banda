import '../../../core/exceptions/app_exception.dart';
import '../data/repositories/evento_repository.dart';
import '../domain/entities/evento.dart';

class EventoService {
  const EventoService(this._repo);
  final EventoRepository _repo;

  Future<List<Evento>> listarByBanda(String bandaId, {String? status}) =>
      _repo.listByBanda(bandaId, status: status);

  Future<Evento> buscarPorId(String id) async {
    final evento = await _repo.findById(id);
    if (evento == null) throw const NotFoundException('Evento não encontrado.');
    return evento;
  }

  Future<Evento> criar({
    required String bandaId,
    required String tipo,
    required String titulo,
    required DateTime dataHoraInicio,
    DateTime? dataHoraFim,
    String? localId,
    required String userId,
  }) async {
    if (!['show', 'ensaio'].contains(tipo)) {
      throw const ValidationException("Tipo deve ser 'show' ou 'ensaio'.");
    }
    if (titulo.trim().isEmpty) {
      throw const ValidationException('Título é obrigatório.');
    }
    return _repo.create(
      bandaId: bandaId,
      tipo: tipo,
      titulo: titulo,
      dataHoraInicio: dataHoraInicio,
      dataHoraFim: dataHoraFim,
      localId: localId,
      criadoPor: userId,
    );
  }

  Future<Evento> atualizar({
    required String id,
    String? titulo,
    String? tipo,
    DateTime? dataHoraInicio,
    DateTime? dataHoraFim,
    String? localId,
    String? status,
    String? notas,
  }) async {
    await buscarPorId(id);
    if (tipo != null && !['show', 'ensaio'].contains(tipo)) {
      throw const ValidationException("Tipo deve ser 'show' ou 'ensaio'.");
    }
    if (status != null &&
        !['proposto', 'confirmado', 'realizado', 'cancelado'].contains(status)) {
      throw const ValidationException(
          "Status inválido. Use: proposto, confirmado, realizado, cancelado.");
    }
    return _repo.update(
      id: id,
      titulo: titulo,
      tipo: tipo,
      dataHoraInicio: dataHoraInicio,
      dataHoraFim: dataHoraFim,
      localId: localId,
      status: status,
      notas: notas,
    );
  }

  Future<void> deletar(String id) async {
    await buscarPorId(id);
    await _repo.delete(id);
  }

  Future<List<EventoConfirmacao>> listarConfirmacoes(String eventoId) =>
      _repo.getConfirmacoes(eventoId);

  Future<void> confirmarPresenca({
    required String eventoId,
    required String userId,
    required String status,
  }) async {
    if (!['confirmado', 'recusado', 'pendente'].contains(status)) {
      throw const ValidationException(
          "Status deve ser 'confirmado', 'recusado' ou 'pendente'.");
    }
    await buscarPorId(eventoId);
    await _repo.upsertConfirmacao(
      eventoId: eventoId,
      userId: userId,
      status: status,
    );
  }

  Future<List<ChecklistItem>> listarChecklist(String eventoId) =>
      _repo.getChecklist(eventoId);

  Future<ChecklistItem> addChecklistItem({
    required String eventoId,
    required String descricao,
  }) async {
    if (descricao.trim().isEmpty) {
      throw const ValidationException('Descrição é obrigatória.');
    }
    await buscarPorId(eventoId);
    return _repo.addChecklistItem(eventoId: eventoId, descricao: descricao);
  }

  Future<void> toggleChecklistItem({
    required String itemId,
    required bool concluido,
  }) =>
      _repo.toggleChecklistItem(itemId: itemId, concluido: concluido);

  Future<void> deleteChecklistItem(String itemId) =>
      _repo.deleteChecklistItem(itemId);
}
