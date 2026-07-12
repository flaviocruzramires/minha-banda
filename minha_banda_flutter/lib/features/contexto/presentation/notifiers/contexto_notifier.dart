import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_token_provider.dart';
import '../../data/repositories/http_contexto_repository.dart';
import '../../domain/entities/vinculo_contexto.dart';

class ContextoState extends Equatable {
  const ContextoState({
    this.vinculos = const [],
    this.ativo,
    this.carregado = false,
  });

  final List<VinculoContexto> vinculos;
  final VinculoContexto? ativo;
  final bool carregado;

  bool get precisaSeletor => carregado && vinculos.length > 1 && ativo == null;
  bool get temBandaAtiva => ativo?.isBanda ?? false;

  ContextoState copyWith({
    List<VinculoContexto>? vinculos,
    VinculoContexto? ativo,
    bool? carregado,
  }) =>
      ContextoState(
        vinculos: vinculos ?? this.vinculos,
        ativo: ativo ?? this.ativo,
        carregado: carregado ?? this.carregado,
      );

  ContextoState clearAtivo() => ContextoState(vinculos: vinculos, carregado: carregado);

  @override
  List<Object?> get props => [vinculos, ativo, carregado];
}

final contextoNotifierProvider =
    StateNotifierProvider<ContextoNotifier, ContextoState>(
  (ref) {
    final token = ref.watch(authTokenProvider);
    return ContextoNotifier(token != null ? HttpContextoRepository(token: token) : null);
  },
);

class ContextoNotifier extends StateNotifier<ContextoState> {
  ContextoNotifier(this._repo) : super(const ContextoState());

  final HttpContextoRepository? _repo;

  Future<void> carregar() async {
    if (_repo == null) return;
    try {
      final vinculos = await _repo.getMeuContexto();
      if (vinculos.length == 1) {
        state = state.copyWith(vinculos: vinculos, ativo: vinculos.first, carregado: true);
      } else {
        state = state.copyWith(vinculos: vinculos, carregado: true);
      }
    } catch (_) {
      state = state.copyWith(carregado: true);
    }
  }

  void selecionar(VinculoContexto vinculo) {
    state = state.copyWith(ativo: vinculo);
  }

  void limpar() {
    state = const ContextoState();
  }
}
