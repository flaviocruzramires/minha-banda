import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_banda_flutter/features/repertorio/domain/entities/musica.dart';
import 'package:minha_banda_flutter/features/repertorio/domain/repositories/repertorio_repository.dart';
import 'package:minha_banda_flutter/features/repertorio/presentation/notifiers/repertorio_notifier.dart';
import 'package:minha_banda_flutter/features/repertorio/data/repositories/mock_repertorio_repository.dart';

void main() {
  group('RepertorioNotifier', () {
    test('loading -> success with mock', () async {
      final container = ProviderContainer(overrides: [
        repertorioRepositoryProvider.overrideWithValue(MockRepertorioRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(repertorioNotifierProvider.notifier).carregar('banda-1');
      final state = container.read(repertorioNotifierProvider);

      expect(state.status, RepertorioStatus.success);
      expect(state.musicas, isNotEmpty);
    });

    test('loading -> error with throwing mock', () async {
      final container = ProviderContainer(overrides: [
        repertorioRepositoryProvider.overrideWithValue(_ThrowingRepertorioRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(repertorioNotifierProvider.notifier).carregar('banda-1');
      final state = container.read(repertorioNotifierProvider);

      expect(state.status, RepertorioStatus.error);
      expect(state.erro, isNotNull);
    });
  });
}

class _ThrowingRepertorioRepository implements RepertorioRepository {
  @override
  Future<List<Musica>> listar(String bandaId) => Future.error(Exception('fail'));

  @override
  Future<Musica> criar({
    required String bandaId, required String titulo,
    String? artistaOriginal, String? tonalidade, int? bpm, int? duracaoSeg,
    List<String> tags = const [], String? letra, String? cifra,
    String? linkReferencia, String? notasArranjo, required String status,
  }) => Future.error(Exception('fail'));

  @override
  Future<Musica> atualizar(Musica musica) => Future.error(Exception('fail'));

  @override
  Future<void> deletar(String id) => Future.error(Exception('fail'));
}
