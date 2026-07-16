import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/banda.dart';

abstract interface class BandaRepository {
  Future<Banda?> findByNome(String nome);
  Future<Banda> create({
    required String nome,
    required String generoMusical,
    required String cidade,
    required int corHex,
    required String criadoPor,
  });
  Future<void> adicionarMembro({
    required String bandaId,
    required String userId,
    required String papel,
  });
  Future<String> criarConvite({
    required String bandaId,
    required String email,
    required String token,
  });
  Future<bool> isMembro(String bandaId, String userId);
  Future<Banda> update({
    required String bandaId,
    String? nome,
    String? generoMusical,
    String? cidade,
  });
}

class PostgresBandaRepository implements BandaRepository {
  const PostgresBandaRepository(this._conn);
  final Session _conn;

  @override
  Future<Banda?> findByNome(String nome) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT id, nome, genero_musical, cidade, cor_hex, criado_por, criado_em '
        'FROM bandas WHERE lower(nome) = lower(@nome) LIMIT 1',
      ),
      parameters: {'nome': nome},
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<Banda> create({
    required String nome,
    required String generoMusical,
    required String cidade,
    required int corHex,
    required String criadoPor,
  }) async {
    final id = const Uuid().v4();
    final rows = await _conn.execute(
      Sql.named(
        'INSERT INTO bandas (id, nome, genero_musical, cidade, cor_hex, criado_por) '
        'VALUES (@id, @nome, @genero, @cidade, @cor, @criado_por) '
        'RETURNING id, nome, genero_musical, cidade, cor_hex, criado_por, criado_em',
      ),
      parameters: {
        'id': id,
        'nome': nome.trim(),
        'genero': generoMusical.trim(),
        'cidade': cidade.trim(),
        'cor': corHex,
        'criado_por': criadoPor,
      },
    );
    return _fromRow(rows.first);
  }

  @override
  Future<void> adicionarMembro({
    required String bandaId,
    required String userId,
    required String papel,
  }) async {
    await _conn.execute(
      Sql.named(
        'INSERT INTO memberships (id, banda_id, user_id, papel) '
        'VALUES (@id, @banda, @user, @papel) '
        'ON CONFLICT (banda_id, user_id) DO NOTHING',
      ),
      parameters: {
        'id': const Uuid().v4(),
        'banda': bandaId,
        'user': userId,
        'papel': papel,
      },
    );
  }

  @override
  Future<String> criarConvite({
    required String bandaId,
    required String email,
    required String token,
  }) async {
    await _conn.execute(
      Sql.named(
        'INSERT INTO convites (id, banda_id, email, token) '
        'VALUES (@id, @banda, @email, @token) '
        'ON CONFLICT (banda_id, email) DO UPDATE SET token = @token, criado_em = now()',
      ),
      parameters: {
        'id': const Uuid().v4(),
        'banda': bandaId,
        'email': email.toLowerCase(),
        'token': token,
      },
    );
    return token;
  }

  @override
  Future<bool> isMembro(String bandaId, String userId) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT 1 FROM memberships WHERE banda_id = @banda AND user_id = @user AND ativo = true LIMIT 1',
      ),
      parameters: {'banda': bandaId, 'user': userId},
    );
    return rows.isNotEmpty;
  }

  @override
  Future<Banda> update({
    required String bandaId,
    String? nome,
    String? generoMusical,
    String? cidade,
  }) async {
    final sets = <String>[];
    final params = <String, dynamic>{'id': bandaId};

    if (nome != null && nome.trim().isNotEmpty) {
      sets.add('nome = @nome');
      params['nome'] = nome.trim();
    }
    if (generoMusical != null) {
      sets.add('genero_musical = @genero');
      params['genero'] = generoMusical.trim();
    }
    if (cidade != null) {
      sets.add('cidade = @cidade');
      params['cidade'] = cidade.trim();
    }

    if (sets.isEmpty) {
      final rows = await _conn.execute(
        Sql.named('SELECT id, nome, genero_musical, cidade, cor_hex, criado_por, criado_em FROM bandas WHERE id = @id'),
        parameters: {'id': bandaId},
      );
      return _fromRow(rows.first);
    }

    final rows = await _conn.execute(
      Sql.named(
        'UPDATE bandas SET ${sets.join(', ')} WHERE id = @id '
        'RETURNING id, nome, genero_musical, cidade, cor_hex, criado_por, criado_em',
      ),
      parameters: params,
    );
    return _fromRow(rows.first);
  }

  Banda _fromRow(ResultRow row) {
    final c = row.toColumnMap();
    return Banda(
      id: c['id'].toString(),
      nome: c['nome'] as String,
      generoMusical: c['genero_musical'] as String,
      cidade: c['cidade'] as String,
      corHex: (c['cor_hex'] as num).toInt(),
      criadoPor: c['criado_por'].toString(),
      criadoEm: _dt(c['criado_em']),
    );
  }
}

DateTime _dt(dynamic v) =>
    v is DateTime ? v : DateTime.parse(v.toString());
