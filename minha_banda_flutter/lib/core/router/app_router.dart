import 'package:go_router/go_router.dart';

import '../../features/agenda/presentation/pages/agenda_page.dart';
import '../../features/agenda/presentation/pages/novo_bloqueio_page.dart';
import '../../features/eventos/presentation/pages/evento_detalhe_page.dart';
import '../../features/eventos/presentation/pages/evento_form_page.dart';
import '../../features/eventos/presentation/pages/eventos_lista_page.dart';
import '../../features/integrantes/domain/entities/integrante.dart';
import '../../features/integrantes/presentation/pages/integrante_perfil_page.dart';
import '../../features/integrantes/presentation/pages/integrantes_lista_page.dart';
import '../../features/locais/presentation/pages/local_form_page.dart';
import '../../features/locais/presentation/pages/locais_lista_page.dart';
import '../../features/repertorio/domain/entities/musica.dart';
import '../../features/repertorio/presentation/pages/musica_form_page.dart';
import '../../features/repertorio/presentation/pages/repertorio_lista_page.dart';
import '../../features/teleprompter/presentation/pages/teleprompter_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AgendaPage()),
    GoRoute(
      path: '/repertorio/:bandaId',
      builder: (context, state) =>
          RepertorioListaPage(bandaId: state.pathParameters['bandaId']!),
    ),
    GoRoute(
      path: '/musica-form/:bandaId',
      builder: (context, state) => MusicaFormPage(
        bandaId: state.pathParameters['bandaId']!,
        musica: state.extra as Musica?,
      ),
    ),
    GoRoute(
      path: '/eventos/:bandaId',
      builder: (context, state) =>
          EventosListaPage(bandaId: state.pathParameters['bandaId']!),
    ),
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
      path: '/novo-bloqueio',
      builder: (context, state) => const NovoBloqueioPage(),
    ),
    GoRoute(
      path: '/locais',
      builder: (context, state) => const LocaisListaPage(),
    ),
    GoRoute(
      path: '/local-form',
      builder: (context, state) => const LocalFormPage(),
    ),
    GoRoute(
      path: '/integrantes/:bandaId',
      builder: (context, state) =>
          IntegrantesListaPage(bandaId: state.pathParameters['bandaId']!),
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
