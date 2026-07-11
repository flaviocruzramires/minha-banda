import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/helpers/response_helper.dart';
import '../../repertorio/data/repositories/musica_repository.dart';

class TeleprompterController {
  TeleprompterController(this._musicaRepo);
  final MusicaRepository _musicaRepo;

  Router get router {
    final r = Router();
    r.get('/evento/<eventoId>', _getEventoComLetra);
    return r;
  }

  Future<Response> _getEventoComLetra(Request req, String eventoId) async {
    if (eventoId.isEmpty) {
      throw const ValidationException('eventoId é obrigatório.');
    }
    final setlist = await _musicaRepo.getSetlist(eventoId);
    final musicas = <Map<String, dynamic>>[];
    for (final item in setlist) {
      final m = await _musicaRepo.findById(item.musicaId);
      if (m != null) {
        musicas.add({...m.toJson(), 'posicao': item.posicao});
      }
    }
    return ResponseHelper.ok({'musicas': musicas});
  }
}
