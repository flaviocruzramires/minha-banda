import 'package:postgres/postgres.dart';
import '../../../core/exceptions/app_exception.dart';
import '../data/repositories/bloqueio_repository.dart';
import '../domain/entities/bloqueio.dart';
import '../../eventos/data/repositories/evento_repository.dart';

class BloqueioService {
  // eventoRepo is kept for API compatibility; direct DB query is used for agenda
  const BloqueioService(this._bloqueioRepo, EventoRepository _, this._db);
  final BloqueioRepository _bloqueioRepo;
  final Session _db;

  Future<List<Bloqueio>> listarBloqueios(String userId) =>
      _bloqueioRepo.listByUser(userId);

  Future<Bloqueio> criar({
    required String userId,
    required String titulo,
    required String dataHoraInicioStr,
    required String dataHoraFimStr,
  }) async {
    if (titulo.trim().isEmpty) {
      throw const ValidationException('TÃ­tulo Ã© obrigatÃ³rio.');
    }
    final inicio = DateTime.parse(dataHoraInicioStr);
    final fim = DateTime.parse(dataHoraFimStr);
    if (!fim.isAfter(inicio)) {
      throw const ValidationException(
          'dataHoraFim deve ser posterior a dataHoraInicio.');
    }
    return _bloqueioRepo.create(
      userId: userId,
      titulo: titulo,
      dataHoraInicio: inicio,
      dataHoraFim: fim,
    );
  }

  Future<void> deletar(String id, String userId) async {
    final bloqueio = await _bloqueioRepo.findById(id);
    if (bloqueio == null) {
      throw const NotFoundException('Bloqueio nÃ£o encontrado.');
    }
    if (bloqueio.userId != userId) {
      throw const ForbiddenException('VocÃª nÃ£o pode deletar este bloqueio.');
    }
    await _bloqueioRepo.delete(id);
  }

  /// Lista todos os eventos das bandas em que o user Ã© membro (para agenda visual).
  Future<List<Map<String, dynamic>>> listarEventosDoBanda(String userId) async {
    final rows = await _db.execute(
      Sql.named(
        'SELECT e.id, e.banda_id, e.titulo, e.tipo, e.status, '
        'e.data_hora_inicio, e.data_hora_fim, e.local_id, e.notas '
        'FROM eventos e '
        'JOIN memberships m ON m.banda_id = e.banda_id '
        'WHERE m.user_id = @user AND m.ativo = true '
        'ORDER BY e.data_hora_inicio',
      ),
      parameters: {'user': userId},
    );
    return rows.map((r) {
      final c = r.toColumnMap();
      return {
        'id': c['id'],
        'bandaId': c['banda_id'],
        'titulo': c['titulo'],
        'tipo': c['tipo'],
        'status': c['status'],
        'dataHoraInicio': (c['data_hora_inicio'] as DateTime).toIso8601String(),
        'dataHoraFim': (c['data_hora_fim'] as DateTime?)?.toIso8601String(),
        'localId': c['local_id'],
        'notas': c['notas'],
      };
    }).toList();
  }
}
