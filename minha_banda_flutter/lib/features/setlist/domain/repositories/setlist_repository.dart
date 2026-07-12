abstract interface class SetlistRepository {
  Future<List<String>> getSetlistIds(String eventoId);
  Future<void> setSetlist({required String eventoId, required List<String> musicaIds});
}
