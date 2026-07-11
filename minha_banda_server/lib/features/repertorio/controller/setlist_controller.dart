import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../../../core/middleware/auth_middleware.dart';
import '../service/musica_service.dart';

class SetlistController {
  SetlistController(this._service);
  final MusicaService _service;

  Router get router {
    final r = Router();
    r.get('/', _getSetlist);
    r.put('/', _setSetlist);
    return r;
  }

  Future<Response> _getSetlist(Request req) async {
    final params = req.context['shelf_router/params'] as Map<String, String>?;
    final eventoId = params?['eventoId'] ?? '';
    if (eventoId.isEmpty) {
      throw const ValidationException('eventoId é obrigatório.');
    }
    final itens = await _service.getSetlist(eventoId);
    return ResponseHelper.ok({'setlist': itens.map((i) => i.toJson()).toList()});
  }

  Future<Response> _setSetlist(Request req) async {
    final userId = req.userId;
    final params = req.context['shelf_router/params'] as Map<String, String>?;
    final eventoId = params?['eventoId'] ?? '';
    if (eventoId.isEmpty) {
      throw const ValidationException('eventoId é obrigatório.');
    }
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
