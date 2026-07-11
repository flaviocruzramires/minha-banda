import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_banda_flutter/features/teleprompter/data/repositories/mock_teleprompter_repository.dart';
import 'package:minha_banda_flutter/features/teleprompter/domain/entities/musica_teleprompter.dart';
import 'package:minha_banda_flutter/features/teleprompter/presentation/notifiers/teleprompter_notifier.dart';

void main() {
  group('TeleprompterNotifier', () {
    test('loading -> success with mock', () async {
      final container = ProviderContainer(overrides: [
        teleprompterRepositoryProvider.overrideWithValue(MockTeleprompterRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(teleprompterNotifierProvider.notifier).carregar('evento-1');
      final state = container.read(teleprompterNotifierProvider);

      expect(state.status, TeleprompterStatus.success);
      expect(state.musicas, isNotEmpty);
    });

    test('loading -> error with throwing mock', () async {
      final container = ProviderContainer(overrides: [
        teleprompterRepositoryProvider.overrideWithValue(_ThrowingTeleprompterRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(teleprompterNotifierProvider.notifier).carregar('evento-1');
      final state = container.read(teleprompterNotifierProvider);

      expect(state.status, TeleprompterStatus.error);
      expect(state.erro, isNotNull);
    });

    test('toggleRolar changes rolando state', () async {
      final container = ProviderContainer(overrides: [
        teleprompterRepositoryProvider.overrideWithValue(MockTeleprompterRepository()),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(teleprompterNotifierProvider.notifier);
      expect(container.read(teleprompterNotifierProvider).rolando, false);
      notifier.toggleRolar();
      expect(container.read(teleprompterNotifierProvider).rolando, true);
      notifier.toggleRolar();
      expect(container.read(teleprompterNotifierProvider).rolando, false);
    });
  });
}

class _ThrowingTeleprompterRepository extends MockTeleprompterRepository {
  @override
  Future<List<MusicaTeleprompter>> getEventoComLetra(String eventoId) => Future.error(Exception('fail'));
}
