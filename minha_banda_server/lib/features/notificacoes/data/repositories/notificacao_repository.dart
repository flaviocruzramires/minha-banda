import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/notificacao.dart';

abstract interface class NotificacaoRepository {
  Future<List<Notificacao>> listarPorUsuario(String usuarioId, {int limit = 50});
  Future<Notificacao> criar({
    required String usuarioId,
    required String tipo,
    required String titulo,
    required String corpo,
    Map<String, dynamic>? payload,
  });
  Future<void> marcarComoLida(String id);
  Future<void> marcarTodasComoLidas(String usuarioId);
  Future<int> contarNaoLidas(String usuarioId);
}

class PostgresNotificacaoRepository implements NotificacaoRepository {
  const PostgresNotificacaoRepository(this._conn);
  final Session _conn;

  @override
  Future<List<Notificacao>> listarPorUsuario(String usuarioId, {int limit = 50}) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT * FROM notificacoes WHERE usuario_id = @uid '
        'ORDER BY criada_em DESC LIMIT @lim',
      ),
      parameters: {'uid': usuarioId, 'lim': limit},
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Notificacao> criar({
    required String usuarioId,
    required String tipo,
    required String titulo,
    required String corpo,
    Map<String, dynamic>? payload,
  }) async {
    final id = const Uuid().v4();
    final rows = await _conn.execute(
      Sql.named(
        'INSERT INTO notificacoes (id, usuario_id, tipo, titulo, corpo, payload) '
        'VALUES (@id, @uid, @tipo, @titulo, @corpo, @payload) RETURNING *',
      ),
      parameters: {
        'id': id,
        'uid': usuarioId,
        'tipo': tipo,
        'titulo': titulo,
        'corpo': corpo,
        'payload': payload != null ? jsonEncode(payload) : null,
      },
    );
    return _fromRow(rows.first);
  }

  @override
  Future<void> marcarComoLida(String id) async {
    await _conn.execute(
      Sql.named('UPDATE notificacoes SET lida = true WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<void> marcarTodasComoLidas(String usuarioId) async {
    await _conn.execute(
      Sql.named('UPDATE notificacoes SET lida = true WHERE usuario_id = @uid AND lida = false'),
      parameters: {'uid': usuarioId},
    );
  }

  @override
  Future<int> contarNaoLidas(String usuarioId) async {
    final rows = await _conn.execute(
      Sql.named('SELECT COUNT(*) FROM notificacoes WHERE usuario_id = @uid AND lida = false'),
      parameters: {'uid': usuarioId},
    );
    return (rows.first[0] as num?)?.toInt() ?? 0;
  }

  Notificacao _fromRow(ResultRow row) {
    final c = row.toColumnMap();
    final payloadStr = c['payload'] as String?;
    return Notificacao(
      id: c['id'] as String,
      usuarioId: c['usuario_id'] as String,
      tipo: c['tipo'] as String,
      titulo: c['titulo'] as String,
      corpo: c['corpo'] as String,
      payload: payloadStr != null ? jsonDecode(payloadStr) as Map<String, dynamic> : null,
      lida: c['lida'] as bool,
      criadaEm: _dt(c['criada_em']),
    );
  }
}

DateTime _dt(dynamic v) =>
    v is DateTime ? v : DateTime.parse(v.toString());
