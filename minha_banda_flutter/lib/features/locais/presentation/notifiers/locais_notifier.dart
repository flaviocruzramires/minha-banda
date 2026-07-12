import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_token_provider.dart';
import '../../data/repositories/http_locais_repository.dart';
import '../../domain/entities/local.dart';
import '../../domain/repositories/locais_repository.dart';

enum LocaisStatus { idle, loading, success, error }

class LocaisState extends Equatable {
  const LocaisState({
    this.status = LocaisStatus.idle,
    this.locais = const [],
    this.erro,
  });

  final LocaisStatus status;
  final List<Local> locais;
  final String? erro;

  bool get isLoading => status == LocaisStatus.loading;
  bool get hasError => status == LocaisStatus.error;

  LocaisState copyWith({LocaisStatus? status, List<Local>? locais, String? erro}) =>
      LocaisState(status: status ?? this.status, locais: locais ?? this.locais, erro: erro);

  @override
  List<Object?> get props => [status, locais, erro];
}

final locaisRepositoryProvider = Provider<LocaisRepository>((ref) {
  final token = ref.watch(authTokenProvider) ?? '';
  return HttpLocaisRepository(token: token);
});

final locaisNotifierProvider = StateNotifierProvider<LocaisNotifier, LocaisState>(
  (ref) => LocaisNotifier(ref.watch(locaisRepositoryProvider)),
);

class LocaisNotifier extends StateNotifier<LocaisState> {
  LocaisNotifier(this._repo) : super(const LocaisState());

  final LocaisRepository _repo;

  Future<void> carregar() async {
    state = state.copyWith(status: LocaisStatus.loading);
    try {
      final locais = await _repo.listar();
      state = state.copyWith(status: LocaisStatus.success, locais: locais);
    } catch (e) {
      state = state.copyWith(status: LocaisStatus.error, erro: e.toString());
    }
  }

  Future<void> criar({
    required String nome, required String cidade, required String tipo,
    int? capacidade, String? contato, bool temSom = false, bool temCamarim = false, String? notas,
  }) async {
    try {
      final novo = await _repo.criar(
        nome: nome, cidade: cidade, tipo: tipo,
        capacidade: capacidade, contato: contato,
        temSom: temSom, temCamarim: temCamarim, notas: notas,
      );
      state = state.copyWith(locais: [...state.locais, novo]);
    } catch (_) {
      state = state.copyWith(status: LocaisStatus.error, erro: 'Erro ao criar local.');
    }
  }

  Future<void> atualizar(Local local) async {
    try {
      final updated = await _repo.atualizar(local);
      state = state.copyWith(
        locais: state.locais.map((l) => l.id == updated.id ? updated : l).toList(),
      );
    } catch (_) {
      state = state.copyWith(status: LocaisStatus.error, erro: 'Erro ao atualizar local.');
    }
  }

  Future<void> deletar(String id) async {
    try {
      await _repo.deletar(id);
      state = state.copyWith(locais: state.locais.where((l) => l.id != id).toList());
    } catch (_) {
      state = state.copyWith(status: LocaisStatus.error, erro: 'Erro ao deletar local.');
    }
  }
}
