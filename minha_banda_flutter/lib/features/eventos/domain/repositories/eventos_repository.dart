import '../entities/checklist_item.dart';
import '../entities/evento.dart';
import '../entities/evento_confirmacao.dart';

abstract interface class EventosRepository {
  Future<List<Evento>> listar(String bandaId);
  Future<Evento> criar({
    required String bandaId,
    required String tipo,
    required String titulo,
    required DateTime dataHoraInicio,
    DateTime? dataHoraFim,
    String? localId,
    required String status,
    String? notas,
  });
  Future<Evento> atualizar(Evento evento);
  Future<void> deletar(String id);
  Future<List<ChecklistItem>> listarChecklist(String eventoId);
  Future<ChecklistItem> addChecklist({required String eventoId, required String descricao});
  Future<ChecklistItem> toggleChecklist(ChecklistItem item);
  Future<List<EventoConfirmacao>> listarConfirmacoes(String eventoId);
  Future<EventoConfirmacao> confirmarPresenca({
    required String eventoId,
    required String userId,
    required String status,
  });
}
