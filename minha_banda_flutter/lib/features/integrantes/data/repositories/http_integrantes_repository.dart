import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/integrante.dart';
import '../../domain/repositories/integrantes_repository.dart';

class HttpIntegrantesRepository implements IntegrantesRepository {
  HttpIntegrantesRepository({http.Client? client, String? baseUrl, required this.token})
      : _client = client ?? http.Client(),
        _base = baseUrl ?? kApiBaseUrl;

  final http.Client _client;
  final String _base;
  final String token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  @override
  Future<List<Integrante>> listar(String bandaId) async {
    final res = await _client.get(Uri.parse('$_base/api/v1/bandas/$bandaId/integrantes/'), headers: _headers);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;
    return list.map((e) => Integrante.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Integrante> atualizar(Integrante integrante) async {
    final res = await _client.put(
        Uri.parse('$_base/api/v1/bandas/${integrante.bandaId}/integrantes/${integrante.userId}'),
        headers: _headers, body: jsonEncode(integrante.toJson()));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Integrante.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> remover(Integrante integrante) async {
    await _client.delete(
        Uri.parse('$_base/api/v1/bandas/${integrante.bandaId}/integrantes/${integrante.userId}'),
        headers: _headers);
  }
}
