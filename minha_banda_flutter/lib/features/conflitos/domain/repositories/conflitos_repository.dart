import '../entities/conflito.dart';

abstract interface class ConflitosRepository {
  Future<List<Conflito>> verificar({
    required String bandaId,
    required DateTime inicio,
    required DateTime fim,
  });
}
