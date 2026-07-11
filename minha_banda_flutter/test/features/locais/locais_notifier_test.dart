import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_banda_flutter/features/locais/data/repositories/mock_locais_repository.dart';
import 'package:minha_banda_flutter/features/locais/domain/entities/local.dart';
import 'package:minha_banda_flutter/features/locais/presentation/notifiers/locais_notifier.dart';

void main() {
  group('LocaisNotifier', () {
    test('loading -> success with mock', () async {
      final container = ProviderContainer(overrides: [
        locaisRepositoryProvider.overrideWithValue(MockLocaisRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(locaisNotifierProvider.notifier).carregar();
      final state = container.read(locaisNotifierProvider);

      expect(state.status, LocaisStatus.success);
      expect(state.locais, isNotEmpty);
    });

    test('loading -> error with throwing mock', () async {
      final container = ProviderContainer(overrides: [
        locaisRepositoryProvider.overrideWithValue(_ThrowingLocaisRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(locaisNotifierProvider.notifier).carregar();
      final state = container.read(locaisNotifierProvider);

      expect(state.status, LocaisStatus.error);
      expect(state.erro, isNotNull);
    });
  });
}

class _ThrowingLocaisRepository extends MockLocaisRepository {
  @override
  Future<List<Local>> listar() => Future.error(Exception('fail'));
}
