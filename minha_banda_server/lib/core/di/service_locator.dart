import 'package:postgres/postgres.dart';
import '../../features/auth/controller/auth_controller.dart';
import '../../features/auth/data/repositories/user_repository.dart';
import '../../features/auth/service/auth_service.dart';
import '../../features/bandas/controller/banda_controller.dart';
import '../../features/bandas/data/repositories/banda_repository.dart';
import '../../features/bandas/service/banda_service.dart';
import '../config/app_config.dart';

class ServiceLocator {
  ServiceLocator._();

  late final Connection _db;
  late final AuthController authController;
  late final BandaController bandaController;

  static Future<ServiceLocator> init() async {
    final sl = ServiceLocator._();
    await sl._setup();
    return sl;
  }

  Future<void> _setup() async {
    final cfg = AppConfig.instance;

    _db = await Connection.open(
      Endpoint(
        host: Uri.parse(cfg.databaseUrl).host,
        database: Uri.parse(cfg.databaseUrl).pathSegments.first,
        username: Uri.parse(cfg.databaseUrl).userInfo.split(':').first,
        password: Uri.parse(cfg.databaseUrl).userInfo.split(':').last,
        port: Uri.parse(cfg.databaseUrl).port != 0
            ? Uri.parse(cfg.databaseUrl).port
            : 5432,
      ),
      settings: ConnectionSettings(
        sslMode: cfg.isProduction ? SslMode.require : SslMode.disable,
      ),
    );

    final userRepo = PostgresUserRepository(_db);
    final bandaRepo = PostgresBandaRepository(_db);

    final authService = AuthService(userRepo);
    final bandaService = BandaService(bandaRepo);

    final baseUrl = cfg.isProduction
        ? 'https://api.minha-banda.com.br'
        : 'http://localhost:${cfg.port}';

    authController = AuthController(authService);
    bandaController = BandaController(bandaService, baseUrl: baseUrl);
  }

  Future<void> close() => _db.close();
}
