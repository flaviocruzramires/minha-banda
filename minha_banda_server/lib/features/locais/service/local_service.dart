import '../../../core/exceptions/app_exception.dart';
import '../data/repositories/local_repository.dart';
import '../domain/entities/local.dart';
import '../domain/entities/responsavel_local.dart';

class LocalService {
  const LocalService(this._repo);
  final LocalRepository _repo;

  Future<List<Local>> listar({String? cidade}) => _repo.listAll(cidade: cidade);

  Future<Local> buscarPorId(String id) async {
    final local = await _repo.findById(id);
    if (local == null) throw const NotFoundException('Local não encontrado.');
    return local;
  }

  Future<Local> criar({
    required String nome,
    required String cidade,
    required String criadoPor,
    String? endereco,
    String? tipo,
    int? capacidade,
    String? contato,
    bool temSom = false,
    bool temCamarim = false,
    String? notas,
  }) async {
    if (nome.trim().isEmpty) {
      throw const ValidationException('Nome do local é obrigatório.');
    }
    if (cidade.trim().isEmpty) {
      throw const ValidationException('Cidade é obrigatória.');
    }

    final local = await _repo.create(
      nome: nome,
      cidade: cidade,
      criadoPor: criadoPor,
      endereco: endereco,
      tipo: tipo,
      capacidade: capacidade,
      contato: contato,
      temSom: temSom,
      temCamarim: temCamarim,
      notas: notas,
    );

    await _repo.addResponsavel(
      localId: local.id,
      userId: criadoPor,
      papel: 'DONO',
    );

    return local;
  }

  Future<Local> atualizar({
    required String id,
    String? nome,
    String? endereco,
    String? cidade,
    String? tipo,
    int? capacidade,
    String? contato,
    bool? temSom,
    bool? temCamarim,
    String? notas,
  }) async {
    await buscarPorId(id);
    return _repo.update(
      id: id,
      nome: nome,
      endereco: endereco,
      cidade: cidade,
      tipo: tipo,
      capacidade: capacidade,
      contato: contato,
      temSom: temSom,
      temCamarim: temCamarim,
      notas: notas,
    );
  }

  Future<void> deletar(String id) async {
    await buscarPorId(id);
    await _repo.delete(id);
  }

  Future<void> addResponsavel({
    required String localId,
    required String userId,
    String papel = 'GERENTE',
  }) =>
      _repo.addResponsavel(localId: localId, userId: userId, papel: papel);

  Future<List<ResponsavelLocal>> listarResponsaveis(String localId) =>
      _repo.getResponsaveis(localId);

  Future<List<Local>> listByResponsavel(String userId) =>
      _repo.listByResponsavel(userId);
}
