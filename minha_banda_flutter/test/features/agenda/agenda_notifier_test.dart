import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_banda_flutter/features/agenda/data/repositories/mock_agenda_repository.dart';
import 'package:minha_banda_flutter/features/agenda/presentation/notifiers/agenda_notifier.dart';
import 'package:minha_banda_flutter/features/eventos/domain/entities/evento.dart';

void main() {
  group('AgendaNotifier', () {
    test('loading -> success with mock', () async {
      final container = ProviderContainer(overrides: [
        agendaRepositoryProvider.overrideWithValue(MockAgendaRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(agendaNotifierProvider.notifier).carregar(userId: 'u1');
      final state = container.read(agendaNotifierProvider);

      expect(state.status, AgendaStatus.success);
    });

    test('loading -> error with throwing mock', () async {
      final container = ProviderContainer(overrides: [
        agendaRepositoryProvider.overrideWithValue(_ThrowingAgendaRepository()),
      ]);
      addTearDown(container.dispose);

      await container.read(agendaNotifierProvider.notifier).carregar(userId: 'u1');
      final state = container.read(agendaNotifierProvider);

      expect(state.status, AgendaStatus.error);
      expect(state.erro, isNotNull);
    });
  });
}

class _ThrowingAgendaRepository extends MockAgendaRepository {
  @override
  Future<List<Evento>> listarEventos() => Future.error(Exception('fail'));
}
