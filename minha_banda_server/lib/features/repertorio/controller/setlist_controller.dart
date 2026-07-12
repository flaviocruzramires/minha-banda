import 'package:shelf/shelf.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../../../core/middleware/auth_middleware.dart';
import '../service/musica_service.dart';

class SetlistController {
  SetlistController(this._service);
  final MusicaService _service;

  Future<Response> getSetlist(Request req, String eventoId) async {
    final itens = await _service.getSetlist(eventoId);
    return ResponseHelper.ok({'setlist': itens.map((i) => i.toJson()).toList()});
  }

  Future<Response> setSetlist(Request req, String eventoId) async {
    final userId = req.userId;
    final body = await RequestHelper.parseBody(req);
    final musicaIds = (body['musicaIds'] as List?)?.cast<String>() ?? [];

    await _service.setSetlist(
      eventoId: eventoId,
      musicaIds: musicaIds,
      userId: userId,
    );
    return ResponseHelper.ok({'message': 'Setlist atualizado com sucesso.'});
  }
}
