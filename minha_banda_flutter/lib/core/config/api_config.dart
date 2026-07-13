import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// URL base da API. Sobrescrita via --dart-define=API_BASE_URL=... em produção.
String get kApiBaseUrl {
  const envUrl = String.fromEnvironment('API_BASE_URL');
  if (envUrl.isNotEmpty) return envUrl;
  if (kIsWeb) return 'http://localhost:8081';
  if (!kIsWeb && Platform.isAndroid) return 'http://192.168.101.6:8081';
  return 'http://localhost:8081'; // Windows, macOS, iOS simulator
}
