import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../../core/config/app_config.dart';
import '../../../core/exceptions/app_exception.dart';
import '../data/repositories/user_repository.dart';
import '../domain/entities/app_user.dart';

class AuthService {
  const AuthService(this._users);
  final UserRepository _users;

  Future<({AppUser user, String token})> registrar({
    required String nomeArtistico,
    required String email,
    required String senha,
  }) async {
    _validarCampos(nomeArtistico: nomeArtistico, email: email, senha: senha);

    final existente = await _users.findByEmail(email);
    if (existente != null) {
      throw const ConflictException('Este e-mail já está cadastrado.');
    }

    final hash = BCrypt.hashpw(senha, BCrypt.gensalt());
    final user = await _users.create(
      nomeArtistico: nomeArtistico.trim(),
      email: email.trim().toLowerCase(),
      senhaHash: hash,
    );

    final token = _gerarToken(user.id);
    return (user: user, token: token);
  }

  Future<({AppUser user, String token})> login({
    required String email,
    required String senha,
  }) async {
    if (email.isEmpty || senha.isEmpty) {
      throw const ValidationException('E-mail e senha são obrigatórios.');
    }

    final user = await _users.findByEmail(email);
    if (user == null || !BCrypt.checkpw(senha, user.senhaHash)) {
      throw const UnauthorizedException('E-mail ou senha incorretos.');
    }

    return (user: user, token: _gerarToken(user.id));
  }

  String _gerarToken(String userId) {
    final config = AppConfig.instance;
    final jwt = JWT({'sub': userId});
    return jwt.sign(
      SecretKey(config.jwtSecret),
      expiresIn: Duration(minutes: config.jwtExpiresMinutes),
    );
  }

  void _validarCampos({
    required String nomeArtistico,
    required String email,
    required String senha,
  }) {
    if (nomeArtistico.trim().isEmpty) {
      throw const ValidationException('Nome artístico é obrigatório.');
    }
    if (!email.contains('@') || email.trim().isEmpty) {
      throw const ValidationException('E-mail inválido.');
    }
    if (senha.length < 8) {
      throw const ValidationException('Senha deve ter no mínimo 8 caracteres.');
    }
  }
}
