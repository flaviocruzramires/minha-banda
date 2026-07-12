import '../entities/app_user.dart';
import '../../../bandas/domain/entities/banda.dart';

typedef AuthResult = ({AppUser user, String token});

abstract interface class AuthRepository {
  Future<AuthResult> cadastrar({
    required String nomeArtistico,
    required String email,
    required String senha,
  });

  Future<AuthResult> login({
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
