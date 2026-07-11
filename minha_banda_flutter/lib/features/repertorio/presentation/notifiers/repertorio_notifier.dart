import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_token_provider.dart';
import '../../data/repositories/http_repertorio_repository.dart';
import '../../domain/entities/musica.dart';
import '../../domain/repositories/repertorio_repository.dart';

enum RepertorioStatus { idle, loading, success, error }

class RepertorioState extends Equatable {
  const RepertorioState({
    this.status = RepertorioStatus.idle,
    this.musicas = const [],
    this.musicaSelecionada,
    this.erro,
  });

  final RepertorioStatus status;
  final List<Musica> musicas;
  final Musica? musicaSelecionada;
  final String? erro;

  bool get isLoading => status == RepertorioStatus.loading;
  bool get hasError => status == RepertorioStatus.error;

  RepertorioState copyWith({
    RepertorioStatus? status,
    List<Musica>? musicas,
    Musica? musicaSelecionada,
    String? erro,
  }) =>
      RepertorioState(
        status: status ?? this.status,
        musicas: musicas ?? this.musicas,
        musicaSelecionada: musicaSelecionada ?? this.musicaSelecionada,
        erro: erro,
      );

  @override
  List<Object?> get props => [status, musicas, musicaSelecionada, erro];
}

final repertorioRepositoryProvider = Provider<RepertorioRepository>((ref) {
  final token = ref.watch(authTokenProvider) ?? '';
  return HttpRepertorioRepository(token: token);
});

final repertorioNotifierProvider =
    StateNotifierProvider<RepertorioNotifier, RepertorioState>(
  (ref) => RepertorioNotifier(ref.watch(repertorioRepositoryProvider)),
);

class RepertorioNotifier extends StateNotifier<RepertorioState> {
  RepertorioNotifier(this._repo) : super(const RepertorioState());

  final RepertorioRepository _repo;

  Future<void> carregar(String bandaId) async {
    state = state.copyWith(status: RepertorioStatus.loading);
    try {
      final musicas = await _repo.listar(bandaId);
      state = state.copyWith(status: RepertorioStatus.success, musicas: musicas);
    } catch (_) {
      state = state.copyWith(
        status: RepertorioStatus.error,
        erro: 'Erro ao carregar repertório.',
      );
    }
  }

  Future<void> criar({
    required String bandaId,
    required String titulo,
    String? artistaOriginal,
    String? tonalidade,
    int? bpm,
    int? duracaoSeg,
    List<String> tags = const [],
    String? letra,
    String? cifra,
    String? linkReferencia,
    String? notasArranjo,
    required String status,
  }) async {
    try {
      final nova = await _repo.criar(
        bandaId: bandaId,
        titulo: titulo,
        artistaOriginal: artistaOriginal,
        tonalidade: tonalidade,
        bpm: bpm,
        duracaoSeg: duracaoSeg,
        tags: tags,
        letra: letra,
        cifra: cifra,
        linkReferencia: linkReferencia,
        notasArranjo: notasArranjo,
        status: status,
      );
      state = state.copyWith(musicas: [...state.musicas, nova]);
    } catch (_) {
      state = state.copyWith(
        status: RepertorioStatus.error,
        erro: 'Erro ao criar música.',
      );
    }
  }

  Future<void> atualizar(Musica musica) async {
    try {
      final atualizada = await _repo.atualizar(musica);
      state = state.copyWith(
        musicas: state.musicas.map((m) => m.id == atualizada.id ? atualizada : m).toList(),
      );
    } catch (_) {
      state = state.copyWith(
        status: RepertorioStatus.error,
        erro: 'Erro ao atualizar música.',
      );
    }
  }

  Future<void> deletar(String id) async {
    try {
      await _repo.deletar(id);
      state = state.copyWith(
        musicas: state.musicas.where((m) => m.id != id).toList(),
      );
    } catch (_) {
      state = state.copyWith(
        status: RepertorioStatus.error,
        erro: 'Erro ao deletar música.',
      );
    }
  }
}
