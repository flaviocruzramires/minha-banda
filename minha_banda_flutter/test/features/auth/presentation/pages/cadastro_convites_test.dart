import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:minha_banda_flutter/features/auth/domain/entities/app_user.dart';
import 'package:minha_banda_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:minha_banda_flutter/features/auth/presentation/notifiers/cadastro_notifier.dart';
import 'package:minha_banda_flutter/features/auth/presentation/pages/cadastro_convites_page.dart';
import 'package:minha_banda_flutter/features/bandas/domain/entities/banda.dart';

import '../../../../helpers/pump_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _usuarioFixture = AppUser(
  id: 'usr_1',
  nomeArtistico: 'Carlos',
  email: 'carlos@test.com',
);

final _bandaFixture = Banda(
  id: 'banda_1',
  nome: 'Os Testes',
  generoMusical: 'Rock',
  cidade: 'SP',
  cor: const Color(0xFF7A1F3D),
);

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  List<Override> overrides({
    required CadastroState estadoInicial,
  }) =>
      [
        authRepositoryProvider.overrideWithValue(repo),
        cadastroNotifierProvider.overrideWith(
          (ref) => CadastroNotifier(repo)..state = estadoInicial,
        ),
      ];

  final estadoComBanda = CadastroState(
    status: CadastroStatus.success,
    usuario: _usuarioFixture,
    banda: _bandaFixture,
    linkConvite: 'https://minha.banda/convite/banda_1',
  );

  group('CadastroConvitesPage', () {
    testWidgets('exibe título e botões esperados', (tester) async {
      await tester.pumpApp(
        const CadastroConvitesPage(),
        overrides: overrides(estadoInicial: estadoComBanda),
      );

      expect(find.text('Convide a galera'), findsOneWidget);
      expect(find.text('PASSO 3 DE 3'), findsOneWidget);
      expect(find.byKey(const Key('btn_concluir')), findsOneWidget);
      expect(find.byKey(const Key('btn_convidar_depois')), findsOneWidget);
    });

    testWidgets('exibe link de convite quando banda existe', (tester) async {
      await tester.pumpApp(
        const CadastroConvitesPage(),
        overrides: overrides(estadoInicial: estadoComBanda),
      );

      expect(find.text('Link de convite da banda'), findsOneWidget);
      expect(find.byKey(const Key('btn_copiar_link')), findsOneWidget);
    });

    testWidgets('validação rejeita e-mail inválido', (tester) async {
      await tester.pumpApp(
        const CadastroConvitesPage(),
        overrides: overrides(estadoInicial: estadoComBanda),
      );

      await tester.enterText(
          find.byKey(const Key('campo_email_convite')), 'invalido');
      await tester.tap(find.byKey(const Key('btn_convidar')));
      await tester.pump();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('convidar por e-mail válido adiciona card na lista',
        (tester) async {
      when(() => repo.convidarPorEmail(
            bandaId: any(named: 'bandaId'),
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      await tester.pumpApp(
        const CadastroConvitesPage(),
        overrides: overrides(estadoInicial: estadoComBanda),
      );

      await tester.enterText(
          find.byKey(const Key('campo_email_convite')),
          'guitarrista@test.com');
      await tester.tap(find.byKey(const Key('btn_convidar')));
      await tester.pumpAndSettle();

      expect(find.text('guitarrista@test.com'), findsOneWidget);
      expect(find.text('Convite enviado'), findsOneWidget);

      verify(() => repo.convidarPorEmail(
            bandaId: 'banda_1',
            email: 'guitarrista@test.com',
          )).called(1);
    });

    testWidgets('convida múltiplos e-mails e lista todos', (tester) async {
      when(() => repo.convidarPorEmail(
            bandaId: any(named: 'bandaId'),
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      await tester.pumpApp(
        const CadastroConvitesPage(),
        overrides: overrides(estadoInicial: estadoComBanda),
      );

      for (final email in ['a@test.com', 'b@test.com', 'c@test.com']) {
        await tester.enterText(
            find.byKey(const Key('campo_email_convite')), email);
        await tester.tap(find.byKey(const Key('btn_convidar')));
        await tester.pumpAndSettle();
      }

      expect(find.text('Convite enviado'), findsNWidgets(3));
    });

    testWidgets('sem banda não exibe link de convite', (tester) async {
      await tester.pumpApp(
        const CadastroConvitesPage(),
        overrides: overrides(
          estadoInicial: const CadastroState(
            status: CadastroStatus.idle,
            usuario: _usuarioFixture,
          ),
        ),
      );

      expect(find.text('Link de convite da banda'), findsNothing);
    });
  });
}
