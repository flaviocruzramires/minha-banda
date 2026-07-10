import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:minha_banda_flutter/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:minha_banda_flutter/features/auth/domain/entities/app_user.dart';
import 'package:minha_banda_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:minha_banda_flutter/features/auth/presentation/notifiers/cadastro_notifier.dart';
import 'package:minha_banda_flutter/features/bandas/domain/entities/banda.dart';
import 'package:flutter/material.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() => container.dispose());

  const usuarioFixture = AppUser(
    id: 'usr_1',
    nomeArtistico: 'Carlos',
    email: 'carlos@test.com',
  );

  final bandaFixture = Banda(
    id: 'banda_1',
    nome: 'Os Testes',
    generoMusical: 'Rock',
    cidade: 'SP',
    cor: const Color(0xFF7A1F3D),
  );

  group('cadastrarUsuario', () {
    test('sucesso → status success e usuario preenchido', () async {
      when(() => repo.cadastrar(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senha: any(named: 'senha'),
          )).thenAnswer((_) async => usuarioFixture);

      final notifier = container.read(cadastroNotifierProvider.notifier);
      final ok = await notifier.cadastrarUsuario(
        nomeArtistico: 'Carlos',
        email: 'carlos@test.com',
        senha: 'senha123',
      );

      expect(ok, isTrue);
      final state = container.read(cadastroNotifierProvider);
      expect(state.status, CadastroStatus.success);
      expect(state.usuario, usuarioFixture);
      expect(state.erro, isNull);
    });

    test('email já cadastrado → status error com mensagem', () async {
      when(() => repo.cadastrar(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senha: any(named: 'senha'),
          )).thenThrow(const EmailJaCadastradoException());

      final notifier = container.read(cadastroNotifierProvider.notifier);
      final ok = await notifier.cadastrarUsuario(
        nomeArtistico: 'Carlos',
        email: 'duplicado@test.com',
        senha: 'senha123',
      );

      expect(ok, isFalse);
      final state = container.read(cadastroNotifierProvider);
      expect(state.status, CadastroStatus.error);
      expect(state.erro, contains('e-mail'));
    });

    test('erro genérico → status error com mensagem genérica', () async {
      when(() => repo.cadastrar(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senha: any(named: 'senha'),
          )).thenThrow(Exception('timeout'));

      final notifier = container.read(cadastroNotifierProvider.notifier);
      final ok = await notifier.cadastrarUsuario(
        nomeArtistico: 'Carlos',
        email: 'carlos@test.com',
        senha: 'senha123',
      );

      expect(ok, isFalse);
      expect(
        container.read(cadastroNotifierProvider).status,
        CadastroStatus.error,
      );
    });
  });

  group('criarBanda', () {
    setUp(() {
      // usuário já cadastrado
      container.read(cadastroNotifierProvider.notifier);
      // injetamos o usuario no estado via cadastrarUsuario mock
    });

    test('sem usuario no estado → retorna false imediatamente', () async {
      final notifier = container.read(cadastroNotifierProvider.notifier);
      final ok = await notifier.criarBanda(
        nome: 'Teste',
        generoMusical: 'Rock',
        cidade: 'SP',
        cor: const Color(0xFF7A1F3D),
      );
      expect(ok, isFalse);
    });

    test('nome em uso → status error', () async {
      // primeiro cadastra user
      when(() => repo.cadastrar(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senha: any(named: 'senha'),
          )).thenAnswer((_) async => usuarioFixture);
      when(() => repo.criarBanda(
            userId: any(named: 'userId'),
            nome: any(named: 'nome'),
            generoMusical: any(named: 'generoMusical'),
            cidade: any(named: 'cidade'),
            corHex: any(named: 'corHex'),
          )).thenThrow(const NomeBandaEmUsoException());

      final notifier = container.read(cadastroNotifierProvider.notifier);
      await notifier.cadastrarUsuario(
        nomeArtistico: 'Carlos',
        email: 'carlos@test.com',
        senha: 'senha123',
      );

      final ok = await notifier.criarBanda(
        nome: 'Duplicada',
        generoMusical: 'Rock',
        cidade: 'SP',
        cor: const Color(0xFF7A1F3D),
      );

      expect(ok, isFalse);
      expect(
        container.read(cadastroNotifierProvider).erro,
        contains('nome de banda'),
      );
    });

    test('sucesso → estado tem banda e linkConvite', () async {
      when(() => repo.cadastrar(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senha: any(named: 'senha'),
          )).thenAnswer((_) async => usuarioFixture);
      when(() => repo.criarBanda(
            userId: any(named: 'userId'),
            nome: any(named: 'nome'),
            generoMusical: any(named: 'generoMusical'),
            cidade: any(named: 'cidade'),
            corHex: any(named: 'corHex'),
          )).thenAnswer((_) async => bandaFixture);
      when(() => repo.gerarLinkConvite(any()))
          .thenAnswer((_) async => 'https://minha.banda/convite/banda_1');

      final notifier = container.read(cadastroNotifierProvider.notifier);
      await notifier.cadastrarUsuario(
        nomeArtistico: 'Carlos',
        email: 'carlos@test.com',
        senha: 'senha123',
      );
      final ok = await notifier.criarBanda(
        nome: 'Os Testes',
        generoMusical: 'Rock',
        cidade: 'SP',
        cor: const Color(0xFF7A1F3D),
      );

      expect(ok, isTrue);
      final state = container.read(cadastroNotifierProvider);
      expect(state.banda?.nome, 'Os Testes');
      expect(state.linkConvite, isNotNull);
    });
  });

  group('convidarPorEmail', () {
    test('adiciona convite à lista de convites', () async {
      when(() => repo.cadastrar(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senha: any(named: 'senha'),
          )).thenAnswer((_) async => usuarioFixture);
      when(() => repo.criarBanda(
            userId: any(named: 'userId'),
            nome: any(named: 'nome'),
            generoMusical: any(named: 'generoMusical'),
            cidade: any(named: 'cidade'),
            corHex: any(named: 'corHex'),
          )).thenAnswer((_) async => bandaFixture);
      when(() => repo.gerarLinkConvite(any()))
          .thenAnswer((_) async => 'https://minha.banda/convite/banda_1');
      when(() => repo.convidarPorEmail(
            bandaId: any(named: 'bandaId'),
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      final notifier = container.read(cadastroNotifierProvider.notifier);
      await notifier.cadastrarUsuario(
        nomeArtistico: 'Carlos',
        email: 'carlos@test.com',
        senha: 'senha123',
      );
      await notifier.criarBanda(
        nome: 'Os Testes',
        generoMusical: 'Rock',
        cidade: 'SP',
        cor: const Color(0xFF7A1F3D),
      );
      await notifier.convidarPorEmail('guitarrista@test.com');
      await notifier.convidarPorEmail('baterista@test.com');

      final convites = container.read(cadastroNotifierProvider).convites;
      expect(convites.length, 2);
      expect(convites.map((c) => c.email),
          containsAll(['guitarrista@test.com', 'baterista@test.com']));
    });
  });

  group('pularCriacaoBanda', () {
    test('volta estado para idle sem banda', () async {
      final notifier = container.read(cadastroNotifierProvider.notifier);
      notifier.pularCriacaoBanda();
      final state = container.read(cadastroNotifierProvider);
      expect(state.banda, isNull);
      expect(state.status, CadastroStatus.idle);
    });
  });
}
