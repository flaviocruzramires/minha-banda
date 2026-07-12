import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../bandas/domain/entities/banda.dart';
import 'mock_auth_repository.dart'
    show EmailJaCadastradoException, CredenciaisInvalidasException, NomeBandaEmUsoException;

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _base = baseUrl ?? kApiBaseUrl;

  final http.Client _client;
  final String _base;
  String? _token;

  @override
  Future<AuthResult> cadastrar({
    required String nomeArtistico,
    required String email,
    required String senha,
  }) async {
    final res = await _client.post(
      Uri.parse('$_base/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nomeArtistico': nomeArtistico,
        'email': email,
        'senha': senha,
      }),
    );

    final body = _decode(res);

    if (res.statusCode == 409) throw const EmailJaCadastradoException();
    _assertOk(res, body);

    final data = body['data'] as Map<String, dynamic>;
    _token = data['token'] as String;
    final u = data['user'] as Map<String, dynamic>;
    return (
      user: AppUser(
        id: u['id'] as String,
        nomeArtistico: u['nomeArtistico'] as String,
        email: u['email'] as String,
      ),
      token: _token!,
    );
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String senha,
  }) async {
    final res = await _client.post(
      Uri.parse('$_base/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    final body = _decode(res);

    if (res.statusCode == 401) throw const CredenciaisInvalidasException();
    _assertOk(res, body);

    final data = body['data'] as Map<String, dynamic>;
    _token = data['token'] as String;
    final u = data['user'] as Map<String, dynamic>;
    return (
      user: AppUser(
        id: u['id'] as String,
        nomeArtistico: u['nomeArtistico'] as String,
        email: u['email'] as String,
      ),
      token: _token!,
    );
  }

  @override
  Future<Banda> criarBanda({
    required String userId,
    required String nome,
    required String generoMusical,
    required String cidade,
    required int corHex,
  }) async {
    final res = await _client.post(
      Uri.parse('$_base/api/v1/bandas/'),
      headers: _authHeaders,
      body: jsonEncode({
        'nome': nome,
        'generoMusical': generoMusical,
        'cidade': cidade,
        'corHex': corHex,
      }),
    );

    final body = _decode(res);

    if (res.statusCode == 409) throw const NomeBandaEmUsoException();
    _assertOk(res, body);

    final data = body['data'] as Map<String, dynamic>;
    return _bandaFromJson(data['banda'] as Map<String, dynamic>);
  }

  @override
  Future<void> convidarPorEmail({
    required String bandaId,
    required String email,
  }) async {
    final res = await _client.post(
      Uri.parse('$_base/api/v1/bandas/$bandaId/convites'),
      headers: _authHeaders,
      body: jsonEncode({'email': email}),
    );
    _assertOk(res, _decode(res));
  }

  @override
  Future<String> gerarLinkConvite(String bandaId) async {
    final res = await _client.get(
      Uri.parse('$_base/api/v1/bandas/$bandaId/link-convite'),
      headers: _authHeaders,
    );
    final body = _decode(res);
    _assertOk(res, body);
    final data = body['data'] as Map<String, dynamic>;
    return data['linkConvite'] as String;
  }

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Map<String, dynamic> _decode(http.Response res) {
    if (res.body.isEmpty) return {};
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void _assertOk(http.Response res, Map<String, dynamic> body) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    final msg = body['error'] as String? ?? body['message'] as String? ?? 'Erro ${res.statusCode}';
    throw HttpRepositoryException(res.statusCode, msg);
  }

  Banda _bandaFromJson(Map<String, dynamic> j) {
    final corHex = j['corHex'] as int? ?? 0;
    return Banda(
      id: j['id'] as String,
      nome: j['nome'] as String,
      generoMusical: j['generoMusical'] as String,
      cidade: j['cidade'] as String,
      cor: Color(corHex),
    );
  }
}

class HttpRepositoryException implements Exception {
  const HttpRepositoryException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => 'HttpRepositoryException($statusCode): $message';
}
