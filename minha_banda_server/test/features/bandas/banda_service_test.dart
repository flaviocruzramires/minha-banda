import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:minha_banda_server/features/bandas/data/repositories/banda_repository.dart';
import 'package:minha_banda_server/features/bandas/domain/entities/banda.dart';
import 'package:minha_banda_server/features/bandas/service/banda_service.dart';
import 'package:minha_banda_server/core/exceptions/app_exception.dart';

class MockBandaRepository extends Mock implements BandaRepository {}

void main() {
  late MockBandaRepository repo;
  late BandaService service;

  setUp(() {
    repo = MockBandaRepository();
    service = BandaService(repo);
  });

  final bandaFixture = Banda(
    id: 'banda-1',
    nome: 'Los Trios',
    generoMusical: 'Rock',
    cidade: 'São Paulo',
    corHex: 0xFF0000,
    criadoPor: 'usr-1',
    criadoEm: DateTime(2024),
  );

  group('criar', () {
    test('sucesso — cria banda e adiciona criador como ADMIN', () async {
      when(() => repo.findByNome(any())).thenAnswer((_) async => null);
      when(() => repo.create(
            nome: any(named: 'nome'),
            generoMusical: any(named: 'generoMusical'),
            cidade: any(named: 'cidade'),
            corHex: any(named: 'corHex'),
            criadoPor: any(named: 'criadoPor'),
          )).thenAnswer((_) async => bandaFixture);
      when(() => repo.adicionarMembro(
            bandaId: any(named: 'bandaId'),
            userId: any(named: 'userId'),
            papel: any(named: 'papel'),
          )).thenAnswer((_) async {});

      final result = await service.criar(
        nome: 'Los Trios',
        generoMusical: 'Rock',
        cidade: 'São Paulo',
        corHex: 0xFF0000,
        userId: 'usr-1',
      );

      expect(result.nome, 'Los Trios');
      verify(() => repo.adicionarMembro(
            bandaId: 'banda-1',
            userId: 'usr-1',
            papel: 'ADMIN',
          )).called(1);
    });

    test('nome duplicado → ConflictException', () async {
      when(() => repo.findByNome(any()))
          .thenAnswer((_) async => bandaFixture);

      expect(
        () => service.criar(
          nome: 'Los Trios',
          generoMusical: 'Rock',
          cidade: 'SP',
          corHex: 0,
          userId: 'usr-1',
        ),
        throwsA(isA<ConflictException>()),
      );
    });

    test('nome vazio → ValidationException', () {
      expect(
        () => service.criar(
          nome: '',
          generoMusical: 'Rock',
          cidade: 'SP',
          corHex: 0,
          userId: 'usr-1',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('gênero musical vazio → ValidationException', () {
      expect(
        () => service.criar(
          nome: 'Los Trios',
          generoMusical: '',
          cidade: 'SP',
          corHex: 0,
          userId: 'usr-1',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('cidade vazia → ValidationException', () {
      expect(
        () => service.criar(
          nome: 'Los Trios',
          generoMusical: 'Rock',
          cidade: '',
          corHex: 0,
          userId: 'usr-1',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('não chama create quando nome já existe', () async {
      when(() => repo.findByNome(any()))
          .thenAnswer((_) async => bandaFixture);

      try {
        await service.criar(
          nome: 'Los Trios',
          generoMusical: 'Rock',
          cidade: 'SP',
          corHex: 0,
          userId: 'usr-1',
        );
      } catch (_) {}

      verifyNever(() => repo.create(
            nome: any(named: 'nome'),
            generoMusical: any(named: 'generoMusical'),
            cidade: any(named: 'cidade'),
            corHex: any(named: 'corHex'),
            criadoPor: any(named: 'criadoPor'),
          ));
    });
  });

  group('convidarPorEmail', () {
    test('sucesso — retorna token de convite', () async {
      when(() => repo.isMembro(any(), any())).thenAnswer((_) async => true);
      when(() => repo.criarConvite(
            bandaId: any(named: 'bandaId'),
            email: any(named: 'email'),
            token: any(named: 'token'),
          )).thenAnswer((inv) async =>
              inv.namedArguments[#token] as String);

      final token = await service.convidarPorEmail(
        bandaId: 'banda-1',
        email: 'novo@test.com',
        userId: 'usr-1',
      );

      expect(token, isNotEmpty);
    });

    test('usuário não membro → ForbiddenException', () async {
      when(() => repo.isMembro(any(), any())).thenAnswer((_) async => false);

      expect(
        () => service.convidarPorEmail(
          bandaId: 'banda-1',
          email: 'novo@test.com',
          userId: 'usr-2',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('e-mail inválido → ValidationException', () {
      expect(
        () => service.convidarPorEmail(
          bandaId: 'banda-1',
          email: 'invalido',
          userId: 'usr-1',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('gerarLinkConvite', () {
    test('retorna URL com bandaId', () {
      final link = service.gerarLinkConvite(
          'banda-1', 'https://app.minha-banda.com.br');
      expect(link, contains('banda-1'));
    });
  });
}
