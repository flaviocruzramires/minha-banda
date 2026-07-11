import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_token_provider.dart';
import '../../data/repositories/http_eventos_repository.dart';
import '../../domain/entities/checklist_item.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/evento_confirmacao.dart';
import '../../domain/repositories/eventos_repository.dart';

enum EventosStatus { idle, loading, success, error }

class EventosState extends Equatable {
  const EventosState({
    this.status = EventosStatus.idle,
    this.eventos = const [],
    this.eventoSelecionado,
    this.checklist = const [],
    this.confirmacoes = const [],
    this.erro,
  });

  final EventosStatus status;
  final List<Evento> eventos;
  final Evento? eventoSelecionado;
  final List<ChecklistItem> checklist;
  final List<EventoConfirmacao> confirmacoes;
  final String? erro;

  bool get isLoading => status == EventosStatus.loading;
  bool get hasError => status == EventosStatus.error;

  EventosState copyWith({
    EventosStatus? status,
    List<Evento>? eventos,
    Evento? eventoSelecionado,
    List<ChecklistItem>? checklist,
    List<EventoConfirmacao>? confirmacoes,
    String? erro,
  }) =>
      EventosState(
        status: status ?? this.status,
        eventos: eventos ?? this.eventos,
        eventoSelecionado: eventoSelecionado ?? this.eventoSelecionado,
        checklist: checklist ?? this.checklist,
        confirmacoes: confirmacoes ?? this.confirmacoes,
        erro: erro,
      );

  @override
  List<Object?> get props => [status, eventos, eventoSelecionado, checklist, confirmacoes, erro];
}

final eventosRepositoryProvider = Provider<EventosRepository>((ref) {
  final token = ref.watch(authTokenProvider) ?? '';
  return HttpEventosRepository(token: token);
});

final eventosNotifierProvider =
    StateNotifierProvider<EventosNotifier, EventosState>(
  (ref) => EventosNotifier(ref.watch(eventosRepositoryProvider)),
);

class EventosNotifier extends StateNotifier<EventosState> {
  EventosNotifier(this._repo) : super(const EventosState());

  final EventosRepository _repo;

  Future<void> carregar(String bandaId) async {
    state = state.copyWith(status: EventosStatus.loading);
    try {
      final eventos = await _repo.listar(bandaId);
      state = state.copyWith(status: EventosStatus.success, eventos: eventos);
    } catch (_) {
      state = state.copyWith(status: EventosStatus.error, erro: 'Erro ao carregar eventos.');
    }
  }

  void selecionarEvento(Evento evento) {
    state = state.copyWith(eventoSelecionado: evento);
  }

  Future<void> carregarDetalhes(String eventoId) async {
    state = state.copyWith(status: EventosStatus.loading);
    try {
      final checklist = await _repo.listarChecklist(eventoId);
      final confirmacoes = await _repo.listarConfirmacoes(eventoId);
      state = state.copyWith(
        status: EventosStatus.success,
        checklist: checklist,
        confirmacoes: confirmacoes,
      );
    } catch (_) {
      state = state.copyWith(status: EventosStatus.error, erro: 'Erro ao carregar detalhes.');
    }
  }

  Future<void> criar({
    required String bandaId,
    required String tipo,
    required String titulo,
    required DateTime dataHoraInicio,
    DateTime? dataHoraFim,
    String? localId,
    String status = 'agendado',
    String? notas,
  }) async {
    try {
      final novo = await _repo.criar(
        bandaId: bandaId, tipo: tipo, titulo: titulo,
        dataHoraInicio: dataHoraInicio, dataHoraFim: dataHoraFim,
        localId: localId, status: status, notas: notas,
      );
      state = state.copyWith(eventos: [...state.eventos, novo]);
    } catch (_) {
      state = state.copyWith(status: EventosStatus.error, erro: 'Erro ao criar evento.');
    }
  }

  Future<void> confirmarPresenca({required String eventoId, required String userId, required String confirmStatus}) async {
    try {
      final conf = await _repo.confirmarPresenca(eventoId: eventoId, userId: userId, status: confirmStatus);
      final updated = [...state.confirmacoes.where((c) => c.userId != userId), conf];
      state = state.copyWith(confirmacoes: updated);
    } catch (_) {
      state = state.copyWith(status: EventosStatus.error, erro: 'Erro ao confirmar presença.');
    }
  }

  Future<void> addChecklist({required String eventoId, required String descricao}) async {
    try {
      final item = await _repo.addChecklist(eventoId: eventoId, descricao: descricao);
      state = state.copyWith(checklist: [...state.checklist, item]);
    } catch (_) {
      state = state.copyWith(status: EventosStatus.error, erro: 'Erro ao adicionar checklist.');
    }
  }

  Future<void> toggleChecklist(ChecklistItem item) async {
    try {
      final updated = await _repo.toggleChecklist(item);
      state = state.copyWith(
        checklist: state.checklist.map((c) => c.id == updated.id ? updated : c).toList(),
      );
    } catch (_) {
      state = state.copyWith(status: EventosStatus.error, erro: 'Erro ao atualizar checklist.');
    }
  }
}
