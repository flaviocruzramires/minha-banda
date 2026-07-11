import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../service/conflitos_service.dart';

class ConflitosController {
  ConflitosController(this._service);
  final ConflitosService _service;

  Router get router {
    final r = Router();
    r.post('/verificar', _verificar);
    return r;
  }

  Future<Response> _verificar(Request request) async {
    final body = await RequestHelper.parseBody(request);

    final bandaId = body['bandaId'] as String?;
    final inicioStr = body['dataHoraInicio'] as String?;
    final fimStr = body['dataHoraFim'] as String?;

    if (bandaId == null || inicioStr == null || fimStr == null) {
      throw const ValidationException(
          'bandaId, dataHoraInicio e dataHoraFim são obrigatórios.');
    }

    final conflitos = await _service.verificarConflitosEvento(
      bandaId: bandaId,
      inicio: DateTime.parse(inicioStr),
      fim: DateTime.parse(fimStr),
    );

    return ResponseHelper.ok({'conflitos': conflitos});
  }
}
