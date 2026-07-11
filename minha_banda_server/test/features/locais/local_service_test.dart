import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:minha_banda_server/features/locais/data/repositories/local_repository.dart';
import 'package:minha_banda_server/features/locais/domain/entities/local.dart';
import 'package:minha_banda_server/features/locais/service/local_service.dart';
import 'package:minha_banda_server/core/exceptions/app_exception.dart';

class MockLocalRepository extends Mock implements LocalRepository {}

void main() {
  late MockLocalRepository repo;
  late LocalService service;

  setUp(() {
    repo = MockLocalRepository();
    service = LocalService(repo);
  });

  final localFixture = Local(
    id: 'local-1',
    nome: 'Palco Azul',
    cidade: 'São Paulo',
    tipo: 'bar',
    temSom: true,
    temCamarim: false,
    criadoPor: 'usr-1',
    criadoEm: DateTime(2024),
  );

  group('criar', () {
    test('criar local válido → sucesso + vira responsável DONO', () async {
      when(() => repo.create(
            nome: any(named: 'nome'),
            cidade: any(named: 'cidade'),
            criadoPor: any(named: 'criadoPor'),
            endereco: any(named: 'endereco'),
            tipo: any(named: 'tipo'),
            capacidade: any(named: 'capacidade'),
            contato: any(named: 'contato'),
            temSom: any(named: 'temSom'),
            temCamarim: any(named: 'temCamarim'),
            notas: any(named: 'notas'),
          )).thenAnswer((_) async => localFixture);
      when(() => repo.addResponsavel(
            localId: any(named: 'localId'),
            userId: any(named: 'userId'),
            papel: any(named: 'papel'),
          )).thenAnswer((_) async {});

      final result = await service.criar(
        nome: 'Palco Azul',
        cidade: 'São Paulo',
        criadoPor: 'usr-1',
      );

      expect(result.nome, 'Palco Azul');
      verify(() => repo.addResponsavel(
            localId: 'local-1',
            userId: 'usr-1',
            papel: 'DONO',
          )).called(1);
    });

    test('criar local com nome vazio → ValidationException', () {
      expect(
        () => service.criar(nome: '', cidade: 'SP', criadoPor: 'usr-1'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('buscarPorId', () {
    test('buscar por id inexistente → NotFoundException', () async {
      when(() => repo.findById(any())).thenAnswer((_) async => null);

      expect(
        () => service.buscarPorId('inexistente'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('listar', () {
    test('listar por cidade → retorna lista filtrada', () async {
      when(() => repo.listAll(cidade: 'São Paulo'))
          .thenAnswer((_) async => [localFixture]);

      final lista = await service.listar(cidade: 'São Paulo');

      expect(lista.length, 1);
      expect(lista.first.cidade, 'São Paulo');
    });
  });

  group('addResponsavel', () {
    test('addResponsavel duplicado → ConflictException propagada', () async {
      when(() => repo.addResponsavel(
            localId: any(named: 'localId'),
            userId: any(named: 'userId'),
            papel: any(named: 'papel'),
          )).thenThrow(const ConflictException('Responsável já cadastrado.'));

      expect(
        () => service.addResponsavel(localId: 'local-1', userId: 'usr-2'),
        throwsA(isA<ConflictException>()),
      );
    });
  });
}
