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

  // shelf_router não suporta parâmetros em mount() — registrar rotas completas diretamente.
  final protectedApi = Router()
    // Bandas (sem parâmetro no mount — funciona corretamente)
    ..mount('/bandas/', sl.bandaController.router.call)
    // Músicas por banda — rotas com parâmetro registradas individualmente
    ..get('/bandas/<bandaId>/musicas/', sl.musicaController.listar)
    ..post('/bandas/<bandaId>/musicas/', sl.musicaController.criar)
    ..get('/bandas/<bandaId>/musicas/<id>', sl.musicaController.buscar)
    ..put('/bandas/<bandaId>/musicas/<id>', sl.musicaController.atualizar)
    ..delete('/bandas/<bandaId>/musicas/<id>', sl.musicaController.deletar)
    // Integrantes por banda
    ..get('/bandas/<bandaId>/integrantes/', sl.integrantesController.listar)
    ..get('/bandas/<bandaId>/integrantes/<userId>', sl.integrantesController.buscar)
    ..put('/bandas/<bandaId>/integrantes/<userId>', sl.integrantesController.atualizar)
    ..delete('/bandas/<bandaId>/integrantes/<userId>', sl.integrantesController.remover)
    // Eventos por banda
    ..get('/bandas/<bandaId>/eventos/', sl.eventoController.listar)
    ..post('/bandas/<bandaId>/eventos/', sl.eventoController.criar)
    // Eventos por id (buscar/atualizar/deletar)
    ..mount('/eventos/', sl.eventoController.router.call)
    // Confirmações de presença
    ..get('/eventos/<eventoId>/confirmacoes/', sl.eventoActionsController.listarConfirmacoes)
    ..post('/eventos/<eventoId>/confirmacoes/', sl.eventoActionsController.confirmar)
    // Checklist
    ..get('/eventos/<eventoId>/checklist/', sl.eventoActionsController.listarChecklist)
    ..post('/eventos/<eventoId>/checklist/', sl.eventoActionsController.addItem)
    ..put('/eventos/<eventoId>/checklist/<itemId>', sl.eventoActionsController.toggleItem)
    ..delete('/eventos/<eventoId>/checklist/<itemId>', sl.eventoActionsController.deleteItem)
    // Setlist
    ..get('/eventos/<eventoId>/setlist/', sl.setlistController.getSetlist)
    ..put('/eventos/<eventoId>/setlist/', sl.setlistController.setSetlist)
    // Locais
    ..mount('/locais/', sl.localController.router.call)
    ..get('/meus-locais', sl.localController.meusLocaisHandler)
    // Contexto do usuário
    ..get('/meu-contexto', sl.contextoController.handler)
    // Agenda / Bloqueios
    ..mount('/agenda/', sl.bloqueioController.router.call)
    // Conflitos
    ..mount('/conflitos/', sl.conflitosController.router.call)
    // Teleprompter
    ..mount('/teleprompter/', sl.teleprompterController.router.call);

  final protectedHandler = Pipeline()
      .addMiddleware(authMiddleware())
      .addHandler(protectedApi.call);

  final root = Router()
    ..get('/health/', _health)
    ..mount('/api/v1/auth/', sl.authController.router.call)
    ..mount('/api/v1/', protectedHandler);

  final handler = Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(loggerMiddleware())
      .addMiddleware(errorHandlerMiddleware())
      .addHandler(root.call);

  final server = await io.serve(handler, cfg.host, cfg.port);
  Logger('Server').info('Rodando em http://${server.address.host}:${server.port}');

  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) async {
      await sl.close();
      await server.close(force: true);
      exit(0);
    });
  }
}

Response _health(Request _) =>
    ResponseHelper.ok({'status': 'ok', 'service': 'minha-banda-api'});
