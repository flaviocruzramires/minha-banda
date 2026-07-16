import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../../../core/middleware/auth_middleware.dart';
import '../service/banda_service.dart';

class BandaController {
  BandaController(this._service, {required this.baseUrl});
  final BandaService _service;
  final String baseUrl;

  Router get router {
    final r = Router();
    r.post('/', _criar);
    r.patch('/<bandaId>', _atualizar);
    r.post('/<bandaId>/convites', _convidar);
    r.get('/<bandaId>/link-convite', _linkConvite);
    return r;
  }

  Future<Response> _criar(Request request) async {
    final userId = request.userId;
    final body = await RequestHelper.parseBody(request);

    final nome = body['nome'] as String? ?? '';
    final genero = body['generoMusical'] as String? ?? '';
    final cidade = body['cidade'] as String? ?? '';
    final corHex = body['corHex'] as int? ?? 0xFF7A1F3D;

    if (nome.isEmpty || genero.isEmpty || cidade.isEmpty) {
      throw const ValidationException('nome, generoMusical e cidade são obrigatórios.');
    }

    final banda = await _service.criar(
      nome: nome,
      generoMusical: genero,
      cidade: cidade,
      corHex: corHex,
      userId: userId,
    );

    final link = _service.gerarLinkConvite(banda.id, baseUrl);

    return ResponseHelper.created({
      'banda': banda.toJson(),
      'linkConvite': link,
    });
  }

  Future<Response> _atualizar(Request request, String bandaId) async {
    final userId = request.userId;
    final body = await RequestHelper.parseBody(request);

    final nome = body['nome'] as String?;
    final genero = body['generoMusical'] as String?;
    final cidade = body['cidade'] as String?;

    final banda = await _service.atualizar(
      bandaId: bandaId,
      userId: userId,
      nome: nome,
      generoMusical: genero,
      cidade: cidade,
    );

    return ResponseHelper.ok({'banda': banda.toJson()});
  }

  Future<Response> _convidar(Request request, String bandaId) async {
    final userId = request.userId;
    final body = await RequestHelper.parseBody(request);

    final email = body['email'] as String? ?? '';
    if (email.isEmpty) {
      throw const ValidationException('email é obrigatório.');
    }

    await _service.convidarPorEmail(
      bandaId: bandaId,
      email: email,
      userId: userId,
    );

    return ResponseHelper.created({'message': 'Convite enviado para $email.'});
  }

  Future<Response> _linkConvite(Request request, String bandaId) async {
    final link = _service.gerarLinkConvite(bandaId, baseUrl);
    return ResponseHelper.ok({'linkConvite': link});
  }
}
