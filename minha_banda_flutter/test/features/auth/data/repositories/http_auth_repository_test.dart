import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:minha_banda_flutter/features/auth/data/repositories/http_auth_repository.dart';
import 'package:minha_banda_flutter/features/auth/data/repositories/mock_auth_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

// Respostas que espelham exatamente o formato do servidor (ResponseHelper)
// { "data": { ... } }  para sucesso
// { "error": "..." }   para erro

Map<String, String> get _jsonHeader =>
    {'content-type': 'application/json'};

http.Response _ok(Object body) =>
    http.Response(jsonEncode({'data': body}), 200, headers: _jsonHeader);

http.Response _created(Object body) =>
    http.Response(jsonEncode({'data': body}), 201, headers: _jsonHeader);

http.Response _error(int code, String message) =>
    http.Response(jsonEncode({'error': message}), code, headers: _jsonHeader);

// Payloads que o servidor retorna
const _userPayload = {
  'id': 'usr-1',
  'nomeArtistico': 'Zé da Guitarra',
  'email': 'ze@banda.com',
};

const _bandaPayload = {
  'id': 'banda-1',
  'nome': 'Os Acordes',
  'generoMusical': 'Rock',
  'cidade': 'SP',
  'corHex': 0xFF7A1F3D,
  'criadoPor': 'usr-1',
};

const _token = 'eyJhbGciOiJIUzI1NiJ9.test.sig';

