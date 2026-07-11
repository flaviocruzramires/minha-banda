import '../entities/local.dart';

abstract interface class LocaisRepository {
  Future<List<Local>> listar();
  Future<Local> criar({
    required String nome,
    required String cidade,
    required String tipo,
    int? capacidade,
    String? contato,
    bool temSom,
    bool temCamarim,
    String? notas,
  });
  Future<void> deletar(String id);
}
