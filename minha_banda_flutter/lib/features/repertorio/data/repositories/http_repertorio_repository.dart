import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/musica.dart';
import '../../domain/repositories/repertorio_repository.dart';

class HttpRepertorioRepository implements RepertorioRepository {
  HttpRepertorioRepository({
    http.Client? client,
    String? baseUrl,
    required this.token,
  })  : _client = client ?? http.Client(),
        _base = baseUrl ?? kApiBaseUrl;

  final http.Client _client;
  final String _base;
  final String token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  @override
  Future<List<Musica>> listar(String bandaId) async {
    final res = await _client.get(
      Uri.parse('$_base/api/v1/bandas/$bandaId/musicas/'),
      headers: _headers,
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data']['musicas'] as List<dynamic>;
    return list.map((e) => Musica.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Musica> criar({
    required String bandaId,
    required String titulo,
    String? artistaOriginal,
    String? tonalidade,
    int? bpm,
    int? duracaoSeg,
    List<String> tags = const [],
    String? letra,
    String? cifra,
    String? linkReferencia,
    String? notasArranjo,
    required String status,
  }) async {
    final res = await _client.post(
      Uri.parse('$_base/api/v1/bandas/$bandaId/musicas/'),
      headers: _headers,
      body: jsonEncode({
        'titulo': titulo,
        'artistaOriginal': artistaOriginal,
        'tonalidade': tonalidade,
        'bpm': bpm,
        'duracaoSeg': duracaoSeg,
        'tags': tags,
        'letra': letra,
        'cifra': cifra,
        'linkReferencia': linkReferencia,
        'notasArranjo': notasArranjo,
        'status': status,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Musica.fromJson((body['data'] as Map<String, dynamic>)['musica'] as Map<String, dynamic>);
  }

  @override
  Future<Musica> atualizar(Musica musica) async {
    final res = await _client.put(
      Uri.parse('$_base/api/v1/bandas/${musica.bandaId}/musicas/${musica.id}'),
      headers: _headers,
      body: jsonEncode(musica.toJson()),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Musica.fromJson((body['data'] as Map<String, dynamic>)['musica'] as Map<String, dynamic>);
  }

  @override
  Future<void> deletar(String bandaId, String id) async {
    await _client.delete(
      Uri.parse('$_base/api/v1/bandas/$bandaId/musicas/$id'),
      headers: _headers,
    );
  }
}
