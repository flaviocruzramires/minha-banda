import '../data/repositories/notificacao_repository.dart';
import '../domain/entities/notificacao.dart';

class NotificacaoService {
  const NotificacaoService(this._repo);
  final NotificacaoRepository _repo;

  Future<List<Notificacao>> listar(String usuarioId) =>
      _repo.listarPorUsuario(usuarioId);

  Future<int> contarNaoLidas(String usuarioId) =>
      _repo.contarNaoLidas(usuarioId);

  Future<void> marcarComoLida(String id) => _repo.marcarComoLida(id);

  Future<void> marcarTodasComoLidas(String usuarioId) =>
      _repo.marcarTodasComoLidas(usuarioId);

  Future<Notificacao> criar({
    required String usuarioId,
    required String tipo,
    required String titulo,
    required String corpo,
    Map<String, dynamic>? payload,
  }) =>
      _repo.criar(
        usuarioId: usuarioId,
        tipo: tipo,
        titulo: titulo,
        corpo: corpo,
        payload: payload,
      );
}
