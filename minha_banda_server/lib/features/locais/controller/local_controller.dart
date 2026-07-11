import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../../../core/middleware/auth_middleware.dart';
import '../service/local_service.dart';

class LocalController {
  LocalController(this._service);
  final LocalService _service;

  Router get router {
    final r = Router();
    r.get('/', _listar);
    r.post('/', _criar);
    r.get('/<id>', _buscar);
    r.put('/<id>', _atualizar);
    r.delete('/<id>', _deletar);
    r.get('/<id>/responsaveis', _listarResponsaveis);
    r.post('/<id>/responsaveis', _addResponsavel);
    return r;
  }

  Future<Response> meusLocaisHandler(Request request) async {
    final userId = request.userId;
    final locais = await _service.listByResponsavel(userId);
    return ResponseHelper.ok(locais.map((l) => l.toJson()).toList());
  }

  Future<Response> _listar(Request request) async {
    final cidade = request.url.queryParameters['cidade'];
    final locais = await _service.listar(cidade: cidade);
    return ResponseHelper.ok(locais.map((l) => l.toJson()).toList());
  }

  Future<Response> _criar(Request request) async {
    final userId = request.userId;
    final body = await RequestHelper.parseBody(request);

    final nome = body['nome'] as String? ?? '';
    final cidade = body['cidade'] as String? ?? '';
    final endereco = body['endereco'] as String?;
    final tipo = body['tipo'] as String?;
    final capacidade = body['capacidade'] as int?;
    final contato = body['contato'] as String?;
    final temSom = body['temSom'] as bool? ?? false;
    final temCamarim = body['temCamarim'] as bool? ?? false;
    final notas = body['notas'] as String?;

    final local = await _service.criar(
      nome: nome,
      cidade: cidade,
      criadoPor: userId,
      endereco: endereco,
      tipo: tipo,
      capacidade: capacidade,
      contato: contato,
      temSom: temSom,
      temCamarim: temCamarim,
      notas: notas,
    );

    return ResponseHelper.created({'local': local.toJson()});
  }

  Future<Response> _buscar(Request request, String id) async {
    final local = await _service.buscarPorId(id);
    return ResponseHelper.ok(local.toJson());
  }

  Future<Response> _atualizar(Request request, String id) async {
    final body = await RequestHelper.parseBody(request);

    final local = await _service.atualizar(
      id: id,
      nome: body['nome'] as String?,
      endereco: body['endereco'] as String?,
      cidade: body['cidade'] as String?,
      tipo: body['tipo'] as String?,
      capacidade: body['capacidade'] as int?,
      contato: body['contato'] as String?,
      temSom: body['temSom'] as bool?,
      temCamarim: body['temCamarim'] as bool?,
      notas: body['notas'] as String?,
    );

    return ResponseHelper.ok(local.toJson());
  }

  Future<Response> _deletar(Request request, String id) async {
    await _service.deletar(id);
    return ResponseHelper.noContent();
  }

  Future<Response> _listarResponsaveis(Request request, String id) async {
    final responsaveis = await _service.listarResponsaveis(id);
    return ResponseHelper.ok(responsaveis.map((r) => r.toJson()).toList());
  }

  Future<Response> _addResponsavel(Request request, String id) async {
    final body = await RequestHelper.parseBody(request);
    final userId = body['userId'] as String? ?? '';
    final papel = body['papel'] as String? ?? 'GERENTE';

    if (userId.isEmpty) {
      throw const ValidationException('userId é obrigatório.');
    }

    await _service.addResponsavel(
      localId: id,
      userId: userId,
      papel: papel,
    );

    return ResponseHelper.created({'message': 'Responsável adicionado.'});
  }
}
