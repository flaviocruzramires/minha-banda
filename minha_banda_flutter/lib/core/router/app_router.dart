import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_shell.dart';
import '../../features/agenda/presentation/pages/agenda_page.dart';
import '../../features/agenda/presentation/pages/novo_bloqueio_page.dart';
import '../../features/auth/presentation/pages/cadastro_dados_pessoais_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/contexto/domain/entities/vinculo_contexto.dart';
import '../../features/contexto/presentation/notifiers/contexto_notifier.dart';
import '../../features/contexto/presentation/pages/seletor_contexto_page.dart';
import '../../features/eventos/presentation/pages/evento_detalhe_page.dart';
import '../../features/eventos/presentation/pages/evento_form_page.dart';
import '../../features/eventos/presentation/pages/eventos_lista_page.dart';
import '../../features/integrantes/domain/entities/integrante.dart';
import '../../features/integrantes/presentation/pages/integrante_perfil_page.dart';
import '../../features/integrantes/presentation/pages/integrantes_lista_page.dart';
import '../../features/locais/domain/entities/local.dart';
import '../../features/locais/presentation/pages/local_form_page.dart';
import '../../features/locais/presentation/pages/locais_lista_page.dart';
import '../../features/repertorio/domain/entities/musica.dart';
import '../../features/repertorio/presentation/pages/musica_form_page.dart';
import '../../features/repertorio/presentation/pages/repertorio_lista_page.dart';
import '../../features/setlist/presentation/pages/setlist_page.dart';
import '../../features/teleprompter/presentation/pages/teleprompter_page.dart';
import '../providers/auth_token_provider.dart';

// ---------------------------------------------------------------------------
// RouterNotifier — liga mudanças no token e contexto ao GoRouter
// ---------------------------------------------------------------------------

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<String?>(authTokenProvider, (_, __) => notifyListeners());
    _ref.listen<ContextoState>(contextoNotifierProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final token = _ref.read(authTokenProvider);
    final loc = state.matchedLocation;

    final isPublic = loc == '/login' || loc.startsWith('/cadastro');

    if (token == null && !isPublic) return '/login';
    if (token != null && loc == '/login') return '/';

    if (token != null && !isPublic && loc != '/seletor-contexto') {
      final contextoState = _ref.read(contextoNotifierProvider);
      if (contextoState.precisaSeletor) return '/seletor-contexto';
    }

    return null;
  }
}

// ---------------------------------------------------------------------------
// Provider do router
// ---------------------------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // Rotas públicas
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/cadastro',
        builder: (context, state) => const CadastroDadosPessoaisPage(),
      ),
      GoRoute(
        path: '/seletor-contexto',
        builder: (context, state) => const SeletorContextoPage(),
      ),

      // Shell principal com bottom navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const AgendaPage(),
          ),
          GoRoute(
            path: '/eventos/:bandaId',
            builder: (context, state) =>
                EventosListaPage(bandaId: state.pathParameters['bandaId']!),
          ),
          GoRoute(
            path: '/repertorio/:bandaId',
            builder: (context, state) =>
                RepertorioListaPage(bandaId: state.pathParameters['bandaId']!),
          ),
          GoRoute(
            path: '/integrantes/:bandaId',
            builder: (context, state) =>
                IntegrantesListaPage(bandaId: state.pathParameters['bandaId']!),
          ),
          GoRoute(
            path: '/locais',
            builder: (context, state) => const LocaisListaPage(),
          ),
        ],
      ),

      // Rotas fora do shell (tela cheia)
      GoRoute(
        path: '/evento/:id',
        builder: (context, state) =>
            EventoDetalhePage(eventoId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/evento-form/:bandaId',
        builder: (context, state) =>
            EventoFormPage(bandaId: state.pathParameters['bandaId']!),
      ),
      GoRoute(
        path: '/setlist/:eventoId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return SetlistPage(
            eventoId: state.pathParameters['eventoId']!,
            bandaId: extra['bandaId'] as String? ?? '',
            tituloEvento: extra['titulo'] as String? ?? 'Evento',
          );
        },
      ),
      GoRoute(
        path: '/novo-bloqueio',
        builder: (context, state) => const NovoBloqueioPage(),
      ),
      GoRoute(
        path: '/local-form',
        builder: (context, state) =>
            LocalFormPage(local: state.extra as Local?),
      ),
      GoRoute(
        path: '/musica-form/:bandaId',
        builder: (context, state) => MusicaFormPage(
          bandaId: state.pathParameters['bandaId']!,
          musica: state.extra as Musica?,
        ),
      ),
      GoRoute(
        path: '/integrante-perfil',
        builder: (context, state) =>
            IntegrantePerfilPage(integrante: state.extra as Integrante),
      ),
      GoRoute(
        path: '/teleprompter/:eventoId',
        builder: (context, state) =>
            TeleprompterPage(eventoId: state.pathParameters['eventoId']!),
      ),
    ],
  );
});
