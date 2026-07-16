import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/local.dart';
import '../../domain/entities/responsavel_local.dart';

abstract interface class LocalRepository {
  Future<List<Local>> listAll({String? cidade});
  Future<Local?> findById(String id);
  Future<Local> create({
    required String nome,
    required String cidade,
    required String criadoPor,
    String? endereco,
    String? tipo,
    int? capacidade,
    String? contato,
    bool temSom,
    bool temCamarim,
    String? notas,
  });
  Future<Local> update({
    required String id,
    String? nome,
    String? endereco,
    String? cidade,
    String? tipo,
    int? capacidade,
    String? contato,
    bool? temSom,
    bool? temCamarim,
    String? notas,
  });
  Future<void> delete(String id);
  Future<void> addResponsavel({
    required String localId,
    required String userId,
    String papel,
  });
  Future<List<ResponsavelLocal>> getResponsaveis(String localId);
  Future<List<Local>> listByResponsavel(String userId);
}

class PostgresLocalRepository implements LocalRepository {
  const PostgresLocalRepository(this._conn);
  final Session _conn;

  @override
  Future<List<Local>> listAll({String? cidade}) async {
    final rows = cidade != null
        ? await _conn.execute(
            Sql.named(
              'SELECT id, nome, endereco, cidade, tipo, capacidade, contato, '
              'tem_som, tem_camarim, notas, criado_por, criado_em '
              'FROM locais WHERE lower(cidade) = lower(@cidade) ORDER BY nome',
            ),
            parameters: {'cidade': cidade},
          )
        : await _conn.execute(
            'SELECT id, nome, endereco, cidade, tipo, capacidade, contato, '
            'tem_som, tem_camarim, notas, criado_por, criado_em '
            'FROM locais ORDER BY nome',
          );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Local?> findById(String id) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT id, nome, endereco, cidade, tipo, capacidade, contato, '
        'tem_som, tem_camarim, notas, criado_por, criado_em '
        'FROM locais WHERE id = @id',
      ),
      parameters: {'id': id},
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<Local> create({
    required String nome,
    required String cidade,
    required String criadoPor,
    String? endereco,
    String? tipo,
    int? capacidade,
    String? contato,
    bool temSom = false,
    bool temCamarim = false,
    String? notas,
  }) async {
    final id = const Uuid().v4();
    final rows = await _conn.execute(
      Sql.named(
        'INSERT INTO locais (id, nome, endereco, cidade, tipo, capacidade, '
        'contato, tem_som, tem_camarim, notas, criado_por) '
        'VALUES (@id, @nome, @endereco, @cidade, @tipo, @capacidade, '
        '@contato, @temSom, @temCamarim, @notas, @criadoPor) '
        'RETURNING id, nome, endereco, cidade, tipo, capacidade, contato, '
        'tem_som, tem_camarim, notas, criado_por, criado_em',
      ),
      parameters: {
        'id': id,
        'nome': nome.trim(),
        'endereco': endereco,
        'cidade': cidade.trim(),
        'tipo': tipo ?? 'bar',
        'capacidade': capacidade,
        'contato': contato,
        'temSom': temSom,
        'temCamarim': temCamarim,
        'notas': notas,
        'criadoPor': criadoPor,
      },
    );
    return _fromRow(rows.first);
  }

  @override
  Future<Local> update({
    required String id,
    String? nome,
    String? endereco,
    String? cidade,
    String? tipo,
    int? capacidade,
    String? contato,
    bool? temSom,
    bool? temCamarim,
    String? notas,
  }) async {
    final rows = await _conn.execute(
      Sql.named(
        'UPDATE locais SET '
        'nome = COALESCE(@nome, nome), '
        'endereco = COALESCE(@endereco, endereco), '
        'cidade = COALESCE(@cidade, cidade), '
        'tipo = COALESCE(@tipo, tipo), '
        'capacidade = COALESCE(@capacidade, capacidade), '
        'contato = COALESCE(@contato, contato), '
        'tem_som = COALESCE(@temSom, tem_som), '
        'tem_camarim = COALESCE(@temCamarim, tem_camarim), '
        'notas = COALESCE(@notas, notas), '
        'atualizado_em = now() '
        'WHERE id = @id '
        'RETURNING id, nome, endereco, cidade, tipo, capacidade, contato, '
        'tem_som, tem_camarim, notas, criado_por, criado_em',
      ),
      parameters: {
        'id': id,
        'nome': nome,
        'endereco': endereco,
        'cidade': cidade,
        'tipo': tipo,
        'capacidade': capacidade,
        'contato': contato,
        'temSom': temSom,
        'temCamarim': temCamarim,
        'notas': notas,
      },
    );
    return _fromRow(rows.first);
  }

  @override
  Future<void> delete(String id) async {
    await _conn.execute(
      Sql.named('DELETE FROM locais WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<void> addResponsavel({
    required String localId,
    required String userId,
    String papel = 'GERENTE',
  }) async {
    await _conn.execute(
      Sql.named(
        'INSERT INTO responsaveis_local (id, local_id, user_id, papel) '
        'VALUES (@id, @localId, @userId, @papel) '
        'ON CONFLICT (local_id, user_id) DO NOTHING',
      ),
      parameters: {
        'id': const Uuid().v4(),
        'localId': localId,
        'userId': userId,
        'papel': papel,
      },
    );
  }

  @override
  Future<List<ResponsavelLocal>> getResponsaveis(String localId) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT id, local_id, user_id, papel '
        'FROM responsaveis_local WHERE local_id = @localId',
      ),
      parameters: {'localId': localId},
    );
    return rows.map((r) {
      final c = r.toColumnMap();
      return ResponsavelLocal(
        id: c['id'] as String,
        localId: c['local_id'] as String,
        userId: c['user_id'] as String,
        papel: c['papel'] as String,
      );
    }).toList();
  }

  @override
  Future<List<Local>> listByResponsavel(String userId) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT l.id, l.nome, l.endereco, l.cidade, l.tipo, l.capacidade, '
        'l.contato, l.tem_som, l.tem_camarim, l.notas, l.criado_por, l.criado_em '
        'FROM locais l '
        'JOIN responsaveis_local rl ON rl.local_id = l.id '
        'WHERE rl.user_id = @userId ORDER BY l.nome',
      ),
      parameters: {'userId': userId},
    );
    return rows.map(_fromRow).toList();
  }

  Local _fromRow(ResultRow row) {
    final c = row.toColumnMap();
    return Local(
      id: c['id'] as String,
      nome: c['nome'] as String,
      endereco: c['endereco'] as String?,
      cidade: c['cidade'] as String,
      tipo: c['tipo'] as String,
      capacidade: (c['capacidade'] as num?)?.toInt(),
      contato: c['contato'] as String?,
      temSom: c['tem_som'] as bool,
      temCamarim: c['tem_camarim'] as bool,
      notas: c['notas'] as String?,
      criadoPor: c['criado_por'] as String,
      criadoEm: _dt(c['criado_em']),
    );
  }
}

DateTime _dt(dynamic v) =>
    v is DateTime ? v : DateTime.parse(v.toString());
