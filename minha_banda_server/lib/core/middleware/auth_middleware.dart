import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import '../config/app_config.dart';
import '../exceptions/app_exception.dart';
import '../helpers/request_helper.dart';

const _userIdKey = 'userId';

Middleware authMiddleware() {
  return (Handler inner) {
    return (Request request) async {
      final token = RequestHelper.bearerToken(request);
      if (token == null) throw const UnauthorizedException();

      try {
        final jwt = JWT.verify(
          token,
          SecretKey(AppConfig.instance.jwtSecret),
        );
        final userId = jwt.payload['sub'] as String?;
        if (userId == null) throw const UnauthorizedException();
        return await inner(
          request.change(context: {...request.context, _userIdKey: userId}),
        );
      } on JWTExpiredException {
        throw const UnauthorizedException('Token expirado.');
      } on JWTException {
        throw const UnauthorizedException('Token inválido.');
      }
    };
  };
}

extension RequestAuth on Request {
  String get userId {
    final id = context[_userIdKey] as String?;
    if (id == null) throw const UnauthorizedException();
    return id;
  }
}