void main() {
  late MockHttpClient client;
  late HttpAuthRepository repo;

  setUp(() {
    client = MockHttpClient();
    repo = HttpAuthRepository(client: client, baseUrl: 'http://localhost:8081');
    registerFallbackValue(Uri.parse('http://localhost:8081'));
  });

  // ---------------------------------------------------------------------------
  // cadastrar
  // ---------------------------------------------------------------------------

  group('cadastrar', () {
    final uri = Uri.parse('http://localhost:8081/api/v1/auth/register');

    test('sucesso → retorna user e token', () async {
      when(() => client.post(uri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer((_) async => _created({
                'user': _userPayload,
                'token': _token,
              }));

      final result = await repo.cadastrar(
        nomeArtistico: 'Zé da Guitarra',
        email: 'ze@banda.com',
        senha: 'senha123',
      );

      expect(result.token, _token);
      expect(result.user.id, 'usr-1');
      expect(result.user.nomeArtistico, 'Zé da Guitarra');
      expect(result.user.email, 'ze@banda.com');
    });

    test('409 → lança EmailJaCadastradoException', () async {
      when(() => client.post(uri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer(
              (_) async => _error(409, 'Este e-mail já está cadastrado.'));

      expect(
        () => repo.cadastrar(
            nomeArtistico: 'X', email: 'ze@banda.com', senha: 'senha123'),
        throwsA(isA<EmailJaCadastradoException>()),
      );
    });

    test('400 (validação) → lança HttpRepositoryException com mensagem', () async {
      when(() => client.post(uri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer((_) async =>
              _error(400, 'Senha deve ter no mínimo 8 caracteres.'));

      expect(
        () => repo.cadastrar(
            nomeArtistico: 'Zé', email: 'ze@banda.com', senha: 'curta'),
        throwsA(isA<HttpRepositoryException>().having(
            (e) => e.message, 'message', contains('8 caracteres'))),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // login
  // ---------------------------------------------------------------------------

  group('login', () {
    final uri = Uri.parse('http://localhost:8081/api/v1/auth/login');

    test('sucesso → retorna user e token', () async {
      when(() => client.post(uri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer((_) async => _ok({
                'user': _userPayload,
                'token': _token,
              }));

      final result = await repo.login(
          email: 'ze@banda.com', senha: 'senha123');

      expect(result.token, _token);
      expect(result.user.email, 'ze@banda.com');
    });

    test('401 → lança CredenciaisInvalidasException', () async {
      when(() => client.post(uri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer(
              (_) async => _error(401, 'E-mail ou senha incorretos.'));

      expect(
        () => repo.login(email: 'ze@banda.com', senha: 'errada'),
        throwsA(isA<CredenciaisInvalidasException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // criarBanda — requer token (cadastrar primeiro)
  // ---------------------------------------------------------------------------

  group('criarBanda', () {
    final registerUri =
        Uri.parse('http://localhost:8081/api/v1/auth/register');
    final bandaUri = Uri.parse('http://localhost:8081/api/v1/bandas');

    test('sucesso → retorna Banda com dados corretos', () async {
      // primeiro cadastra para ter token
      when(() => client.post(registerUri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer((_) async =>
              _created({'user': _userPayload, 'token': _token}));

      when(() => client.post(bandaUri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer((_) async => _created({
                'banda': _bandaPayload,
                'linkConvite': 'http://localhost:8081/convite/banda-1',
              }));

      await repo.cadastrar(
          nomeArtistico: 'Zé', email: 'ze@banda.com', senha: 'senha123');

      final banda = await repo.criarBanda(
        userId: 'usr-1',
        nome: 'Os Acordes',
        generoMusical: 'Rock',
        cidade: 'SP',
        corHex: 0xFF7A1F3D,
      );

      expect(banda.id, 'banda-1');
      expect(banda.nome, 'Os Acordes');
      expect(banda.generoMusical, 'Rock');
      expect(banda.cidade, 'SP');
      expect(banda.cor, const Color(0xFF7A1F3D));
    });

    test('409 → lança NomeBandaEmUsoException', () async {
      when(() => client.post(registerUri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer((_) async =>
              _created({'user': _userPayload, 'token': _token}));

      when(() => client.post(bandaUri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer((_) async => _error(409, 'Nome de banda já em uso.'));

      await repo.cadastrar(
          nomeArtistico: 'Zé', email: 'ze@banda.com', senha: 'senha123');

      expect(
        () => repo.criarBanda(
            userId: 'usr-1',
            nome: 'Duplicada',
            generoMusical: 'Rock',
            cidade: 'SP',
            corHex: 0),
        throwsA(isA<NomeBandaEmUsoException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // gerarLinkConvite
  // ---------------------------------------------------------------------------

  group('gerarLinkConvite', () {
    final registerUri =
        Uri.parse('http://localhost:8081/api/v1/auth/register');

    test('sucesso → retorna URL do link', () async {
      when(() => client.post(registerUri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer((_) async =>
              _created({'user': _userPayload, 'token': _token}));

      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              _ok({'linkConvite': 'http://localhost:8081/convite/banda-1'}));

      await repo.cadastrar(
          nomeArtistico: 'Zé', email: 'ze@banda.com', senha: 'senha123');

      final link = await repo.gerarLinkConvite('banda-1');
      expect(link, 'http://localhost:8081/convite/banda-1');
    });
  });

  // ---------------------------------------------------------------------------
  // convidarPorEmail
  // ---------------------------------------------------------------------------

  group('convidarPorEmail', () {
    final registerUri =
        Uri.parse('http://localhost:8081/api/v1/auth/register');

    test('sucesso → não lança exceção', () async {
      when(() => client.post(registerUri,
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer((_) async =>
              _created({'user': _userPayload, 'token': _token}));

      when(() => client.post(
              Uri.parse(
                  'http://localhost:8081/api/v1/bandas/banda-1/convites'),
              headers: any(named: 'headers'),
              body: any(named: 'body')))
          .thenAnswer((_) async =>
              _created({'message': 'Convite enviado para g@test.com.'}));

      await repo.cadastrar(
          nomeArtistico: 'Zé', email: 'ze@banda.com', senha: 'senha123');

      await expectLater(
        repo.convidarPorEmail(bandaId: 'banda-1', email: 'g@test.com'),
        completes,
      );
    });
  });
}
