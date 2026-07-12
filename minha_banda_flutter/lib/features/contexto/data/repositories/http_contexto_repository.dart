import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/vinculo_contexto.dart';

class HttpContextoRepository {
  HttpContextoRepository({http.Client? client, String? baseUrl, required this.token})
      : _client = client ?? http.Client(),
        _base = baseUrl ?? kApiBaseUrl;

  final http.Client _client;
  final String _base;
  final String token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<VinculoContexto>> getMeuContexto() async {
    final res = await _client.get(
      Uri.parse('$_base/api/v1/meu-contexto'),
      headers: _headers,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) return [];
    final body = (jsonDecode(res.body) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final bandas = ((body['bandas'] as List<dynamic>?) ?? [])
        .map((b) => VinculoContexto.fromJson(b as Map<String, dynamic>, 'banda'))
        .toList();
    final locais = ((body['locais'] as List<dynamic>?) ?? [])
        .map((l) => VinculoContexto.fromJson(l as Map<String, dynamic>, 'local'))
        .toList();
    return [...bandas, ...locais];
  }
}
