import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/conflito.dart';
import '../../domain/repositories/conflitos_repository.dart';

class HttpConflitosRepository implements ConflitosRepository {
  HttpConflitosRepository({http.Client? client, String? baseUrl, required this.token})
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
  Future<List<Conflito>> verificar({
    required String bandaId,
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final res = await _client.post(
      Uri.parse('$_base/api/v1/conflitos/verificar'),
      headers: _headers,
      body: jsonEncode({
        'bandaId': bandaId,
        'dataHoraInicio': inicio.toIso8601String(),
        'dataHoraFim': fim.toIso8601String(),
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['data'] as Map<String, dynamic>)['conflitos'] as List<dynamic>;
    return list
        .map((c) => Conflito.fromJson(c as Map<String, dynamic>))
        .where((c) => c.temConflito)
        .toList();
  }
}
