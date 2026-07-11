import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_banda_flutter/features/eventos/data/repositories/mock_eventos_repository.dart';
import 'package:minha_banda_flutter/features/eventos/domain/entities/evento.dart';
import 'package:minha_banda_flutter/features/eventos/presentation/notifiers/eventos_notifier.dart';

void main() {
  group('EventosNotifier', () {
    test('loading -> success with mock', () async {
      final container = ProviderContainer(overrides: [
        eventosRepositoryProvider.overrideWithValue(MockEventosRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(eventosNotifierProvider.notifier).carregar('banda-1');
      final state = container.read(eventosNotifierProvider);

      expect(state.status, EventosStatus.success);
      expect(state.eventos, isNotEmpty);
    });

    test('loading -> error with throwing mock', () async {
      final container = ProviderContainer(overrides: [
        eventosRepositoryProvider.overrideWithValue(_ThrowingEventosRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(eventosNotifierProvider.notifier).carregar('banda-1');
      final state = container.read(eventosNotifierProvider);

      expect(state.status, EventosStatus.error);
      expect(state.erro, isNotNull);
    });
  });
}

class _ThrowingEventosRepository extends MockEventosRepository {
  @override
  Future<List<Evento>> listar(String bandaId) => Future.error(Exception('fail'));
}
