import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:minha_banda_server/features/auth/data/repositories/user_repository.dart';
import 'package:minha_banda_server/features/auth/domain/entities/app_user.dart';
import 'package:minha_banda_server/features/auth/service/auth_service.dart';
import 'package:minha_banda_server/core/exceptions/app_exception.dart';
import 'package:minha_banda_server/core/config/app_config.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repo;
  late AuthService service;

  setUpAll(() {
    // Configura AppConfig mínimo para os testes (JWT não requer DB)
    AppConfig.loadTest(
      jwtSecret: 'segredo-de-teste-com-pelo-menos-32-chars!!',
      jwtExpiresMinutes: 60,
    );
  });

  setUp(() {
    repo = MockUserRepository();
    service = AuthService(repo);
  });

  final userFixture = AppUser(
    id: 'usr-1',
    nomeArtistico: 'Carlos',
    email: 'carlos@test.com',
    senhaHash: r'$2b$12$somehashedvalue',
    criadoEm: DateTime(2024),
  );

  group('registrar', () {
    test('sucesso — cria usuário e retorna token', () async {
      when(() => repo.findByEmail(any())).thenAnswer((_) async => null);
      when(() => repo.create(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senhaHash: any(named: 'senhaHash'),
          )).thenAnswer((_) async => userFixture);

      final result = await service.registrar(
        nomeArtistico: 'Carlos',
        email: 'carlos@test.com',
        senha: 'senha123',
      );

      expect(result.user.email, 'carlos@test.com');
      expect(result.token, isNotEmpty);
      verify(() => repo.create(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senhaHash: any(named: 'senhaHash'),
          )).called(1);
    });

    test('e-mail duplicado → ConflictException', () async {
      when(() => repo.findByEmail(any()))
          .thenAnswer((_) async => userFixture);

      expect(
        () => service.registrar(
          nomeArtistico: 'Carlos',
          email: 'carlos@test.com',
          senha: 'senha123',
        ),
        throwsA(isA<ConflictException>()),
      );
    });

    test('nome artístico vazio → ValidationException', () {
      expect(
        () => service.registrar(
          nomeArtistico: '',
          email: 'carlos@test.com',
          senha: 'senha123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('e-mail sem @ → ValidationException', () {
      expect(
        () => service.registrar(
          nomeArtistico: 'Carlos',
          email: 'invalido',
          senha: 'senha123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('senha com menos de 8 caracteres → ValidationException', () {
      expect(
        () => service.registrar(
          nomeArtistico: 'Carlos',
          email: 'carlos@test.com',
          senha: '123',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('não chama create quando e-mail já existe', () async {
      when(() => repo.findByEmail(any()))
          .thenAnswer((_) async => userFixture);

      try {
        await service.registrar(
          nomeArtistico: 'Carlos',
          email: 'carlos@test.com',
          senha: 'senha123',
        );
      } catch (_) {}

      verifyNever(() => repo.create(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senhaHash: any(named: 'senhaHash'),
          ));
    });
  });

  group('login', () {
    test('e-mail ou senha vazios → ValidationException', () {
      expect(
        () => service.login(email: '', senha: ''),
        throwsA(isA<ValidationException>()),
      );
    });

    test('usuário não encontrado → UnauthorizedException', () async {
      when(() => repo.findByEmail(any())).thenAnswer((_) async => null);

      expect(
        () => service.login(email: 'x@x.com', senha: 'qualquer'),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
