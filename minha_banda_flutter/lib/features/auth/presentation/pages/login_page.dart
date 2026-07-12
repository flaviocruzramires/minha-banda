import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../contexto/presentation/notifiers/contexto_notifier.dart';
import '../notifiers/login_notifier.dart';
import '../widgets/campo_palco.dart';
import '../widgets/erro_inline.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _mostrarSenha = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(loginNotifierProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          senha: _senhaCtrl.text,
        );
    if (ok && mounted) {
      ref.read(contextoNotifierProvider.notifier).carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Icon(Icons.music_note_rounded,
                    size: 72, color: AppColors.spotlight),
                const SizedBox(height: 16),
                Text(
                  'Minha Banda',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Acesse sua conta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 48),
                CampoPalco(
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                    if (!v.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CampoPalco(
                  label: 'Senha',
                  hint: 'Sua senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_mostrarSenha,
                  controller: _senhaCtrl,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _entrar(),
                  suffixIcon: Icon(
                    _mostrarSenha
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white54,
                  ),
                  onSuffixTap: () =>
                      setState(() => _mostrarSenha = !_mostrarSenha),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                if (state.hasError && state.erro != null)
                  ErroInline(mensagem: state.erro!),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('btn_entrar'),
                  onPressed: state.isLoading ? null : _entrar,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.spotlight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Entrar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Não tem conta?',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white54)),
                    TextButton(
                      onPressed: () => context.go('/cadastro'),
                      child: Text('Criar conta',
                          style: TextStyle(color: AppColors.spotlight)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
