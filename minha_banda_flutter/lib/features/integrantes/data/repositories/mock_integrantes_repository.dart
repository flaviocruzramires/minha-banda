import '../../domain/entities/integrante.dart';
import '../../domain/repositories/integrantes_repository.dart';

class MockIntegrantesRepository implements IntegrantesRepository {
  @override
  Future<List<Integrante>> listar(String bandaId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      Integrante(id: 'i1', userId: 'u1', bandaId: bandaId, papel: 'vocalista', instrumento: 'Voz', apelido: 'João', email: 'joao@email.com', nomeArtistico: 'JV'),
      Integrante(id: 'i2', userId: 'u2', bandaId: bandaId, papel: 'guitarrista', instrumento: 'Guitarra', apelido: 'Maria', email: 'maria@email.com'),
      Integrante(id: 'i3', userId: 'u3', bandaId: bandaId, papel: 'baterista', instrumento: 'Bateria', apelido: 'Pedro', email: 'pedro@email.com'),
    ];
  }

  @override
  Future<Integrante> atualizar(Integrante integrante) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return integrante;
  }

  @override
  Future<void> remover(Integrante integrante) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
