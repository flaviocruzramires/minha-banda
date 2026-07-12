import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/musica_teleprompter.dart';
import '../../domain/repositories/teleprompter_repository.dart';

class HttpTeleprompterRepository implements TeleprompterRepository {
  HttpTeleprompterRepository({http.Client? client, String? baseUrl, required this.token})
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
  Future<List<MusicaTeleprompter>> getEventoComLetra(String eventoId) async {
    final res = await _client.get(
      Uri.parse('$_base/api/v1/teleprompter/evento/$eventoId'),
      headers: _headers,
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data']['musicas'] as List<dynamic>;
    return list.map((e) => MusicaTeleprompter.fromJson(e as Map<String, dynamic>)).toList();
  }
}
