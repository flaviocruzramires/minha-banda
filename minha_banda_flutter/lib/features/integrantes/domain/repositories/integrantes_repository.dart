import '../entities/integrante.dart';

abstract interface class IntegrantesRepository {
  Future<List<Integrante>> listar(String bandaId);
  Future<Integrante> atualizar(Integrante integrante);
  Future<void> remover(Integrante integrante);
}
