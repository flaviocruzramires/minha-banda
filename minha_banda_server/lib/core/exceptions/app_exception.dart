abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;
  int get statusCode;
  @override
  String toString() => message;
}

class ValidationException extends AppException {
  const ValidationException(super.message);
  @override
  int get statusCode => 400;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Não autorizado.'])
      : super(message);
  @override
  int get statusCode => 401;
}

class ForbiddenException extends AppException {
  const ForbiddenException([String message = 'Acesso negado.']) : super(message);
  @override
  int get statusCode => 403;
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
  @override
  int get statusCode => 404;
}

class ConflictException extends AppException {
  const ConflictException(super.message);
  @override
  int get statusCode => 409;
}

class InternalServerException extends AppException {
  const InternalServerException(
      [String message = 'Erro interno do servidor.'])
      : super(message);
  @override
  int get statusCode => 500;
}
