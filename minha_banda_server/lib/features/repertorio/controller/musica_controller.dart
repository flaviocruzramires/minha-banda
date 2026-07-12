import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/helpers/request_helper.dart';
import '../../../core/helpers/response_helper.dart';
import '../../../core/middleware/auth_middleware.dart';
import '../service/musica_service.dart';

class MusicaController {
  MusicaController(this._service);
  final MusicaService _service;

  /// Rotas sem parâmetro de banda (buscar/atualizar/deletar por id)
  Router get router {
    final r = Router();
    r.get('/<id>', buscar);
    r.put('/<id>', atualizar);
    r.delete('/<id>', deletar);
    return r;
  }

  Future<Response> listar(Request req, String bandaId) async {
    final musicas = await _service.listarByBanda(bandaId);
    return ResponseHelper.ok({'musicas': musicas.map((m) => m.toJson()).toList()});
  }

  Future<Response> criar(Request req, String bandaId) async {
    final userId = req.userId;
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

  Future<Response> buscar(Request req, String id) async {
    final musica = await _service.buscarPorId(id);
    return ResponseHelper.ok({'musica': musica.toJson()});
  }

  Future<Response> atualizar(Request req, String id) async {
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

  Future<Response> deletar(Request req, String id) async {
    final userId = req.userId;
    await _service.deletar(id: id, userId: userId);
    return ResponseHelper.noContent();
  }
}
