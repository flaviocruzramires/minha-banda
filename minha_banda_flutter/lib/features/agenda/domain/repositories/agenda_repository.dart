import '../../../eventos/domain/entities/evento.dart';
import '../entities/bloqueio.dart';

abstract interface class AgendaRepository {
  Future<List<Evento>> listarEventos();
  Future<List<Bloqueio>> listarBloqueios(String userId);
  Future<Bloqueio> adicionarBloqueio({
    required String userId,
    required String titulo,
    required DateTime dataHoraInicio,
    required DateTime dataHoraFim,
  });
  Future<void> removerBloqueio(String id);
}
