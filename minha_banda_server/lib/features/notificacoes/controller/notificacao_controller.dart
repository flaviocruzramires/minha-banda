import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../core/helpers/response_helper.dart';
import '../../../core/middleware/auth_middleware.dart';
import '../service/notificacao_service.dart';

class NotificacaoController {
  NotificacaoController(this._service);
  final NotificacaoService _service;

  Router get router {
    final r = Router();
    r.get('/', _listar);
    r.get('/nao-lidas/count', _contarNaoLidas);
    r.patch('/<id>/lida', _marcarLida);
    r.patch('/marcar-todas-lidas', _marcarTodasLidas);
    return r;
  }

  Future<Response> _listar(Request request) async {
    final userId = request.userId;
    final lista = await _service.listar(userId);
    return ResponseHelper.ok(lista.map((n) => n.toJson()).toList());
  }

  Future<Response> _contarNaoLidas(Request request) async {
    final userId = request.userId;
    final count = await _service.contarNaoLidas(userId);
    return ResponseHelper.ok({'count': count});
  }

  Future<Response> _marcarLida(Request request, String id) async {
    await _service.marcarComoLida(id);
    return ResponseHelper.ok({'message': 'Notificação marcada como lida.'});
  }

  Future<Response> _marcarTodasLidas(Request request) async {
    final userId = request.userId;
    await _service.marcarTodasComoLidas(userId);
    return ResponseHelper.ok({'message': 'Todas as notificações marcadas como lidas.'});
  }
}
