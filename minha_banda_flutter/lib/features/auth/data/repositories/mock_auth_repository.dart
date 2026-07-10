import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../bandas/domain/entities/banda.dart';

class MockAuthRepository implements AuthRepository {
  final Set<String> _emailsCadastrados = {};
  final Set<String> _nomesBanda = {};

  @override
  Future<AppUser> cadastrar({
    required String nomeArtistico,
    required String email,
    required String senha,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_emailsCadastrados.contains(email.toLowerCase())) {
      throw const EmailJaCadastradoException();
    }
    _emailsCadastrados.add(email.toLowerCase());
    return AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      nomeArtistico: nomeArtistico,
      email: email,
    );
  }

  @override
  Future<Banda> criarBanda({
    required String userId,
    required String nome,
    required String generoMusical,
    required String cidade,
    required int corHex,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_nomesBanda.contains(nome.toLowerCase())) {
      throw const NomeBandaEmUsoException();
    }
    _nomesBanda.add(nome.toLowerCase());
    return Banda(
      id: 'banda_${DateTime.now().millisecondsSinceEpoch}',
      nome: nome,
      generoMusical: generoMusical,
      cidade: cidade,
      cor: Color(corHex),
    );
  }

  @override
  Future<void> convidarPorEmail({
    required String bandaId,
    required String email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<String> gerarLinkConvite(String bandaId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'https://minha.banda/convite/$bandaId';
  }
}

class EmailJaCadastradoException implements Exception {
  const EmailJaCadastradoException();
  @override
  String toString() => 'E-mail já cadastrado.';
}

class NomeBandaEmUsoException implements Exception {
  const NomeBandaEmUsoException();
  @override
  String toString() => 'Esse nome de banda já está em uso.';
}
