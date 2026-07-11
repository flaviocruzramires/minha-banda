import 'package:postgres/postgres.dart';
import '../../eventos/data/repositories/evento_repository.dart';
import '../../agenda/data/repositories/bloqueio_repository.dart';

class ConflitosService {
  const ConflitosService(this._eventoRepo, this._bloqueioRepo, this._db);
  final EventoRepository _eventoRepo;
  final BloqueioRepository _bloqueioRepo;
  final Connection _db;

  /// Verifica conflitos para todos os membros de uma banda em uma data/hora.
  Future<List<Map<String, dynamic>>> verificarConflitosEvento({
    required String bandaId,
    required DateTime inicio,
    required DateTime fim,
  }) async {
    // 1. Busca todos os memberships ativos da banda
    final membRows = await _db.execute(
      Sql.named(
        'SELECT user_id FROM memberships WHERE banda_id = @banda AND ativo = true',
      ),
      parameters: {'banda': bandaId},
    );

    final conflitos = <Map<String, dynamic>>[];

    for (final row in membRows) {
      final userId = row.toColumnMap()['user_id'] as String;

      // 2. Busca eventos em outras bandas no mesmo intervalo
      final eventosConflitantes = await _eventoRepo.getEventosDoUser(
        userId: userId,
        inicio: inicio,
        fim: fim,
      );

      // Filtra para excluir eventos da mesma banda
      final outrosBanda = eventosConflitantes
          .where((e) => e['banda_id'] != bandaId)
          .toList();

      // 3. Busca bloqueios pessoais no mesmo intervalo
      final bloqueiosConflitantes = await _bloqueioRepo.listByUserInInterval(
        userId: userId,
        inicio: inicio,
        fim: fim,
      );

      if (outrosBanda.isNotEmpty || bloqueiosConflitantes.isNotEmpty) {
        conflitos.add({
          'userId': userId,
          'eventosConflitantes': outrosBanda.map((e) => {
                'id': e['id'],
                'bandaId': e['banda_id'],
                'titulo': e['titulo'],
                'dataHoraInicio': (e['data_hora_inicio'] as DateTime)
                    .toIso8601String(),
                'dataHoraFim': (e['data_hora_fim'] as DateTime?)
                    ?.toIso8601String(),
              }).toList(),
          'bloqueiosConflitantes':
              bloqueiosConflitantes.map((b) => b.toJson()).toList(),
        });
      }
    }

    return conflitos;
  }
}
