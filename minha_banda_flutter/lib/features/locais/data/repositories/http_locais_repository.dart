import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/local.dart';
import '../../domain/repositories/locais_repository.dart';

class HttpLocaisRepository implements LocaisRepository {
  HttpLocaisRepository({http.Client? client, String? baseUrl, required this.token})
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
  Future<List<Local>> listar() async {
    final res = await _client.get(Uri.parse('$_base/api/v1/locais'), headers: _headers);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data']['locais'] as List<dynamic>;
    return list.map((e) => Local.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Local> criar({
    required String nome, required String cidade, required String tipo,
    int? capacidade, String? contato, bool temSom = false, bool temCamarim = false, String? notas,
  }) async {
    final res = await _client.post(Uri.parse('$_base/api/v1/locais'),
        headers: _headers,
        body: jsonEncode({'nome': nome, 'cidade': cidade, 'tipo': tipo,
          'capacidade': capacidade, 'contato': contato,
          'temSom': temSom, 'temCamarim': temCamarim, 'notas': notas}));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Local.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deletar(String id) async {
    await _client.delete(Uri.parse('$_base/api/v1/locais/$id'), headers: _headers);
  }
}
