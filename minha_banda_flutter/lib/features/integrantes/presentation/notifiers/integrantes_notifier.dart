import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_token_provider.dart';
import '../../data/repositories/http_integrantes_repository.dart';
import '../../domain/entities/integrante.dart';
import '../../domain/repositories/integrantes_repository.dart';

enum IntegrantesStatus { idle, loading, success, error }

class IntegrantesState extends Equatable {
  const IntegrantesState({
    this.status = IntegrantesStatus.idle,
    this.integrantes = const [],
    this.integranteSelecionado,
    this.erro,
  });

  final IntegrantesStatus status;
  final List<Integrante> integrantes;
  final Integrante? integranteSelecionado;
  final String? erro;

  bool get isLoading => status == IntegrantesStatus.loading;
  bool get hasError => status == IntegrantesStatus.error;

  IntegrantesState copyWith({
    IntegrantesStatus? status,
    List<Integrante>? integrantes,
    Integrante? integranteSelecionado,
    String? erro,
  }) =>
      IntegrantesState(
        status: status ?? this.status,
        integrantes: integrantes ?? this.integrantes,
        integranteSelecionado: integranteSelecionado ?? this.integranteSelecionado,
        erro: erro,
      );

  @override
  List<Object?> get props => [status, integrantes, integranteSelecionado, erro];
}

final integrantesRepositoryProvider = Provider<IntegrantesRepository>((ref) {
  final token = ref.watch(authTokenProvider) ?? '';
  return HttpIntegrantesRepository(token: token);
});

final integrantesNotifierProvider =
    StateNotifierProvider<IntegrantesNotifier, IntegrantesState>(
  (ref) => IntegrantesNotifier(ref.watch(integrantesRepositoryProvider)),
);

class IntegrantesNotifier extends StateNotifier<IntegrantesState> {
  IntegrantesNotifier(this._repo) : super(const IntegrantesState());

  final IntegrantesRepository _repo;

  Future<void> carregar(String bandaId) async {
    state = state.copyWith(status: IntegrantesStatus.loading);
    try {
      final integrantes = await _repo.listar(bandaId);
      state = state.copyWith(status: IntegrantesStatus.success, integrantes: integrantes);
    } catch (_) {
      state = state.copyWith(status: IntegrantesStatus.error, erro: 'Erro ao carregar integrantes.');
    }
  }

  Future<void> atualizar(Integrante integrante) async {
    try {
      final atualizado = await _repo.atualizar(integrante);
      state = state.copyWith(
        integrantes: state.integrantes.map((i) => i.id == atualizado.id ? atualizado : i).toList(),
      );
    } catch (_) {
      state = state.copyWith(status: IntegrantesStatus.error, erro: 'Erro ao atualizar integrante.');
    }
  }

  Future<void> remover(String id) async {
    try {
      await _repo.remover(id);
      state = state.copyWith(integrantes: state.integrantes.where((i) => i.id != id).toList());
    } catch (_) {
      state = state.copyWith(status: IntegrantesStatus.error, erro: 'Erro ao remover integrante.');
    }
  }
}
