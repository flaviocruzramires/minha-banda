import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../service/auth_service.dart';

class AuthController {
  AuthController(this._service);
  final AuthService _service;

  Router get router {
    final r = Router();
    r.post('/register', _register);
    r.post('/login', _login);
    return r;
  }

  Future<Response> _register(Request request) async {
    final body = await RequestHelper.parseBody(request);

    final nome = body['nomeArtistico'] as String? ?? '';
    final email = body['email'] as String? ?? '';
    final senha = body['senha'] as String? ?? '';

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      throw const ValidationException(
          'nomeArtistico, email e senha são obrigatórios.');
    }

    final result = await _service.registrar(
      nomeArtistico: nome,
      email: email,
      senha: senha,
    );

    return ResponseHelper.created({
      'user': result.user.toJson(),
      'token': result.token,
    });
  }

  Future<Response> _login(Request request) async {
    final body = await RequestHelper.parseBody(request);

    final email = body['email'] as String? ?? '';
    final senha = body['senha'] as String? ?? '';

    final result = await _service.login(email: email, senha: senha);

    return ResponseHelper.ok({
      'user': result.user.toJson(),
      'token': result.token,
    });
  }
}
