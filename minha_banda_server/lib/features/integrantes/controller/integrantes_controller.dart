import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../service/integrantes_service.dart';

class IntegrantesController {
  IntegrantesController(this._service);
  final IntegrantesService _service;

  Router get router {
    final r = Router();
    r.get('/', _listar);
    r.get('/<userId>', _buscar);
    r.put('/<userId>', _atualizar);
    r.delete('/<userId>', _remover);
    return r;
  }

  String _getBandaId(Request request) {
    final params =
        request.context['shelf_router/params'] as Map<String, String>?;
    final bandaId = params?['bandaId'] ?? '';
    if (bandaId.isEmpty) {
      throw const ValidationException('bandaId é obrigatório.');
    }
    return bandaId;
  }

  Future<Response> _listar(Request request) async {
    final bandaId = _getBandaId(request);
    final integrantes = await _service.listar(bandaId);
    return ResponseHelper.ok(integrantes);
  }

  Future<Response> _buscar(Request request, String userId) async {
    final bandaId = _getBandaId(request);
    final membro = await _service.buscarMembro(bandaId: bandaId, userId: userId);
    return ResponseHelper.ok(membro);
  }

  Future<Response> _atualizar(Request request, String userId) async {
    final bandaId = _getBandaId(request);
    final body = await RequestHelper.parseBody(request);

    await _service.atualizar(
      bandaId: bandaId,
      userId: userId,
      instrumento: body['instrumento'] as String?,
      apelido: body['apelido'] as String?,
      telefone: body['telefone'] as String?,
      papel: body['papel'] as String?,
    );

    final membro = await _service.buscarMembro(bandaId: bandaId, userId: userId);
    return ResponseHelper.ok(membro);
  }

  Future<Response> _remover(Request request, String userId) async {
    final bandaId = _getBandaId(request);
    await _service.remover(bandaId: bandaId, userId: userId);
    return ResponseHelper.noContent();
  }
}
