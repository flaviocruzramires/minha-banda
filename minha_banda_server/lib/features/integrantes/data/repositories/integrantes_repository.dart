import 'package:postgres/postgres.dart';

abstract interface class IntegrantesRepository {
  Future<List<Map<String, dynamic>>> listByBanda(String bandaId);
  Future<Map<String, dynamic>?> findMembro({
    required String bandaId,
    required String userId,
  });
  Future<void> updateMembro({
    required String bandaId,
    required String userId,
    String? instrumento,
    String? apelido,
    String? telefone,
    String? papel,
  });
  Future<void> removerMembro({
    required String bandaId,
    required String userId,
  });
}

class PostgresIntegrantesRepository implements IntegrantesRepository {
  const PostgresIntegrantesRepository(this._conn);
  final Connection _conn;

  @override
  Future<List<Map<String, dynamic>>> listByBanda(String bandaId) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT m.id, m.banda_id, m.user_id, m.papel, m.instrumento, '
        'm.apelido, m.telefone, m.ativo, '
        'u.nome_artistico, u.email '
        'FROM memberships m '
        'JOIN users u ON u.id = m.user_id '
        'WHERE m.banda_id = @banda AND m.ativo = true',
      ),
      parameters: {'banda': bandaId},
    );
    return rows.map((r) => r.toColumnMap()).toList();
  }

  @override
  Future<Map<String, dynamic>?> findMembro({
    required String bandaId,
    required String userId,
  }) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT m.id, m.banda_id, m.user_id, m.papel, m.instrumento, '
        'm.apelido, m.telefone, m.ativo, '
        'u.nome_artistico, u.email '
        'FROM memberships m '
        'JOIN users u ON u.id = m.user_id '
        'WHERE m.banda_id = @banda AND m.user_id = @user AND m.ativo = true',
      ),
      parameters: {'banda': bandaId, 'user': userId},
    );
    if (rows.isEmpty) return null;
    return rows.first.toColumnMap();
  }

  @override
  Future<void> updateMembro({
    required String bandaId,
    required String userId,
    String? instrumento,
    String? apelido,
    String? telefone,
    String? papel,
  }) async {
    await _conn.execute(
      Sql.named(
        'UPDATE memberships SET '
        'instrumento = COALESCE(@instrumento, instrumento), '
        'apelido = COALESCE(@apelido, apelido), '
        'telefone = COALESCE(@telefone, telefone), '
        'papel = COALESCE(@papel, papel) '
        'WHERE banda_id = @banda AND user_id = @user AND ativo = true',
      ),
      parameters: {
        'banda': bandaId,
        'user': userId,
        'instrumento': instrumento,
        'apelido': apelido,
        'telefone': telefone,
        'papel': papel,
      },
    );
  }

  @override
  Future<void> removerMembro({
    required String bandaId,
    required String userId,
  }) async {
    await _conn.execute(
      Sql.named(
        'UPDATE memberships SET ativo = false '
        'WHERE banda_id = @banda AND user_id = @user',
      ),
      parameters: {'banda': bandaId, 'user': userId},
    );
  }
}
