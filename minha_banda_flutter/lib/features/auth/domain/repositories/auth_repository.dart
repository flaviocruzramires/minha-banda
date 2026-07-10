import '../entities/app_user.dart';
import '../../../bandas/domain/entities/banda.dart';

abstract interface class AuthRepository {
  Future<AppUser> cadastrar({
    required String nomeArtistico,
    required String email,
    required String senha,
  });

  Future<Banda> criarBanda({
    required String userId,
    required String nome,
    required String generoMusical,
    required String cidade,
    required int corHex,
  });

  Future<void> convidarPorEmail({
    required String bandaId,
    required String email,
  });

  Future<String> gerarLinkConvite(String bandaId);
}
