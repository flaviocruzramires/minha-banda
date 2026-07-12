class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

void checkResponse(dynamic res) {
  // ignore: avoid_dynamic_calls
  final status = res.statusCode as int;
  if (status == 401) throw const ApiException('Sessão expirada. Faça login novamente.', statusCode: 401);
  if (status >= 400) {
    throw ApiException('Erro $status do servidor.', statusCode: status);
  }
}
