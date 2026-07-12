import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_token_provider.dart';
import '../../data/repositories/http_conflitos_repository.dart';
import '../../domain/entities/conflito.dart';
import '../../domain/repositories/conflitos_repository.dart';

enum ConflitosStatus { idle, verificando, limpo, comConflitos, erro }

class ConflitosState extends Equatable {
  const ConflitosState({
    this.status = ConflitosStatus.idle,
    this.conflitos = const [],
  });

  final ConflitosStatus status;
  final List<Conflito> conflitos;

  bool get isVerificando => status == ConflitosStatus.verificando;
  bool get temConflitos => conflitos.isNotEmpty;

  ConflitosState copyWith({ConflitosStatus? status, List<Conflito>? conflitos}) =>
      ConflitosState(
        status: status ?? this.status,
        conflitos: conflitos ?? this.conflitos,
      );

  @override
  List<Object?> get props => [status, conflitos];
}

final conflitosRepositoryProvider = Provider<ConflitosRepository>((ref) {
  final token = ref.watch(authTokenProvider) ?? '';
  return HttpConflitosRepository(token: token);
});

final conflitosNotifierProvider =
    StateNotifierProvider<ConflitosNotifier, ConflitosState>(
  (ref) => ConflitosNotifier(ref.watch(conflitosRepositoryProvider)),
);

class ConflitosNotifier extends StateNotifier<ConflitosState> {
  ConflitosNotifier(this._repo) : super(const ConflitosState());

  final ConflitosRepository _repo;

  Future<List<Conflito>> verificar({
    required String bandaId,
    required DateTime inicio,
    required DateTime fim,
  }) async {
    state = state.copyWith(status: ConflitosStatus.verificando, conflitos: []);
    try {
      final conflitos = await _repo.verificar(bandaId: bandaId, inicio: inicio, fim: fim);
      state = state.copyWith(
        status: conflitos.isEmpty ? ConflitosStatus.limpo : ConflitosStatus.comConflitos,
        conflitos: conflitos,
      );
      return conflitos;
    } catch (_) {
      state = state.copyWith(status: ConflitosStatus.erro, conflitos: []);
      return [];
    }
  }

  void limpar() => state = const ConflitosState();
}
