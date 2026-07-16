import 'package:uuid/uuid.dart';
import '../../../core/exceptions/app_exception.dart';
import '../data/repositories/banda_repository.dart';
import '../domain/entities/banda.dart';

class BandaService {
  const BandaService(this._bandas);
  final BandaRepository _bandas;

  Future<Banda> criar({
    required String nome,
    required String generoMusical,
    required String cidade,
    required int corHex,
    required String userId,
  }) async {
    _validar(nome: nome, generoMusical: generoMusical, cidade: cidade);

    final existente = await _bandas.findByNome(nome);
    if (existente != null) {
      throw const ConflictException('Esse nome de banda já está em uso.');
    }

    final banda = await _bandas.create(
      nome: nome,
      generoMusical: generoMusical,
      cidade: cidade,
      corHex: corHex,
      criadoPor: userId,
    );

    await _bandas.adicionarMembro(
      bandaId: banda.id,
      userId: userId,
      papel: 'ADMIN',
    );

    return banda;
  }

  Future<String> convidarPorEmail({
    required String bandaId,
    required String email,
    required String userId,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      throw const ValidationException('E-mail de convite inválido.');
    }

    final ehMembro = await _bandas.isMembro(bandaId, userId);
    if (!ehMembro) {
      throw const ForbiddenException(
          'Você não é membro desta banda.');
    }

    final token = const Uuid().v4();
    await _bandas.criarConvite(bandaId: bandaId, email: email, token: token);
    return token;
  }

  Future<Banda> atualizar({
    required String bandaId,
    required String userId,
    String? nome,
    String? generoMusical,
    String? cidade,
  }) async {
    final ehMembro = await _bandas.isMembro(bandaId, userId);
    if (!ehMembro) {
      throw const ForbiddenException('Você não é membro desta banda.');
    }
    return _bandas.update(
      bandaId: bandaId,
      nome: nome,
      generoMusical: generoMusical,
      cidade: cidade,
    );
  }

  String gerarLinkConvite(String bandaId, String baseUrl) =>
      '$baseUrl/convite/$bandaId';

  void _validar({
    required String nome,
    required String generoMusical,
    required String cidade,
  }) {
    if (nome.trim().isEmpty) {
      throw const ValidationException('Nome da banda é obrigatório.');
    }
    if (generoMusical.trim().isEmpty) {
      throw const ValidationException('Gênero musical é obrigatório.');
    }
    if (cidade.trim().isEmpty) {
      throw const ValidationException('Cidade é obrigatória.');
    }
  }
}
