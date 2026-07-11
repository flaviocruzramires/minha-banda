import '../../domain/entities/checklist_item.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/evento_confirmacao.dart';
import '../../domain/repositories/eventos_repository.dart';

class MockEventosRepository implements EventosRepository {
  @override
  Future<List<Evento>> listar(String bandaId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    return [
      Evento(id: 'ev1', bandaId: bandaId, tipo: 'show', titulo: 'Show no Bar do João',
          dataHoraInicio: now.add(const Duration(days: 7)), status: 'agendado'),
      Evento(id: 'ev2', bandaId: bandaId, tipo: 'ensaio', titulo: 'Ensaio semanal',
          dataHoraInicio: now.add(const Duration(days: 2)), status: 'agendado'),
      Evento(id: 'ev3', bandaId: bandaId, tipo: 'reuniao', titulo: 'Reunião de pauta',
          dataHoraInicio: now.subtract(const Duration(days: 5)), status: 'realizado'),
    ];
  }

  @override
  Future<Evento> criar({
    required String bandaId,
    required String tipo,
    required String titulo,
    required DateTime dataHoraInicio,
    DateTime? dataHoraFim,
    String? localId,
    required String status,
    String? notas,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Evento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bandaId: bandaId,
      tipo: tipo,
      titulo: titulo,
      dataHoraInicio: dataHoraInicio,
      dataHoraFim: dataHoraFim,
      localId: localId,
      status: status,
      notas: notas,
    );
  }

  @override
  Future<Evento> atualizar(Evento evento) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return evento;
  }

  @override
  Future<void> deletar(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<List<ChecklistItem>> listarChecklist(String eventoId) async => [];

  @override
  Future<ChecklistItem> addChecklist({required String eventoId, required String descricao}) async {
    return ChecklistItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventoId: eventoId,
      descricao: descricao,
    );
  }

  @override
  Future<ChecklistItem> toggleChecklist(ChecklistItem item) async {
    return item.copyWith(concluido: !item.concluido);
  }

  @override
  Future<List<EventoConfirmacao>> listarConfirmacoes(String eventoId) async => [];

  @override
  Future<EventoConfirmacao> confirmarPresenca({
    required String eventoId,
    required String userId,
    required String status,
  }) async {
    return EventoConfirmacao(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventoId: eventoId,
      userId: userId,
      status: status,
    );
  }
}
