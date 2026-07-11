import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_banda_flutter/features/integrantes/data/repositories/mock_integrantes_repository.dart';
import 'package:minha_banda_flutter/features/integrantes/domain/entities/integrante.dart';
import 'package:minha_banda_flutter/features/integrantes/presentation/notifiers/integrantes_notifier.dart';

void main() {
  group('IntegrantesNotifier', () {
    test('loading -> success with mock', () async {
      final container = ProviderContainer(overrides: [
        integrantesRepositoryProvider.overrideWithValue(MockIntegrantesRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(integrantesNotifierProvider.notifier).carregar('banda-1');
      final state = container.read(integrantesNotifierProvider);

      expect(state.status, IntegrantesStatus.success);
      expect(state.integrantes, isNotEmpty);
    });

    test('loading -> error with throwing mock', () async {
      final container = ProviderContainer(overrides: [
        integrantesRepositoryProvider.overrideWithValue(_ThrowingIntegrantesRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(integrantesNotifierProvider.notifier).carregar('banda-1');
      final state = container.read(integrantesNotifierProvider);

      expect(state.status, IntegrantesStatus.error);
      expect(state.erro, isNotNull);
    });
  });
}

class _ThrowingIntegrantesRepository extends MockIntegrantesRepository {
  @override
  Future<List<Integrante>> listar(String bandaId) => Future.error(Exception('fail'));
}
