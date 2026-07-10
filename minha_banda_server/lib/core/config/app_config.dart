import 'dart:io';
import 'package:dotenv/dotenv.dart';

class AppConfig {
  AppConfig._();
  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  late final String databaseUrl;
  late final String jwtSecret;
  late final int jwtExpiresMinutes;
  late final String host;
  late final int port;
  late final String env;

  static void load() {
    final dot = DotEnv(includePlatformEnvironment: true)..load(['.env']);

    _instance = AppConfig._()
      ..databaseUrl = _require(dot, 'DATABASE_URL')
      ..jwtSecret = _require(dot, 'JWT_SECRET')
      ..jwtExpiresMinutes = int.parse(dot['JWT_EXPIRES_MINUTES'] ?? '60')
      ..host = dot['HOST'] ?? '0.0.0.0'
      ..port = int.parse(dot['PORT'] ?? '8080')
      ..env = dot['DART_ENV'] ?? 'development';
  }

  bool get isProduction => env == 'production';

  static void loadTest({
    required String jwtSecret,
    int jwtExpiresMinutes = 60,
  }) {
    _instance = AppConfig._()
      ..databaseUrl = 'postgres://test'
      ..jwtSecret = jwtSecret
      ..jwtExpiresMinutes = jwtExpiresMinutes
      ..host = 'localhost'
      ..port = 8080
      ..env = 'test';
  }

  static String _require(DotEnv dot, String key) {
    final v = dot[key];
    if (v == null || v.isEmpty) {
      throw StateError('Variável de ambiente obrigatória não encontrada: $key');
    }
    return v;
  }
}
