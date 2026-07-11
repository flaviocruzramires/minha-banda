import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:minha_banda_server/features/repertorio/data/repositories/musica_repository.dart';
import 'package:minha_banda_server/features/repertorio/domain/entities/musica.dart';
import 'package:minha_banda_server/features/repertorio/domain/entities/setlist_item.dart';
import 'package:minha_banda_server/features/repertorio/service/musica_service.dart';
import 'package:minha_banda_server/core/exceptions/app_exception.dart';

class MockMusicaRepository extends Mock implements MusicaRepository {}

void main() {
  late MockMusicaRepository repo;
  late MusicaService service;

  setUp(() {
    repo = MockMusicaRepository();
    service = MusicaService(repo);
  });

  final now = DateTime(2024);

  final musicaFixture = Musica(
    id: 'musica-1',
    bandaId: 'banda-1',
    titulo: 'Bohemian Rhapsody',
    tags: const [],
    status: 'em_aprendizado',
    criadoPor: 'usr-1',
    criadoEm: now,
    atualizadoEm: now,
  );

  group('criar', () {
    test('título válido → cria música com sucesso', () async {
      when(() => repo.create(
            bandaId: any(named: 'bandaId'),
            titulo: any(named: 'titulo'),
            criadoPor: any(named: 'criadoPor'),
            artistaOriginal: any(named: 'artistaOriginal'),
            tonalidade: any(named: 'tonalidade'),
            bpm: any(named: 'bpm'),
            duracaoSeg: any(named: 'duracaoSeg'),
            tags: any(named: 'tags'),
            letra: any(named: 'letra'),
            cifra: any(named: 'cifra'),
            linkReferencia: any(named: 'linkReferencia'),
            notasArranjo: any(named: 'notasArranjo'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => musicaFixture);

      final result = await service.criar(
        bandaId: 'banda-1',
        titulo: 'Bohemian Rhapsody',
        userId: 'usr-1',
      );

      expect(result.titulo, 'Bohemian Rhapsody');
      expect(result.bandaId, 'banda-1');
    });

    test('título vazio → ValidationException', () {
      expect(
        () => service.criar(
          bandaId: 'banda-1',
          titulo: '',
          userId: 'usr-1',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('título só espaços → ValidationException', () {
      expect(
        () => service.criar(
          bandaId: 'banda-1',
          titulo: '   ',
          userId: 'usr-1',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('buscarPorId', () {
    test('id existente → retorna música', () async {
      when(() => repo.findById('musica-1')).thenAnswer((_) async => musicaFixture);

      final result = await service.buscarPorId('musica-1');
      expect(result.id, 'musica-1');
    });

    test('id inexistente → NotFoundException', () async {
      when(() => repo.findById(any())).thenAnswer((_) async => null);

      expect(
        () => service.buscarPorId('nao-existe'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('deletar', () {
    test('música existente → deleta com sucesso', () async {
      when(() => repo.findById('musica-1')).thenAnswer((_) async => musicaFixture);
      when(() => repo.delete('musica-1')).thenAnswer((_) async {});

      await service.deletar(id: 'musica-1', userId: 'usr-1');

      verify(() => repo.delete('musica-1')).called(1);
    });

    test('música inexistente → NotFoundException antes de deletar', () async {
      when(() => repo.findById(any())).thenAnswer((_) async => null);

      expect(
        () => service.deletar(id: 'nao-existe', userId: 'usr-1'),
        throwsA(isA<NotFoundException>()),
      );
      verifyNever(() => repo.delete(any()));
    });
  });

  group('getSetlist', () {
    test('retorna lista ordenada por posição', () async {
      final itens = [
        SetlistItem(id: 'si-1', eventoId: 'evt-1', musicaId: 'musica-1', posicao: 0),
        SetlistItem(id: 'si-2', eventoId: 'evt-1', musicaId: 'musica-2', posicao: 1),
      ];
      when(() => repo.getSetlist('evt-1')).thenAnswer((_) async => itens);

      final result = await service.getSetlist('evt-1');

      expect(result.length, 2);
      expect(result.first.posicao, 0);
      expect(result.last.posicao, 1);
    });
  });

  group('setSetlist', () {
    test('chama repository com eventoId e musicaIds corretos', () async {
      when(() => repo.setSetlist(
            eventoId: any(named: 'eventoId'),
            musicaIds: any(named: 'musicaIds'),
          )).thenAnswer((_) async {});

      await service.setSetlist(
        eventoId: 'evt-1',
        musicaIds: ['musica-1', 'musica-2'],
        userId: 'usr-1',
      );

      verify(() => repo.setSetlist(
            eventoId: 'evt-1',
            musicaIds: ['musica-1', 'musica-2'],
          )).called(1);
    });
  });
}
