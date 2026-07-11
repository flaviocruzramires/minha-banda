import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../../../core/middleware/auth_middleware.dart';
import '../service/musica_service.dart';

class MusicaController {
  MusicaController(this._service);
  final MusicaService _service;

  Router get router {
    final r = Router();
    r.get('/', _listar);
    r.post('/', _criar);
    r.get('/<id>', _buscar);
    r.put('/<id>', _atualizar);
    r.delete('/<id>', _deletar);
    return r;
  }

  Future<Response> _listar(Request req) async {
    final params = req.context['shelf_router/params'] as Map<String, String>?;
    final bandaId = params?['bandaId'] ?? '';
    if (bandaId.isEmpty) {
      throw const ValidationException('bandaId é obrigatório.');
    }
    final musicas = await _service.listarByBanda(bandaId);
    return ResponseHelper.ok({'musicas': musicas.map((m) => m.toJson()).toList()});
  }

  Future<Response> _criar(Request req) async {
    final userId = req.userId;
    final params = req.context['shelf_router/params'] as Map<String, String>?;
    final bandaId = params?['bandaId'] ?? '';
    if (bandaId.isEmpty) {
      throw const ValidationException('bandaId é obrigatório.');
    }
    final body = await RequestHelper.parseBody(req);

    final titulo = body['titulo'] as String? ?? '';
    final artistaOriginal = body['artistaOriginal'] as String?;
    final tonalidade = body['tonalidade'] as String?;
    final bpm = body['bpm'] as int?;
    final duracaoSeg = body['duracaoSeg'] as int?;
    final tags = (body['tags'] as List?)?.cast<String>() ?? [];
    final letra = body['letra'] as String?;
    final cifra = body['cifra'] as String?;
    final linkReferencia = body['linkReferencia'] as String?;
    final notasArranjo = body['notasArranjo'] as String?;
    final status = body['status'] as String? ?? 'em_aprendizado';

    final musica = await _service.criar(
      bandaId: bandaId,
      titulo: titulo,
      userId: userId,
      artistaOriginal: artistaOriginal,
      tonalidade: tonalidade,
      bpm: bpm,
      duracaoSeg: duracaoSeg,
      tags: tags,
      letra: letra,
      cifra: cifra,
      linkReferencia: linkReferencia,
      notasArranjo: notasArranjo,
      status: status,
    );
    return ResponseHelper.created({'musica': musica.toJson()});
  }

  Future<Response> _buscar(Request req, String id) async {
    final musica = await _service.buscarPorId(id);
    return ResponseHelper.ok({'musica': musica.toJson()});
  }

  Future<Response> _atualizar(Request req, String id) async {
    final userId = req.userId;
    final body = await RequestHelper.parseBody(req);

    final musica = await _service.atualizar(
      id: id,
      userId: userId,
      titulo: body['titulo'] as String?,
      artistaOriginal: body['artistaOriginal'] as String?,
      tonalidade: body['tonalidade'] as String?,
      bpm: body['bpm'] as int?,
      duracaoSeg: body['duracaoSeg'] as int?,
      tags: (body['tags'] as List?)?.cast<String>(),
      letra: body['letra'] as String?,
      cifra: body['cifra'] as String?,
      linkReferencia: body['linkReferencia'] as String?,
      notasArranjo: body['notasArranjo'] as String?,
      status: body['status'] as String?,
    );
    return ResponseHelper.ok({'musica': musica.toJson()});
  }

  Future<Response> _deletar(Request req, String id) async {
    final userId = req.userId;
    await _service.deletar(id: id, userId: userId);
    return ResponseHelper.noContent();
  }
}
