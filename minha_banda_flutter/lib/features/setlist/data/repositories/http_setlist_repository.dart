import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/repositories/setlist_repository.dart';

class HttpSetlistRepository implements SetlistRepository {
  HttpSetlistRepository({http.Client? client, String? baseUrl, required this.token})
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
  Future<List<String>> getSetlistIds(String eventoId) async {
    final res = await _client.get(
      Uri.parse('$_base/api/v1/eventos/$eventoId/setlist'),
      headers: _headers,
    );
    _assertOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final items = (body['data'] as Map<String, dynamic>)['setlist'] as List<dynamic>;
    items.sort((a, b) =>
        ((a as Map)['posicao'] as int).compareTo((b as Map)['posicao'] as int));
    return items.map((i) => (i as Map<String, dynamic>)['musicaId'] as String).toList();
  }

  @override
  Future<void> setSetlist({required String eventoId, required List<String> musicaIds}) async {
    final res = await _client.put(
      Uri.parse('$_base/api/v1/eventos/$eventoId/setlist'),
      headers: _headers,
      body: jsonEncode({'musicaIds': musicaIds}),
    );
    _assertOk(res);
  }

  void _assertOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    final body = res.body.isNotEmpty
        ? (jsonDecode(res.body) as Map<String, dynamic>)
        : <String, dynamic>{};
    final msg = body['error'] as String? ?? 'Erro ${res.statusCode}';
    throw Exception(msg);
  }
}
