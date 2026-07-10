import 'dart:convert';
import 'package:shelf/shelf.dart';

abstract final class ResponseHelper {
  static const _headers = {'content-type': 'application/json'};

  static Response ok(Object data) =>
      Response.ok(_encode({'data': data}), headers: _headers);

  static Response created(Object data) =>
      Response(201, body: _encode({'data': data}), headers: _headers);

  static Response noContent() => Response(204, headers: _headers);

  static Response error(int statusCode, String message) => Response(
        statusCode,
        body: _encode({'error': message}),
        headers: _headers,
      );

  static String _encode(Object obj) => jsonEncode(obj);
}
