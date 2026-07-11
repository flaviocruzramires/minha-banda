import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/checklist_item.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/evento_confirmacao.dart';
import '../../domain/repositories/eventos_repository.dart';

class HttpEventosRepository implements EventosRepository {
  HttpEventosRepository({http.Client? client, String? baseUrl, required this.token})
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
  Future<List<Evento>> listar(String bandaId) async {
    final res = await _client.get(Uri.parse('$_base/api/v1/bandas/$bandaId/eventos'), headers: _headers);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data']['eventos'] as List<dynamic>;
    return list.map((e) => Evento.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Evento> criar({
    required String bandaId, required String tipo, required String titulo,
    required DateTime dataHoraInicio, DateTime? dataHoraFim, String? localId,
    required String status, String? notas,
  }) async {
    final res = await _client.post(Uri.parse('$_base/api/v1/eventos'), headers: _headers,
        body: jsonEncode({'bandaId': bandaId, 'tipo': tipo, 'titulo': titulo,
          'dataHoraInicio': dataHoraInicio.toIso8601String(),
          'dataHoraFim': dataHoraFim?.toIso8601String(), 'localId': localId,
          'status': status, 'notas': notas}));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Evento.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<Evento> atualizar(Evento evento) async {
    final res = await _client.put(Uri.parse('$_base/api/v1/eventos/${evento.id}'),
        headers: _headers, body: jsonEncode(evento.toJson()));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Evento.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deletar(String id) async {
    await _client.delete(Uri.parse('$_base/api/v1/eventos/$id'), headers: _headers);
  }

  @override
  Future<List<ChecklistItem>> listarChecklist(String eventoId) async {
    final res = await _client.get(Uri.parse('$_base/api/v1/eventos/$eventoId/checklist'), headers: _headers);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data']['checklist'] as List<dynamic>;
    return list.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ChecklistItem> addChecklist({required String eventoId, required String descricao}) async {
    final res = await _client.post(Uri.parse('$_base/api/v1/eventos/$eventoId/checklist'),
        headers: _headers, body: jsonEncode({'descricao': descricao}));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return ChecklistItem.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<ChecklistItem> toggleChecklist(ChecklistItem item) async {
    final res = await _client.put(
        Uri.parse('$_base/api/v1/checklist/${item.id}'),
        headers: _headers,
        body: jsonEncode({'concluido': !item.concluido}));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return ChecklistItem.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<EventoConfirmacao>> listarConfirmacoes(String eventoId) async {
    final res = await _client.get(Uri.parse('$_base/api/v1/eventos/$eventoId/confirmacoes'), headers: _headers);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data']['confirmacoes'] as List<dynamic>;
    return list.map((e) => EventoConfirmacao.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<EventoConfirmacao> confirmarPresenca({required String eventoId, required String userId, required String status}) async {
    final res = await _client.post(Uri.parse('$_base/api/v1/eventos/$eventoId/confirmacoes'),
        headers: _headers, body: jsonEncode({'userId': userId, 'status': status}));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return EventoConfirmacao.fromJson(body['data'] as Map<String, dynamic>);
  }
}
