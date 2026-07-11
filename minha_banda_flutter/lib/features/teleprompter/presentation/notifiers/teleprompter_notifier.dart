import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_token_provider.dart';
import '../../data/repositories/http_teleprompter_repository.dart';
import '../../domain/entities/musica_teleprompter.dart';
import '../../domain/repositories/teleprompter_repository.dart';

enum TeleprompterStatus { idle, loading, success, error }

class TeleprompterState extends Equatable {
  const TeleprompterState({
    this.status = TeleprompterStatus.idle,
    this.musicas = const [],
    this.indiceSelecionado = 0,
    this.velocidade = 1.0,
    this.rolando = false,
    this.erro,
  });

  final TeleprompterStatus status;
  final List<MusicaTeleprompter> musicas;
  final int indiceSelecionado;
  final double velocidade;
  final bool rolando;
  final String? erro;

  bool get isLoading => status == TeleprompterStatus.loading;
  bool get hasError => status == TeleprompterStatus.error;

  TeleprompterState copyWith({
    TeleprompterStatus? status,
    List<MusicaTeleprompter>? musicas,
    int? indiceSelecionado,
    double? velocidade,
    bool? rolando,
    String? erro,
  }) =>
      TeleprompterState(
        status: status ?? this.status,
        musicas: musicas ?? this.musicas,
        indiceSelecionado: indiceSelecionado ?? this.indiceSelecionado,
        velocidade: velocidade ?? this.velocidade,
        rolando: rolando ?? this.rolando,
        erro: erro,
      );

  @override
  List<Object?> get props => [status, musicas, indiceSelecionado, velocidade, rolando, erro];
}

final teleprompterRepositoryProvider = Provider<TeleprompterRepository>((ref) {
  final token = ref.watch(authTokenProvider) ?? '';
  return HttpTeleprompterRepository(token: token);
});

final teleprompterNotifierProvider =
    StateNotifierProvider<TeleprompterNotifier, TeleprompterState>(
  (ref) => TeleprompterNotifier(ref.watch(teleprompterRepositoryProvider)),
);

class TeleprompterNotifier extends StateNotifier<TeleprompterState> {
  TeleprompterNotifier(this._repo) : super(const TeleprompterState());

  final TeleprompterRepository _repo;

  Future<void> carregar(String eventoId) async {
    state = state.copyWith(status: TeleprompterStatus.loading);
    try {
      final musicas = await _repo.getEventoComLetra(eventoId);
      state = state.copyWith(status: TeleprompterStatus.success, musicas: musicas);
    } catch (_) {
      state = state.copyWith(status: TeleprompterStatus.error, erro: 'Erro ao carregar teleprompter.');
    }
  }

  void selecionarMusica(int index) {
    if (index >= 0 && index < state.musicas.length) {
      state = state.copyWith(indiceSelecionado: index, rolando: false);
    }
  }

  void toggleRolar() {
    state = state.copyWith(rolando: !state.rolando);
  }

  void setVelocidade(double v) {
    state = state.copyWith(velocidade: v);
  }
}
