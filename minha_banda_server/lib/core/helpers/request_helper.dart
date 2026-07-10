import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../exceptions/app_exception.dart';

abstract final class RequestHelper {
  static Future<Map<String, dynamic>> parseBody(Request request) async {
    final body = await request.readAsString();
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const ValidationException('Body deve ser um objeto JSON.');
      }
      return decoded;
    } catch (e) {
      if (e is AppException) rethrow;
      throw const ValidationException('JSON inválido.');
    }
  }

  static String? bearerToken(Request request) {
    final auth = request.headers['authorization'];
    if (auth == null || !auth.startsWith('Bearer ')) return null;
    return auth.substring(7);
  }
}
