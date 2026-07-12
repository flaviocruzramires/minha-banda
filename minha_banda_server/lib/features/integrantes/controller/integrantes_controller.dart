import 'package:shelf/shelf.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../service/integrantes_service.dart';

class IntegrantesController {
  IntegrantesController(this._service);
  final IntegrantesService _service;

  Future<Response> listar(Request request, String bandaId) async {
    final integrantes = await _service.listar(bandaId);
    return ResponseHelper.ok(integrantes);
  }

  Future<Response> buscar(Request request, String bandaId, String userId) async {
    final membro = await _service.buscarMembro(bandaId: bandaId, userId: userId);
    return ResponseHelper.ok(membro);
  }

  Future<Response> atualizar(Request request, String bandaId, String userId) async {
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

  Future<Response> remover(Request request, String bandaId, String userId) async {
    await _service.remover(bandaId: bandaId, userId: userId);
    return ResponseHelper.noContent();
  }
}
