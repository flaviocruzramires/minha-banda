import '../../domain/repositories/setlist_repository.dart';

class MockSetlistRepository implements SetlistRepository {
  @override
  Future<List<String>> getSetlistIds(String eventoId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['1', '3'];
  }

  @override
  Future<void> setSetlist({required String eventoId, required List<String> musicaIds}) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
