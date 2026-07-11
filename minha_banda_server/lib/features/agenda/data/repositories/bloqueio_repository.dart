import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/bloqueio.dart';

abstract interface class BloqueioRepository {
  Future<List<Bloqueio>> listByUser(String userId);
  Future<Bloqueio> create({
    required String userId,
    required String titulo,
    required DateTime dataHoraInicio,
    required DateTime dataHoraFim,
  });
  Future<Bloqueio?> findById(String id);
  Future<void> delete(String id);

  // Para conflitos: bloqueios de um user em um intervalo
  Future<List<Bloqueio>> listByUserInInterval({
    required String userId,
    required DateTime inicio,
    required DateTime fim,
  });
}

class PostgresBloqueioRepository implements BloqueioRepository {
  const PostgresBloqueioRepository(this._conn);
  final Connection _conn;

  @override
  Future<List<Bloqueio>> listByUser(String userId) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT * FROM bloqueios_pessoais WHERE user_id = @user ORDER BY data_hora_inicio',
      ),
      parameters: {'user': userId},
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Bloqueio> create({
    required String userId,
    required String titulo,
    required DateTime dataHoraInicio,
    required DateTime dataHoraFim,
  }) async {
    final id = const Uuid().v4();
    final rows = await _conn.execute(
      Sql.named(
        'INSERT INTO bloqueios_pessoais (id, user_id, titulo, data_hora_inicio, data_hora_fim) '
        'VALUES (@id, @user, @titulo, @inicio, @fim) RETURNING *',
      ),
      parameters: {
        'id': id,
        'user': userId,
        'titulo': titulo.trim(),
        'inicio': dataHoraInicio,
        'fim': dataHoraFim,
      },
    );
    return _fromRow(rows.first);
  }

  @override
  Future<Bloqueio?> findById(String id) async {
    final rows = await _conn.execute(
      Sql.named('SELECT * FROM bloqueios_pessoais WHERE id = @id LIMIT 1'),
      parameters: {'id': id},
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<void> delete(String id) async {
    await _conn.execute(
      Sql.named('DELETE FROM bloqueios_pessoais WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<List<Bloqueio>> listByUserInInterval({
    required String userId,
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT * FROM bloqueios_pessoais '
        'WHERE user_id = @user AND data_hora_inicio < @fim AND data_hora_fim > @inicio',
      ),
      parameters: {'user': userId, 'inicio': inicio, 'fim': fim},
    );
    return rows.map(_fromRow).toList();
  }

  Bloqueio _fromRow(ResultRow row) {
    final c = row.toColumnMap();
    return Bloqueio(
      id: c['id'] as String,
      userId: c['user_id'] as String,
      titulo: c['titulo'] as String,
      dataHoraInicio: c['data_hora_inicio'] as DateTime,
      dataHoraFim: c['data_hora_fim'] as DateTime,
      criadoEm: c['criado_em'] as DateTime,
    );
  }
}
