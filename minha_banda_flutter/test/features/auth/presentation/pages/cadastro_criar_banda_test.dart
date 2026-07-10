import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:minha_banda_flutter/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:minha_banda_flutter/features/auth/domain/entities/app_user.dart';
import 'package:minha_banda_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:minha_banda_flutter/features/auth/presentation/notifiers/cadastro_notifier.dart';
import 'package:minha_banda_flutter/features/auth/presentation/pages/cadastro_criar_banda_page.dart';
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

  List<Override> overrides({CadastroState? estadoInicial}) => [
        authRepositoryProvider.overrideWithValue(repo),
        if (estadoInicial != null)
          cadastroNotifierProvider.overrideWith(
            (ref) => CadastroNotifier(repo)..state = estadoInicial,
          ),
      ];

  group('CadastroCriarBandaPage', () {
    testWidgets('exibe campos e botões esperados', (tester) async {
      await tester.pumpApp(
        const CadastroCriarBandaPage(),
        overrides: overrides(),
      );

      expect(find.text('Crie sua banda'), findsOneWidget);
      expect(find.text('PASSO 2 DE 3'), findsOneWidget);
      expect(find.byKey(const Key('btn_criar_banda')), findsOneWidget);
      expect(find.byKey(const Key('btn_pular_banda')), findsOneWidget);
    });

    testWidgets('validação impede submit com campos vazios', (tester) async {
      await tester.pumpApp(
        const CadastroCriarBandaPage(),
        overrides: overrides(),
      );

      await tester.tap(find.byKey(const Key('btn_criar_banda')));
      await tester.pump();

      expect(find.text('Informe o nome da banda'), findsOneWidget);
      expect(find.text('Informe o gênero musical'), findsOneWidget);
      expect(find.text('Informe a cidade'), findsOneWidget);
    });

    testWidgets('exibe erro inline quando nome já está em uso', (tester) async {
      when(() => repo.criarBanda(
            userId: any(named: 'userId'),
            nome: any(named: 'nome'),
            generoMusical: any(named: 'generoMusical'),
            cidade: any(named: 'cidade'),
            corHex: any(named: 'corHex'),
          )).thenThrow(const NomeBandaEmUsoException());

      await tester.pumpApp(
        const CadastroCriarBandaPage(),
        overrides: overrides(
          estadoInicial: const CadastroState(
            status: CadastroStatus.success,
            usuario: _usuarioFixture,
          ),
        ),
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex.: Os Veteranos'), 'Duplicada');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex.: Rock / Blues'), 'Rock');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex.: São Paulo, SP'), 'SP');

      await tester.tap(find.byKey(const Key('btn_criar_banda')));
      await tester.pumpAndSettle();

      expect(
          find.text('Esse nome de banda já está em uso.'), findsOneWidget);
    });

    testWidgets('seleção de cor funciona', (tester) async {
      await tester.pumpApp(
        const CadastroCriarBandaPage(),
        overrides: overrides(),
      );

      final segundaCor = find.byKey(const Key('cor_${0xFF1F4D7A}'));
      expect(segundaCor, findsOneWidget);
      await tester.tap(segundaCor);
      await tester.pump();
    });

    testWidgets('submit válido com usuário no estado chama repositório',
        (tester) async {
      when(() => repo.criarBanda(
            userId: 'usr_1',
            nome: 'Os Testes',
            generoMusical: 'Rock',
            cidade: 'São Paulo, SP',
            corHex: any(named: 'corHex'),
          )).thenAnswer((_) async => _bandaFixture);
      when(() => repo.gerarLinkConvite(any()))
          .thenAnswer((_) async => 'https://minha.banda/convite/banda_1');

      await tester.pumpApp(
        Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => const CadastroCriarBandaPage(),
          ),
        ),
        overrides: overrides(
          estadoInicial: const CadastroState(
            status: CadastroStatus.success,
            usuario: _usuarioFixture,
          ),
        ),
      );

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex.: Os Veteranos'), 'Os Testes');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex.: Rock / Blues'), 'Rock');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex.: São Paulo, SP'),
          'São Paulo, SP');

      await tester.tap(find.byKey(const Key('btn_criar_banda')));
      await tester.pumpAndSettle();

      verify(() => repo.criarBanda(
            userId: 'usr_1',
            nome: 'Os Testes',
            generoMusical: 'Rock',
            cidade: 'São Paulo, SP',
            corHex: any(named: 'corHex'),
          )).called(1);
    });
  });
}
