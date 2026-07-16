import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/evento.dart';

abstract interface class EventoRepository {
  Future<List<Evento>> listByBanda(String bandaId, {String? status});
  Future<Evento?> findById(String id);
  Future<Evento> create({
    required String bandaId,
    required String tipo,
    required String titulo,
    required DateTime dataHoraInicio,
    DateTime? dataHoraFim,
    String? localId,
    required String criadoPor,
  });
  Future<Evento> update({
    required String id,
    String? titulo,
    String? tipo,
    DateTime? dataHoraInicio,
    DateTime? dataHoraFim,
    String? localId,
    String? status,
    String? notas,
    double? valorCache,
    bool clearValorCache = false,
  });
  Future<void> delete(String id);

  // ConfirmaÃ§Ãµes
  Future<List<EventoConfirmacao>> getConfirmacoes(String eventoId);
  Future<void> upsertConfirmacao({
    required String eventoId,
    required String userId,
    required String status,
  });

  // Checklist
  Future<List<ChecklistItem>> getChecklist(String eventoId);
  Future<ChecklistItem> addChecklistItem({
    required String eventoId,
    required String descricao,
  });
  Future<void> toggleChecklistItem({
    required String itemId,
    required bool concluido,
  });
  Future<void> deleteChecklistItem(String itemId);

  // Para conflitos: eventos de um user em um intervalo
  Future<List<Map<String, dynamic>>> getEventosDoUser({
    required String userId,
    required DateTime inicio,
    required DateTime fim,
  });
}

class PostgresEventoRepository implements EventoRepository {
  const PostgresEventoRepository(this._conn);
  final Session _conn;

