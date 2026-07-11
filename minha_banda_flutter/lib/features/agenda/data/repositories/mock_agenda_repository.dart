import '../../../eventos/domain/entities/evento.dart';
import '../../domain/entities/bloqueio.dart';
import '../../domain/repositories/agenda_repository.dart';

class MockAgendaRepository implements AgendaRepository {
  @override
  Future<List<Evento>> listarEventos() async => [];

  @override
  Future<List<Bloqueio>> listarBloqueios(String userId) async {
    final now = DateTime.now();
    return [
      Bloqueio(id: 'b1', userId: userId, titulo: 'Viagem', dataHoraInicio: now.add(const Duration(days: 3)), dataHoraFim: now.add(const Duration(days: 5))),
      Bloqueio(id: 'b2', userId: userId, titulo: 'Consulta médica', dataHoraInicio: now.add(const Duration(days: 10)), dataHoraFim: now.add(const Duration(hours: 242))),
    ];
  }

  @override
  Future<Bloqueio> adicionarBloqueio({
    required String userId,
    required String titulo,
    required DateTime dataHoraInicio,
    required DateTime dataHoraFim,
  }) async {
    return Bloqueio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      titulo: titulo,
      dataHoraInicio: dataHoraInicio,
      dataHoraFim: dataHoraFim,
    );
  }

  @override
  Future<void> removerBloqueio(String id) async {}
}
