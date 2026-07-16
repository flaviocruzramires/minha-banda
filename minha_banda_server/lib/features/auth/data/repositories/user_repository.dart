import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/app_user.dart';

abstract interface class UserRepository {
  Future<AppUser?> findByEmail(String email);
  Future<AppUser> create({
    required String nomeArtistico,
    required String email,
    required String senhaHash,
  });
  Future<AppUser> updateNome({required String userId, required String nomeArtistico});
}

class PostgresUserRepository implements UserRepository {
  const PostgresUserRepository(this._conn);
  final Connection _conn;

  @override
  Future<AppUser?> findByEmail(String email) async {
    final rows = await _conn.execute(
      Sql.named(
        'SELECT id, nome_artistico, email, senha_hash, criado_em '
        'FROM users WHERE email = @email LIMIT 1',
      ),
      parameters: {'email': email.toLowerCase()},
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<AppUser> create({
    required String nomeArtistico,
    required String email,
    required String senhaHash,
  }) async {
    final id = const Uuid().v4();
    final rows = await _conn.execute(
      Sql.named(
        'INSERT INTO users (id, nome_artistico, email, senha_hash) '
        'VALUES (@id, @nome, @email, @hash) '
        'RETURNING id, nome_artistico, email, senha_hash, criado_em',
      ),
      parameters: {
        'id': id,
        'nome': nomeArtistico,
        'email': email.toLowerCase(),
        'hash': senhaHash,
      },
    );
    return _fromRow(rows.first);
  }

  @override
  Future<AppUser> updateNome({required String userId, required String nomeArtistico}) async {
    final rows = await _conn.execute(
      Sql.named(
        'UPDATE users SET nome_artistico = @nome WHERE id = @id '
        'RETURNING id, nome_artistico, email, senha_hash, criado_em',
      ),
      parameters: {'id': userId, 'nome': nomeArtistico.trim()},
    );
    return _fromRow(rows.first);
  }

  AppUser _fromRow(ResultRow row) {
    final cols = row.toColumnMap();
    return AppUser(
      id: cols['id'] as String,
      nomeArtistico: cols['nome_artistico'] as String,
      email: cols['email'] as String,
      senhaHash: cols['senha_hash'] as String,
      criadoEm: _dt(cols['criado_em']),
    );
  }
}

DateTime _dt(dynamic v) =>
    v is DateTime ? v : DateTime.parse(v.toString());