  @override
  Future<List<Evento>> listByBanda(String bandaId, {String? status}) async {
    final sql = status != null
        ? 'SELECT * FROM eventos WHERE banda_id = @banda AND status = @status ORDER BY data_hora_inicio'
        : 'SELECT * FROM eventos WHERE banda_id = @banda ORDER BY data_hora_inicio';
    final params = status != null
        ? {'banda': bandaId, 'status': status}
        : {'banda': bandaId};
    final rows = await _conn.execute(Sql.named(sql), parameters: params);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Evento?> findById(String id) async {
    final rows = await _conn.execute(
      Sql.named('SELECT * FROM eventos WHERE id = @id LIMIT 1'),
      parameters: {'id': id},
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<Evento> create({
    required String bandaId,
    required String tipo,
    required String titulo,
    required DateTime dataHoraInicio,
    DateTime? dataHoraFim,
    String? localId,
    required String criadoPor,
  }) async {
    final id = const Uuid().v4();
    final rows = await _conn.execute(
      Sql.named(
        'INSERT INTO eventos (id, banda_id, tipo, titulo, data_hora_inicio, data_hora_fim, local_id, criado_por) '
        'VALUES (@id, @banda, @tipo, @titulo, @inicio, @fim, @local, @criado_por) '
        'RETURNING *',
      ),
      parameters: {
        'id': id,
        'banda': bandaId,
        'tipo': tipo,
        'titulo': titulo.trim(),
        'inicio': dataHoraInicio,
        'fim': dataHoraFim,
        'local': localId,
        'criado_por': criadoPor,
      },
    );
    return _fromRow(rows.first);
  }

  @override
  Future<Evento> update({
    required String id,
    String? titulo,
    String? tipo,
    DateTime? dataHoraInicio,
    DateTime? dataHoraFim,
    String? localId,
    String? status,
    String? notas,
    double? valorCache,
    bool clearValorCache = false,
  }) async {
    final sets = <String>[];
    final params = <String, dynamic>{'id': id};

    if (titulo != null) {
      sets.add('titulo = @titulo');
      params['titulo'] = titulo.trim();
    }
    if (tipo != null) {
      sets.add('tipo = @tipo');
      params['tipo'] = tipo;
    }
    if (dataHoraInicio != null) {
      sets.add('data_hora_inicio = @inicio');
      params['inicio'] = dataHoraInicio;
    }
    if (dataHoraFim != null) {
      sets.add('data_hora_fim = @fim');
      params['fim'] = dataHoraFim;
    }
    if (localId != null) {
      sets.add('local_id = @local');
      params['local'] = localId;
    }
    if (status != null) {
      sets.add('status = @status');
      params['status'] = status;
    }
    if (notas != null) {
      sets.add('notas = @notas');
      params['notas'] = notas;
    }
    if (clearValorCache) {
      sets.add('valor_cache = NULL');
    } else if (valorCache != null) {
      sets.add('valor_cache = @valorCache');
      params['valorCache'] = valorCache;
    }
    sets.add('atualizado_em = now()');

    final rows = await _conn.execute(
      Sql.named(
        'UPDATE eventos SET ${sets.join(', ')} WHERE id = @id RETURNING *',
      ),
      parameters: params,
    );
    return _fromRow(rows.first);
  }

  @override
  Future<void> delete(String id) async {
    await _conn.execute(
      Sql.named('DELETE FROM eventos WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<List<EventoConfirmacao>> getConfirmacoes(String eventoId) async {
    final rows = await _conn.execute(
      Sql.named('SELECT * FROM evento_confirmacoes WHERE evento_id = @evento'),
      parameters: {'evento': eventoId},
    );
    return rows.map((r) {
      final c = r.toColumnMap();
      return EventoConfirmacao(
        id: c['id'] as String,
        eventoId: c['evento_id'] as String,
        userId: c['user_id'] as String,
        status: c['status'] as String,
      );
    }).toList();
  }

  @override
  Future<void> upsertConfirmacao({
    required String eventoId,
    required String userId,
    required String status,
  }) async {
    await _conn.execute(
      Sql.named(
        'INSERT INTO evento_confirmacoes (id, evento_id, user_id, status) '
        'VALUES (@id, @evento, @user, @status) '
        'ON CONFLICT (evento_id, user_id) DO UPDATE SET status = @status',
      ),
      parameters: {
        'id': const Uuid().v4(),
        'evento': eventoId,
        'user': userId,
        'status': status,
      },
    );
  }

  @override
  Future<List<ChecklistItem>> getChecklist(String eventoId) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT * FROM evento_checklist WHERE evento_id = @evento ORDER BY criado_em',
      ),
      parameters: {'evento': eventoId},
    );
    return rows.map((r) {
      final c = r.toColumnMap();
      return ChecklistItem(
        id: c['id'] as String,
        eventoId: c['evento_id'] as String,
        descricao: c['descricao'] as String,
        concluido: c['concluido'] as bool,
      );
    }).toList();
  }

  @override
  Future<ChecklistItem> addChecklistItem({
    required String eventoId,
    required String descricao,
  }) async {
    final id = const Uuid().v4();
    final rows = await _conn.execute(
      Sql.named(
        'INSERT INTO evento_checklist (id, evento_id, descricao) '
        'VALUES (@id, @evento, @descricao) RETURNING *',
      ),
      parameters: {
        'id': id,
        'evento': eventoId,
        'descricao': descricao.trim(),
      },
    );
    final c = rows.first.toColumnMap();
    return ChecklistItem(
      id: c['id'] as String,
      eventoId: c['evento_id'] as String,
      descricao: c['descricao'] as String,
      concluido: c['concluido'] as bool,
    );
  }

  @override
  Future<void> toggleChecklistItem({
    required String itemId,
    required bool concluido,
  }) async {
    await _conn.execute(
      Sql.named(
        'UPDATE evento_checklist SET concluido = @concluido WHERE id = @id',
      ),
      parameters: {'id': itemId, 'concluido': concluido},
    );
  }

  @override
  Future<void> deleteChecklistItem(String itemId) async {
    await _conn.execute(
      Sql.named('DELETE FROM evento_checklist WHERE id = @id'),
      parameters: {'id': itemId},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getEventosDoUser({
    required String userId,
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT e.id, e.banda_id, e.titulo, e.data_hora_inicio, e.data_hora_fim '
        'FROM eventos e '
        'JOIN memberships m ON m.banda_id = e.banda_id '
        'WHERE m.user_id = @user AND m.ativo = true '
        'AND e.data_hora_inicio < @fim AND (e.data_hora_fim IS NULL OR e.data_hora_fim > @inicio)',
      ),
      parameters: {'user': userId, 'inicio': inicio, 'fim': fim},
    );
    return rows.map((r) => r.toColumnMap()).toList();
  }

  Evento _fromRow(ResultRow row) {
    final c = row.toColumnMap();
    return Evento(
      id: c['id'] as String,
      bandaId: c['banda_id'] as String,
      tipo: c['tipo'] as String,
      titulo: c['titulo'] as String,
      dataHoraInicio: _dt(c['data_hora_inicio']),
      dataHoraFim: c['data_hora_fim'] != null ? _dt(c['data_hora_fim']) : null,
      localId: c['local_id'] as String?,
      status: c['status'] as String,
      notas: c['notas'] as String?,
      valorCache: (c['valor_cache'] as num?)?.toDouble(),
      criadoPor: c['criado_por'] as String,
      criadoEm: _dt(c['criado_em']),
      atualizadoEm: _dt(c['atualizado_em']),
    );
  }
}

DateTime _dt(dynamic v) =>
    v is DateTime ? v : DateTime.parse(v.toString());
