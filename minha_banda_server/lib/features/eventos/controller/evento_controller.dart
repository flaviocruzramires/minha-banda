import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../../../core/middleware/auth_middleware.dart';
import '../service/evento_service.dart';

/// Rotas para /bandas/:bandaId/eventos e /eventos/:id
class EventoController {
  EventoController(this._service);
  final EventoService _service;

  /// Montado em /eventos/
  Router get router {
    final r = Router();
    r.get('/<id>', buscar);
    r.put('/<id>', atualizar);
    r.delete('/<id>', deletar);
    return r;
  }

  Future<Response> listar(Request request, String bandaId) async {
    final status = request.url.queryParameters['status'];
    final eventos = await _service.listarByBanda(bandaId, status: status);
    return ResponseHelper.ok(eventos.map((e) => e.toJson()).toList());
  }

  Future<Response> criar(Request request, String bandaId) async {
    final userId = request.userId;
    final body = await RequestHelper.parseBody(request);

    final tipo = body['tipo'] as String? ?? 'show';
    final titulo = body['titulo'] as String? ?? '';
    final inicioStr = body['dataHoraInicio'] as String?;
    final fimStr = body['dataHoraFim'] as String?;
    final localId = body['localId'] as String?;

    if (inicioStr == null) {
      throw const ValidationException('dataHoraInicio é obrigatório.');
    }

    final evento = await _service.criar(
      bandaId: bandaId,
      tipo: tipo,
      titulo: titulo,
      dataHoraInicio: DateTime.parse(inicioStr),
      dataHoraFim: fimStr != null ? DateTime.parse(fimStr) : null,
      localId: localId,
      userId: userId,
    );

    return ResponseHelper.created({'evento': evento.toJson()});
  }

  Future<Response> buscar(Request request, String id) async {
    final evento = await _service.buscarPorId(id);
    return ResponseHelper.ok({'evento': evento.toJson()});
  }

  Future<Response> atualizar(Request request, String id) async {
    final body = await RequestHelper.parseBody(request);

    final titulo = body['titulo'] as String?;
    final tipo = body['tipo'] as String?;
    final inicioStr = body['dataHoraInicio'] as String?;
    final fimStr = body['dataHoraFim'] as String?;
    final localId = body['localId'] as String?;
    final status = body['status'] as String?;
    final notas = body['notas'] as String?;
    final valorCacheRaw = body['valorCache'];
    final double? valorCache = valorCacheRaw != null ? (valorCacheRaw as num).toDouble() : null;
    final bool clearValorCache = body.containsKey('valorCache') && valorCacheRaw == null;

    final evento = await _service.atualizar(
      id: id,
      titulo: titulo,
      tipo: tipo,
      dataHoraInicio: inicioStr != null ? DateTime.parse(inicioStr) : null,
      dataHoraFim: fimStr != null ? DateTime.parse(fimStr) : null,
      localId: localId,
      status: status,
      notas: notas,
      valorCache: valorCache,
      clearValorCache: clearValorCache,
    );

    return ResponseHelper.ok({'evento': evento.toJson()});
  }

  Future<Response> deletar(Request request, String id) async {
    await _service.deletar(id);
    return ResponseHelper.noContent();
  }
}

/// Rotas para /eventos/:eventoId/confirmacoes e /eventos/:eventoId/checklist
class EventoActionsController {
  EventoActionsController(this._service);
  final EventoService _service;

  Future<Response> listarConfirmacoes(
      Request request, String eventoId) async {
    final lista = await _service.listarConfirmacoes(eventoId);
    return ResponseHelper.ok(lista.map((c) => c.toJson()).toList());
  }

  Future<Response> confirmar(Request request, String eventoId) async {
    final userId = request.userId;
    final body = await RequestHelper.parseBody(request);
    final status = body['status'] as String? ?? '';

    await _service.confirmarPresenca(
      eventoId: eventoId,
      userId: userId,
      status: status,
    );

    return ResponseHelper.ok({'message': 'Confirmação registrada.'});
  }

  Future<Response> listarChecklist(Request request, String eventoId) async {
    final lista = await _service.listarChecklist(eventoId);
    return ResponseHelper.ok(lista.map((i) => i.toJson()).toList());
  }

  Future<Response> addItem(Request request, String eventoId) async {
    final body = await RequestHelper.parseBody(request);
    final descricao = body['descricao'] as String? ?? '';
    final item = await _service.addChecklistItem(
        eventoId: eventoId, descricao: descricao);
    return ResponseHelper.created({'item': item.toJson()});
  }

  Future<Response> toggleItem(
      Request request, String eventoId, String itemId) async {
    final body = await RequestHelper.parseBody(request);
    final concluido = body['concluido'] as bool? ?? false;
    await _service.toggleChecklistItem(itemId: itemId, concluido: concluido);
    return ResponseHelper.ok({'message': 'Item atualizado.'});
  }

  Future<Response> deleteItem(
      Request request, String eventoId, String itemId) async {
    await _service.deleteChecklistItem(itemId);
    return ResponseHelper.noContent();
  }
}
