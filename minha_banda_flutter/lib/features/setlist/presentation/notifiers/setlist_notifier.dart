import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_token_provider.dart';
import '../../../repertorio/data/repositories/http_repertorio_repository.dart';
import '../../../repertorio/domain/entities/musica.dart';
import '../../../repertorio/domain/repositories/repertorio_repository.dart';
import '../../data/repositories/http_setlist_repository.dart';
import '../../domain/entities/setlist_entry.dart';
import '../../domain/repositories/setlist_repository.dart';

enum SetlistStatus { idle, loading, saving, success, error }

class SetlistState extends Equatable {
  const SetlistState({
    this.status = SetlistStatus.idle,
    this.setlistIds = const [],
    this.repertorio = const [],
    this.erro,
  });

  final SetlistStatus status;
  final List<String> setlistIds;
  final List<Musica> repertorio;
  final String? erro;

  bool get isLoading => status == SetlistStatus.loading;
  bool get isSaving => status == SetlistStatus.saving;

  List<SetlistEntry> get setlist {
    final entries = <SetlistEntry>[];
    for (var i = 0; i < setlistIds.length; i++) {
      final id = setlistIds[i];
      final musica = repertorio.where((m) => m.id == id).firstOrNull;
      if (musica != null) {
        entries.add(SetlistEntry(
          musicaId: id,
          titulo: musica.titulo,
          artistaOriginal: musica.artistaOriginal,
          duracaoSeg: musica.duracaoSeg,
          posicao: i,
        ));
      }
    }
    return entries;
  }

  int get totalDuracaoSeg => setlist.fold(0, (acc, e) => acc + (e.duracaoSeg ?? 0));

  List<Musica> get musicasForaDoSetlist =>
      repertorio.where((m) => !setlistIds.contains(m.id)).toList();

  SetlistState copyWith({
    SetlistStatus? status,
    List<String>? setlistIds,
    List<Musica>? repertorio,
    String? erro,
  }) =>
      SetlistState(
        status: status ?? this.status,
        setlistIds: setlistIds ?? this.setlistIds,
        repertorio: repertorio ?? this.repertorio,
        erro: erro,
      );

  @override
  List<Object?> get props => [status, setlistIds, repertorio, erro];
}

final setlistRepositoryProvider = Provider.family<SetlistRepository, String>((ref, token) =>
    HttpSetlistRepository(token: token));

final repertorioForSetlistProvider = Provider.family<RepertorioRepository, String>((ref, token) =>
    HttpRepertorioRepository(token: token));

final setlistNotifierProvider =
    StateNotifierProvider<SetlistNotifier, SetlistState>(
  (ref) {
    final token = ref.watch(authTokenProvider) ?? '';
    return SetlistNotifier(
      ref.watch(setlistRepositoryProvider(token)),
      ref.watch(repertorioForSetlistProvider(token)),
    );
  },
);

class SetlistNotifier extends StateNotifier<SetlistState> {
  SetlistNotifier(this._setlistRepo, this._repertorioRepo) : super(const SetlistState());

  final SetlistRepository _setlistRepo;
  final RepertorioRepository _repertorioRepo;

  Future<void> carregar({required String eventoId, required String bandaId}) async {
    state = state.copyWith(status: SetlistStatus.loading);
    try {
      final results = await Future.wait([
        _setlistRepo.getSetlistIds(eventoId),
        _repertorioRepo.listar(bandaId),
      ]);
      state = state.copyWith(
        status: SetlistStatus.success,
        setlistIds: results[0] as List<String>,
        repertorio: results[1] as List<Musica>,
      );
    } catch (_) {
      state = state.copyWith(status: SetlistStatus.error, erro: 'Erro ao carregar setlist.');
    }
  }

  void reordenar(int oldIndex, int newIndex) {
    final ids = List<String>.from(state.setlistIds);
    if (newIndex > oldIndex) newIndex--;
    final id = ids.removeAt(oldIndex);
    ids.insert(newIndex, id);
    state = state.copyWith(setlistIds: ids);
  }

  void adicionar(String musicaId) {
    if (!state.setlistIds.contains(musicaId)) {
      state = state.copyWith(setlistIds: [...state.setlistIds, musicaId]);
    }
  }

  void remover(String musicaId) {
    state = state.copyWith(
      setlistIds: state.setlistIds.where((id) => id != musicaId).toList(),
    );
  }

  Future<bool> salvar(String eventoId) async {
    state = state.copyWith(status: SetlistStatus.saving);
    try {
      await _setlistRepo.setSetlist(eventoId: eventoId, musicaIds: state.setlistIds);
      state = state.copyWith(status: SetlistStatus.success);
      return true;
    } catch (_) {
      state = state.copyWith(status: SetlistStatus.error, erro: 'Erro ao salvar setlist.');
      return false;
    }
  }
}
