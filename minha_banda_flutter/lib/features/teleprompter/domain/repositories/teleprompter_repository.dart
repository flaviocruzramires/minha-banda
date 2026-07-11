import '../entities/musica_teleprompter.dart';

abstract interface class TeleprompterRepository {
  Future<List<MusicaTeleprompter>> getEventoComLetra(String eventoId);
}
