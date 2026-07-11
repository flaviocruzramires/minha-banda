import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../../../core/middleware/auth_middleware.dart';
import '../service/bloqueio_service.dart';

class BloqueioController {
  BloqueioController(this._service);
  final BloqueioService _service;

  Router get router {
    final r = Router();
    r.get('/bloqueios', _listarBloqueios);
    r.post('/bloqueios', _criar);
    r.delete('/bloqueios/<id>', _deletar);
    r.get('/eventos', _listarEventos);
    return r;
  }

  Future<Response> _listarBloqueios(Request request) async {
    final userId = request.userId;
    final lista = await _service.listarBloqueios(userId);
    return ResponseHelper.ok(lista.map((b) => b.toJson()).toList());
  }

  Future<Response> _criar(Request request) async {
    final userId = request.userId;
    final body = await RequestHelper.parseBody(request);

    final titulo = body['titulo'] as String? ?? '';
    final inicioStr = body['dataHoraInicio'] as String?;
    final fimStr = body['dataHoraFim'] as String?;

    if (inicioStr == null || fimStr == null) {
      throw const ValidationException(
          'dataHoraInicio e dataHoraFim são obrigatórios.');
    }

    final bloqueio = await _service.criar(
      userId: userId,
      titulo: titulo,
      dataHoraInicioStr: inicioStr,
      dataHoraFimStr: fimStr,
    );

    return ResponseHelper.created({'bloqueio': bloqueio.toJson()});
  }

  Future<Response> _deletar(Request request, String id) async {
    final userId = request.userId;
    await _service.deletar(id, userId);
    return ResponseHelper.noContent();
  }

  Future<Response> _listarEventos(Request request) async {
    final userId = request.userId;
    final eventos = await _service.listarEventosDoBanda(userId);
    return ResponseHelper.ok(eventos);
  }
}
