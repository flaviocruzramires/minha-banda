import '../../domain/entities/musica_teleprompter.dart';
import '../../domain/repositories/teleprompter_repository.dart';

class MockTeleprompterRepository implements TeleprompterRepository {
  @override
  Future<List<MusicaTeleprompter>> getEventoComLetra(String eventoId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      MusicaTeleprompter(
        titulo: 'Bohemian Rhapsody',
        artistaOriginal: 'Queen',
        posicao: 1,
        letra: '''Is this the real life?\nIs this just fantasy?\nCaught in a landslide\nNo escape from reality\n\nOpen your eyes\nLook up to the skies and see\nI'm just a poor boy, I need no sympathy\nBecause it's easy come, easy go\nLittle high, little low\nAnyway the wind blows\nDoesn't really matter to me, to me''',
      ),
      MusicaTeleprompter(
        titulo: 'Hotel California',
        artistaOriginal: 'Eagles',
        posicao: 2,
        letra: '''On a dark desert highway, cool wind in my hair\nWarm smell of colitas rising up through the air\nUp ahead in the distance, I saw a shimmering light\nMy head grew heavy and my sight grew dim\nI had to stop for the night\n\nThere she stood in the doorway\nI heard the mission bell\nAnd I was thinking to myself\nThis could be heaven or this could be hell''',
      ),
    ];
  }
}
