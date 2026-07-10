import 'dart:io';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import '../lib/core/config/app_config.dart';
import '../lib/core/di/service_locator.dart';
import '../lib/core/helpers/response_helper.dart';
import '../lib/core/middleware/auth_middleware.dart';
import '../lib/core/middleware/cors_middleware.dart';
import '../lib/core/middleware/error_handler_middleware.dart';
import '../lib/core/middleware/logger_middleware.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    final msg = '[${r.level.name}] ${r.loggerName}: ${r.message}';
    if (r.level >= Level.WARNING) {
      stderr.writeln(msg);
    } else {
      stdout.writeln(msg);
    }
    if (r.error != null) stderr.writeln(r.error);
    if (r.stackTrace != null) stderr.writeln(r.stackTrace);
  });

  AppConfig.load();
  final cfg = AppConfig.instance;
  final sl = await ServiceLocator.init();

  final authRequired = Pipeline().addMiddleware(authMiddleware()).handler;

  final api = Router()
    ..mount('/auth/', sl.authController.router.call)
    ..mount('/bandas/', Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler(sl.bandaController.router.call));

  final root = Router()
    ..get('/health/', _health)
    ..mount('/api/v1/', api.call);

  final handler = Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(loggerMiddleware())
      .addMiddleware(errorHandlerMiddleware())
      .addHandler(root.call);

  final server = await io.serve(handler, cfg.host, cfg.port);
  Logger('Server').info('Rodando em http://${server.address.host}:${server.port}');

  ProcessSignal.sigterm.watch().listen((_) async {
    await sl.close();
    await server.close(force: true);
    exit(0);
  });
}

Response _health(Request _) =>
    ResponseHelper.ok({'status': 'ok', 'service': 'minha-banda-api'});
