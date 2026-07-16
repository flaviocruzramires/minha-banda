import 'package:postgres/postgres.dart';
import '../../features/auth/controller/auth_controller.dart';
import '../../features/auth/controller/contexto_controller.dart';
import '../../features/auth/data/repositories/user_repository.dart';
import '../../features/auth/service/auth_service.dart';
import '../../features/bandas/controller/banda_controller.dart';
import '../../features/bandas/data/repositories/banda_repository.dart';
import '../../features/bandas/service/banda_service.dart';
import '../../features/integrantes/controller/integrantes_controller.dart';
import '../../features/integrantes/data/repositories/integrantes_repository.dart';
import '../../features/integrantes/service/integrantes_service.dart';
import '../../features/locais/controller/local_controller.dart';
import '../../features/locais/data/repositories/local_repository.dart';
import '../../features/locais/service/local_service.dart';
import '../../features/repertorio/controller/musica_controller.dart';
import '../../features/repertorio/controller/setlist_controller.dart';
import '../../features/repertorio/data/repositories/musica_repository.dart';
import '../../features/repertorio/service/musica_service.dart';
import '../../features/teleprompter/controller/teleprompter_controller.dart';
import '../../features/eventos/controller/evento_controller.dart';
import '../../features/eventos/data/repositories/evento_repository.dart';
import '../../features/eventos/service/evento_service.dart';
import '../../features/agenda/controller/bloqueio_controller.dart';
import '../../features/agenda/data/repositories/bloqueio_repository.dart';
import '../../features/agenda/service/bloqueio_service.dart';
import '../../features/conflitos/controller/conflitos_controller.dart';
import '../../features/conflitos/service/conflitos_service.dart';
import '../../features/notificacoes/controller/notificacao_controller.dart';
import '../../features/notificacoes/data/repositories/notificacao_repository.dart';
import '../../features/notificacoes/service/notificacao_service.dart';
import '../config/app_config.dart';

class ServiceLocator {
  ServiceLocator._();

  late final Pool _db;
  late final AuthController authController;
  late final BandaController bandaController;
  late final MusicaController musicaController;
  late final SetlistController setlistController;
  late final TeleprompterController teleprompterController;
  late final LocalController localController;
  late final IntegrantesController integrantesController;
  late final ContextoController contextoController;
  late final EventoController eventoController;
  late final EventoActionsController eventoActionsController;
  late final BloqueioController bloqueioController;
  late final ConflitosController conflitosController;
  late final NotificacaoController notificacaoController;

  static Future<ServiceLocator> init() async {
    final sl = ServiceLocator._();
    await sl._setup();
    return sl;
  }

  Future<void> _setup() async {
    final cfg = AppConfig.instance;

    final uri = Uri.parse(cfg.databaseUrl);
    final endpoint = Endpoint(
      host: uri.host,
      database: uri.pathSegments.first,
      username: uri.userInfo.split(':').first,
      password: uri.userInfo.split(':').last,
      port: uri.port != 0 ? uri.port : 5432,
    );
    _db = Pool.withEndpoints(
      [endpoint],
      settings: PoolSettings(
        maxConnectionCount: 4,
        sslMode: cfg.isProduction ? SslMode.require : SslMode.disable,
      ),
    );

    final userRepo = PostgresUserRepository(_db);
    final bandaRepo = PostgresBandaRepository(_db);
    final localRepo = PostgresLocalRepository(_db);
    final integrantesRepo = PostgresIntegrantesRepository(_db);

    final authService = AuthService(userRepo);
    final bandaService = BandaService(bandaRepo);
    final localService = LocalService(localRepo);
    final integrantesService = IntegrantesService(integrantesRepo);

    final baseUrl = cfg.isProduction
        ? 'https://api.minha-banda.com.br'
        : 'http://localhost:${cfg.port}';

    final musicaRepo = PostgresMusicaRepository(_db);
    final musicaService = MusicaService(musicaRepo);

    authController = AuthController(authService);
    bandaController = BandaController(bandaService, baseUrl: baseUrl);
    musicaController = MusicaController(musicaService);
    setlistController = SetlistController(musicaService);
    teleprompterController = TeleprompterController(musicaRepo);
    localController = LocalController(localService);
    integrantesController = IntegrantesController(integrantesService);
    contextoController = ContextoController(_db);

    final eventoRepo = PostgresEventoRepository(_db);
    final bloqueioRepo = PostgresBloqueioRepository(_db);
    final eventoService = EventoService(eventoRepo);
    eventoController = EventoController(eventoService);
    eventoActionsController = EventoActionsController(eventoService);
    final bloqueioService = BloqueioService(bloqueioRepo, eventoRepo, _db);
    bloqueioController = BloqueioController(bloqueioService);
    final conflitosService = ConflitosService(eventoRepo, bloqueioRepo, _db);
    conflitosController = ConflitosController(conflitosService);

    final notificacaoRepo = PostgresNotificacaoRepository(_db);
    final notificacaoService = NotificacaoService(notificacaoRepo);
    notificacaoController = NotificacaoController(notificacaoService);
  }

  Future<void> close() async => _db.close();
}
