import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_token_provider.dart';
import '../../data/repositories/http_auth_repository.dart'
    show HttpRepositoryException;
import '../../data/repositories/mock_auth_repository.dart'
    show CredenciaisInvalidasException;
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'cadastro_notifier.dart' show authRepositoryProvider;

// ---------------------------------------------------------------------------
// Estado
// ---------------------------------------------------------------------------

enum LoginStatus { idle, loading, success, error }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.idle,
    this.usuario,
    this.erro,
  });

  final LoginStatus status;
  final AppUser? usuario;
  final String? erro;

  bool get isLoading => status == LoginStatus.loading;
  bool get hasError => status == LoginStatus.error;

  LoginState copyWith({
    LoginStatus? status,
    AppUser? usuario,
    String? erro,
  }) =>
      LoginState(
        status: status ?? this.status,
        usuario: usuario ?? this.usuario,
        erro: erro,
      );

  @override
  List<Object?> get props => [status, usuario, erro];
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final loginNotifierProvider =
    StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(ref.watch(authRepositoryProvider), ref),
);

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(this._repo, this._ref) : super(const LoginState());

  final AuthRepository _repo;
  final Ref _ref;

  Future<bool> login({
    required String email,
    required String senha,
  }) async {
    state = state.copyWith(status: LoginStatus.loading, erro: null);
    try {
      final result = await _repo.login(email: email, senha: senha);
      await _ref.read(authTokenProvider.notifier).setToken(result.token);
      state = state.copyWith(
          status: LoginStatus.success, usuario: result.user);
      return true;
    } on CredenciaisInvalidasException {
      state = state.copyWith(
        status: LoginStatus.error,
        erro: 'E-mail ou senha incorretos.',
      );
      return false;
    } on HttpRepositoryException catch (e) {
      state = state.copyWith(
        status: LoginStatus.error,
        erro: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: LoginStatus.error,
        erro: 'Sem conexão com o servidor. Verifique sua rede.',
      );
      return false;
    }
  }
}
