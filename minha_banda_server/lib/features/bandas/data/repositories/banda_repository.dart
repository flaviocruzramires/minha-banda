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
}

class PostgresBandaRepository implements BandaRepository {
  const PostgresBandaRepository(this._conn);
  final Connection _conn;

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

  Banda _fromRow(ResultRow row) {
    final c = row.toColumnMap();
    return Banda(
      id: c['id'] as String,
      nome: c['nome'] as String,
      generoMusical: c['genero_musical'] as String,
      cidade: c['cidade'] as String,
      corHex: c['cor_hex'] as int,
      criadoPor: c['criado_por'] as String,
      criadoEm: c['criado_em'] as DateTime,
    );
  }
}
