import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import '../../../core/helpers/response_helper.dart';
import '../../../core/middleware/auth_middleware.dart';

class ContextoController {
  ContextoController(this._db);
  final Connection _db;

  Future<Response> handler(Request request) async {
    final userId = request.userId;

    final bandaRows = await _db.execute(
      Sql.named(
        'SELECT b.id, b.nome, m.papel '
        'FROM memberships m '
        'JOIN bandas b ON b.id = m.banda_id '
        'WHERE m.user_id = @userId AND m.ativo = true',
      ),
      parameters: {'userId': userId},
    );

    final localRows = await _db.execute(
      Sql.named(
        'SELECT l.id, l.nome, rl.papel '
        'FROM responsaveis_local rl '
        'JOIN locais l ON l.id = rl.local_id '
        'WHERE rl.user_id = @userId',
      ),
      parameters: {'userId': userId},
    );

    final bandas = bandaRows.map((r) {
      final c = r.toColumnMap();
      return {'id': c['id'], 'nome': c['nome'], 'papel': c['papel']};
    }).toList();

    final locais = localRows.map((r) {
      final c = r.toColumnMap();
      return {'id': c['id'], 'nome': c['nome'], 'papel': c['papel']};
    }).toList();

    return ResponseHelper.ok({'bandas': bandas, 'locais': locais});
  }
}
