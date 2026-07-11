import '../../domain/entities/local.dart';
import '../../domain/repositories/locais_repository.dart';

class MockLocaisRepository implements LocaisRepository {
  @override
  Future<List<Local>> listar() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      Local(id: 'l1', nome: 'Bar do Zé', cidade: 'São Paulo', tipo: 'bar', capacidade: 200, temSom: true),
      Local(id: 'l2', nome: 'Teatro Municipal', cidade: 'Rio de Janeiro', tipo: 'teatro', capacidade: 1000, temSom: true, temCamarim: true),
      Local(id: 'l3', nome: 'Arena Rock', cidade: 'Belo Horizonte', tipo: 'arena', capacidade: 5000, temSom: true, temCamarim: true),
    ];
  }

  @override
  Future<Local> criar({
    required String nome, required String cidade, required String tipo,
    int? capacidade, String? contato, bool temSom = false, bool temCamarim = false, String? notas,
  }) async {
    return Local(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome, cidade: cidade, tipo: tipo,
      capacidade: capacidade, contato: contato,
      temSom: temSom, temCamarim: temCamarim, notas: notas,
    );
  }

  @override
  Future<void> deletar(String id) async {}
}
