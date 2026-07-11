import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:minha_banda_server/features/eventos/data/repositories/evento_repository.dart';
import 'package:minha_banda_server/features/eventos/domain/entities/evento.dart';
import 'package:minha_banda_server/features/eventos/service/evento_service.dart';
import 'package:minha_banda_server/core/exceptions/app_exception.dart';

class MockEventoRepository extends Mock implements EventoRepository {}

void main() {
  late MockEventoRepository repo;
  late EventoService service;

  setUp(() {
    repo = MockEventoRepository();
    service = EventoService(repo);
  });

  final now = DateTime(2025, 8, 1, 20, 0);
  final fim = DateTime(2025, 8, 1, 23, 0);

  final eventoFixture = Evento(
    id: 'evt-1',
    bandaId: 'banda-1',
    tipo: 'show',
    titulo: 'Show de Verão',
    dataHoraInicio: now,
    dataHoraFim: fim,
    status: 'proposto',
    criadoPor: 'user-1',
    criadoEm: now,
    atualizadoEm: now,
  );

  group('criar', () {
    test('evento válido → sucesso', () async {
      when(() => repo.create(
            bandaId: any(named: 'bandaId'),
            tipo: any(named: 'tipo'),
            titulo: any(named: 'titulo'),
            dataHoraInicio: any(named: 'dataHoraInicio'),
            dataHoraFim: any(named: 'dataHoraFim'),
            localId: any(named: 'localId'),
            criadoPor: any(named: 'criadoPor'),
          )).thenAnswer((_) async => eventoFixture);

      final resultado = await service.criar(
        bandaId: 'banda-1',
        tipo: 'show',
        titulo: 'Show de Verão',
        dataHoraInicio: now,
        dataHoraFim: fim,
        userId: 'user-1',
      );

      expect(resultado.titulo, 'Show de Verão');
      expect(resultado.tipo, 'show');
    });

    test('tipo inválido → ValidationException', () {
      expect(
        () => service.criar(
          bandaId: 'banda-1',
          tipo: 'festival',
          titulo: 'Show de Verão',
          dataHoraInicio: now,
          userId: 'user-1',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('título vazio → ValidationException', () {
      expect(
        () => service.criar(
          bandaId: 'banda-1',
          tipo: 'show',
          titulo: '',
          dataHoraInicio: now,
          userId: 'user-1',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('buscarPorId', () {
    test('id inexistente → NotFoundException', () async {
      when(() => repo.findById(any())).thenAnswer((_) async => null);

      expect(
        () => service.buscarPorId('nao-existe'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('id existente → retorna evento', () async {
      when(() => repo.findById('evt-1'))
          .thenAnswer((_) async => eventoFixture);

      final resultado = await service.buscarPorId('evt-1');
      expect(resultado.id, 'evt-1');
    });
  });

  group('confirmarPresenca', () {
    test('status inválido → ValidationException', () {
      when(() => repo.findById(any())).thenAnswer((_) async => eventoFixture);

      expect(
        () => service.confirmarPresenca(
          eventoId: 'evt-1',
          userId: 'user-1',
          status: 'talvez',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('status válido → sucesso', () async {
      when(() => repo.findById('evt-1'))
          .thenAnswer((_) async => eventoFixture);
      when(() => repo.upsertConfirmacao(
            eventoId: any(named: 'eventoId'),
            userId: any(named: 'userId'),
            status: any(named: 'status'),
          )).thenAnswer((_) async {});

      await expectLater(
        service.confirmarPresenca(
          eventoId: 'evt-1',
          userId: 'user-1',
          status: 'confirmado',
        ),
        completes,
      );

      verify(() => repo.upsertConfirmacao(
            eventoId: 'evt-1',
            userId: 'user-1',
            status: 'confirmado',
          )).called(1);
    });
  });
}
