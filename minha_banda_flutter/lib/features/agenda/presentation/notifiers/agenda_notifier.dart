import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_token_provider.dart';
import '../../../eventos/domain/entities/evento.dart';
import '../../data/repositories/http_agenda_repository.dart';
import '../../domain/entities/bloqueio.dart';
import '../../domain/repositories/agenda_repository.dart';

enum AgendaStatus { idle, loading, success, error }

class AgendaState extends Equatable {
  const AgendaState({
    this.status = AgendaStatus.idle,
    this.eventos = const [],
    this.bloqueios = const [],
    this.erro,
  });

  final AgendaStatus status;
  final List<Evento> eventos;
  final List<Bloqueio> bloqueios;
  final String? erro;

  bool get isLoading => status == AgendaStatus.loading;
  bool get hasError => status == AgendaStatus.error;

  AgendaState copyWith({
    AgendaStatus? status,
    List<Evento>? eventos,
    List<Bloqueio>? bloqueios,
    String? erro,
  }) =>
      AgendaState(
        status: status ?? this.status,
        eventos: eventos ?? this.eventos,
        bloqueios: bloqueios ?? this.bloqueios,
        erro: erro,
      );

  @override
  List<Object?> get props => [status, eventos, bloqueios, erro];
}

final agendaRepositoryProvider = Provider<AgendaRepository>((ref) {
  final token = ref.watch(authTokenProvider) ?? '';
  return HttpAgendaRepository(token: token);
});

final agendaNotifierProvider =
    StateNotifierProvider<AgendaNotifier, AgendaState>(
  (ref) => AgendaNotifier(ref.watch(agendaRepositoryProvider)),
);

class AgendaNotifier extends StateNotifier<AgendaState> {
  AgendaNotifier(this._repo) : super(const AgendaState());

  final AgendaRepository _repo;

  Future<void> carregar({String userId = ''}) async {
    state = state.copyWith(status: AgendaStatus.loading);
    try {
      final eventos = await _repo.listarEventos();
      final bloqueios = await _repo.listarBloqueios(userId);
      state = state.copyWith(status: AgendaStatus.success, eventos: eventos, bloqueios: bloqueios);
    } catch (_) {
      state = state.copyWith(status: AgendaStatus.error, erro: 'Erro ao carregar agenda.');
    }
  }

  Future<void> adicionarBloqueio({
    required String userId,
    required String titulo,
    required DateTime dataHoraInicio,
    required DateTime dataHoraFim,
  }) async {
    try {
      final b = await _repo.adicionarBloqueio(
        userId: userId, titulo: titulo,
        dataHoraInicio: dataHoraInicio, dataHoraFim: dataHoraFim,
      );
      state = state.copyWith(bloqueios: [...state.bloqueios, b]);
    } catch (_) {
      state = state.copyWith(status: AgendaStatus.error, erro: 'Erro ao adicionar bloqueio.');
    }
  }

  Future<void> removerBloqueio(String id) async {
    try {
      await _repo.removerBloqueio(id);
      state = state.copyWith(bloqueios: state.bloqueios.where((b) => b.id != id).toList());
    } catch (_) {
      state = state.copyWith(status: AgendaStatus.error, erro: 'Erro ao remover bloqueio.');
    }
  }
}
