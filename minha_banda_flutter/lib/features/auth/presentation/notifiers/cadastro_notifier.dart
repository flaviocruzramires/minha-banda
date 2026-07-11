import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/http_auth_repository.dart';
import '../../data/repositories/mock_auth_repository.dart'
    show EmailJaCadastradoException, NomeBandaEmUsoException;
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../bandas/domain/entities/banda.dart';

// ---------------------------------------------------------------------------
// Estado
// ---------------------------------------------------------------------------

enum CadastroStatus { idle, loading, success, error }

class ConviteEnviado extends Equatable {
  const ConviteEnviado({required this.email});
  final String email;
  @override
  List<Object?> get props => [email];
}

class CadastroState extends Equatable {
  const CadastroState({
    this.status = CadastroStatus.idle,
    this.usuario,
    this.banda,
    this.convites = const [],
    this.linkConvite,
    this.erro,
  });

  final CadastroStatus status;
  final AppUser? usuario;
  final Banda? banda;
  final List<ConviteEnviado> convites;
  final String? linkConvite;
  final String? erro;

  bool get isLoading => status == CadastroStatus.loading;
  bool get hasError => status == CadastroStatus.error;

  CadastroState copyWith({
    CadastroStatus? status,
    AppUser? usuario,
    Banda? banda,
    List<ConviteEnviado>? convites,
    String? linkConvite,
    String? erro,
  }) {
    return CadastroState(
      status: status ?? this.status,
      usuario: usuario ?? this.usuario,
      banda: banda ?? this.banda,
      convites: convites ?? this.convites,
      linkConvite: linkConvite ?? this.linkConvite,
      erro: erro,
    );
  }

  @override
  List<Object?> get props =>
      [status, usuario, banda, convites, linkConvite, erro];
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => HttpAuthRepository(),
);

final cadastroNotifierProvider =
    StateNotifierProvider<CadastroNotifier, CadastroState>(
  (ref) => CadastroNotifier(ref.watch(authRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class CadastroNotifier extends StateNotifier<CadastroState> {
  CadastroNotifier(this._repo) : super(const CadastroState());

  final AuthRepository _repo;

  Future<bool> cadastrarUsuario({
    required String nomeArtistico,
    required String email,
    required String senha,
  }) async {
    state = state.copyWith(status: CadastroStatus.loading);
    try {
      final user = await _repo.cadastrar(
        nomeArtistico: nomeArtistico,
        email: email,
        senha: senha,
      );
      state = state.copyWith(status: CadastroStatus.success, usuario: user);
      return true;
    } on EmailJaCadastradoException {
      state = state.copyWith(
        status: CadastroStatus.error,
        erro: 'Este e-mail já está cadastrado.',
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CadastroStatus.error,
        erro: 'Erro ao criar conta. Tente novamente.',
      );
      return false;
    }
  }

  Future<bool> criarBanda({
    required String nome,
    required String generoMusical,
    required String cidade,
    required Color cor,
  }) async {
    final userId = state.usuario?.id;
    if (userId == null) return false;

    state = state.copyWith(status: CadastroStatus.loading);
    try {
      final banda = await _repo.criarBanda(
        userId: userId,
        nome: nome,
        generoMusical: generoMusical,
        cidade: cidade,
        corHex: cor.toARGB32(),
      );
      final link = await _repo.gerarLinkConvite(banda.id);
      state = state.copyWith(
        status: CadastroStatus.success,
        banda: banda,
        linkConvite: link,
      );
      return true;
    } on NomeBandaEmUsoException {
      state = state.copyWith(
        status: CadastroStatus.error,
        erro: 'Esse nome de banda já está em uso.',
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CadastroStatus.error,
        erro: 'Erro ao criar banda. Tente novamente.',
      );
      return false;
    }
  }

  void pularCriacaoBanda() {
    state = state.copyWith(status: CadastroStatus.idle);
  }

  Future<void> convidarPorEmail(String email) async {
    final bandaId = state.banda?.id;
    if (bandaId == null) return;
    await _repo.convidarPorEmail(bandaId: bandaId, email: email);
    state = state.copyWith(
      convites: [...state.convites, ConviteEnviado(email: email)],
    );
  }
}
