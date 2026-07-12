import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:minha_banda_flutter/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:minha_banda_flutter/features/auth/domain/entities/app_user.dart';
import 'package:minha_banda_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:minha_banda_flutter/features/auth/presentation/notifiers/cadastro_notifier.dart';
import 'package:minha_banda_flutter/features/auth/presentation/pages/cadastro_dados_pessoais_page.dart';

import '../../../../helpers/pump_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  List<Override> overrides() => [
        authRepositoryProvider.overrideWithValue(repo),
      ];

  group('CadastroDadosPessoaisPage', () {
    testWidgets('exibe campos obrigatórios e botão continuar', (tester) async {
      await tester.pumpApp(
        const CadastroDadosPessoaisPage(),
        overrides: overrides(),
      );

      expect(find.text('Crie sua conta'), findsOneWidget);
      expect(find.text('PASSO 1 DE 3'), findsOneWidget);
      expect(find.byKey(const Key('btn_continuar')), findsOneWidget);
      expect(find.byKey(const Key('btn_google')), findsOneWidget);
    });

    testWidgets('validação impede submit com campos vazios', (tester) async {
      await tester.pumpApp(
        const CadastroDadosPessoaisPage(),
        overrides: overrides(),
      );

      await tester.tap(find.byKey(const Key('btn_continuar')));
      await tester.pump();

      expect(find.text('Informe seu nome'), findsOneWidget);
      expect(find.text('Informe o e-mail'), findsOneWidget);
      expect(find.text('Informe a senha'), findsOneWidget);
      verifyNever(() => repo.cadastrar(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senha: any(named: 'senha'),
          ));
    });

    testWidgets('validação rejeita e-mail sem @', (tester) async {
      await tester.pumpApp(
        const CadastroDadosPessoaisPage(),
        overrides: overrides(),
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Como você é conhecido'),
          'Carlos');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'seu@email.com'), 'invalido');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Crie uma senha segura'),
          'senha123');
      await tester.tap(find.byKey(const Key('btn_continuar')));
      await tester.pump();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('validação rejeita senha com menos de 8 caracteres',
        (tester) async {
      await tester.pumpApp(
        const CadastroDadosPessoaisPage(),
        overrides: overrides(),
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Como você é conhecido'),
          'Carlos');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'seu@email.com'),
          'carlos@test.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Crie uma senha segura'), '123');
      await tester.ensureVisible(find.byKey(const Key('btn_continuar')));
      await tester.tap(find.byKey(const Key('btn_continuar')));
      await tester.pump();

      expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    });

    testWidgets('exibe erro inline quando e-mail já está cadastrado',
        (tester) async {
      when(() => repo.cadastrar(
            nomeArtistico: any(named: 'nomeArtistico'),
            email: any(named: 'email'),
            senha: any(named: 'senha'),
          )).thenThrow(const EmailJaCadastradoException());

      await tester.pumpApp(
        const CadastroDadosPessoaisPage(),
        overrides: overrides(),
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Como você é conhecido'),
          'Carlos');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'seu@email.com'),
          'carlos@test.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Crie uma senha segura'),
          'senha123');

      await tester.tap(find.byKey(const Key('btn_continuar')));
      await tester.pumpAndSettle();

      expect(find.text('Este e-mail já está cadastrado.'), findsOneWidget);
    });

    testWidgets('submit válido chama repositório com dados corretos',
        (tester) async {
      when(() => repo.cadastrar(
            nomeArtistico: 'Carlos Santana',
            email: 'carlos@test.com',
            senha: 'senha123',
          )).thenAnswer((_) async => (
                user: const AppUser(
                  id: 'usr_1',
                  nomeArtistico: 'Carlos Santana',
                  email: 'carlos@test.com',
                ),
                token: 'tok',
              ));

      await tester.pumpApp(
        Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => const CadastroDadosPessoaisPage(),
          ),
        ),
        overrides: overrides(),
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Como você é conhecido'),
          'Carlos Santana');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'seu@email.com'),
          'carlos@test.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Crie uma senha segura'),
          'senha123');

      await tester.tap(find.byKey(const Key('btn_continuar')));
      await tester.pumpAndSettle();

      verify(() => repo.cadastrar(
            nomeArtistico: 'Carlos Santana',
            email: 'carlos@test.com',
            senha: 'senha123',
          )).called(1);
    });

    testWidgets('botão toggle mostra/oculta senha', (tester) async {
      await tester.pumpApp(
        const CadastroDadosPessoaisPage(),
        overrides: overrides(),
      );

      expect(find.byKey(const Key('btn_toggle_senha')), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byKey(const Key('btn_toggle_senha')));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
