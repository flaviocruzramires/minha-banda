import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../eventos/domain/entities/evento.dart';
import '../../domain/entities/bloqueio.dart';
import '../../domain/repositories/agenda_repository.dart';

class HttpAgendaRepository implements AgendaRepository {
  HttpAgendaRepository({http.Client? client, String? baseUrl, required this.token})
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
  Future<List<Evento>> listarEventos() async {
    final res = await _client.get(Uri.parse('$_base/api/v1/agenda/eventos'), headers: _headers);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data']['eventos'] as List<dynamic>;
    return list.map((e) => Evento.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Bloqueio>> listarBloqueios(String userId) async {
    final res = await _client.get(Uri.parse('$_base/api/v1/agenda/bloqueios'), headers: _headers);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data']['bloqueios'] as List<dynamic>;
    return list.map((e) => Bloqueio.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Bloqueio> adicionarBloqueio({
    required String userId, required String titulo,
    required DateTime dataHoraInicio, required DateTime dataHoraFim,
  }) async {
    final res = await _client.post(Uri.parse('$_base/api/v1/agenda/bloqueios'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId, 'titulo': titulo,
          'dataHoraInicio': dataHoraInicio.toIso8601String(),
          'dataHoraFim': dataHoraFim.toIso8601String(),
        }));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Bloqueio.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> removerBloqueio(String id) async {
    await _client.delete(Uri.parse('$_base/api/v1/agenda/bloqueios/$id'), headers: _headers);
  }
}
