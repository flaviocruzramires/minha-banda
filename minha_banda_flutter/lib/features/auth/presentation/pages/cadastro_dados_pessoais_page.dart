import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../notifiers/cadastro_notifier.dart';
import '../widgets/campo_palco.dart';
import '../widgets/erro_inline.dart';
import '../widgets/indicador_passos.dart';
import 'cadastro_criar_banda_page.dart';

class CadastroDadosPessoaisPage extends ConsumerStatefulWidget {
  const CadastroDadosPessoaisPage({super.key});

  static const routeName = '/cadastro/dados';

  @override
  ConsumerState<CadastroDadosPessoaisPage> createState() =>
      _CadastroDadosPessoaisPageState();
}

class _CadastroDadosPessoaisPageState
    extends ConsumerState<CadastroDadosPessoaisPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _mostrarSenha = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(cadastroNotifierProvider.notifier).cadastrarUsuario(
          nomeArtistico: _nomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          senha: _senhaCtrl.text,
        );
    if (ok && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CadastroCriarBandaPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cadastroNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IndicadorPassos(total: 3, atual: 1),
                const SizedBox(height: 20),
                Text(
                  'PASSO 1 DE 3',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Crie sua conta',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Um login único para todas as suas bandas.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),

                if (state.hasError && state.erro != null) ...[
                  ErroInline(mensagem: state.erro!),
                  const SizedBox(height: 12),
                ],

                CampoPalco(
                  label: 'Nome artístico',
                  hint: 'Como você é conhecido',
                  prefixIcon: Icons.person_outline,
                  controller: _nomeCtrl,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 12),
                CampoPalco(
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  prefixIcon: Icons.mail_outline,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                    if (!v.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CampoPalco(
                  label: 'Senha',
                  hint: 'Crie uma senha segura',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_mostrarSenha,
                  controller: _senhaCtrl,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _continuar(),
                  suffixIcon: Icon(
                    _mostrarSenha
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.hintText,
                  ),
                  suffixKey: const Key('btn_toggle_senha'),
                  onSuffixTap: () =>
                      setState(() => _mostrarSenha = !_mostrarSenha),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha';
                    if (v.length < 8) return 'Mínimo 8 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  key: const Key('btn_continuar'),
                  onPressed: state.isLoading ? null : _continuar,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.stageBlack,
                          ),
                        )
                      : const Text('Continuar'),
                ),
                const SizedBox(height: 16),

                Row(children: [
                  const Expanded(child: Divider(color: AppColors.line)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'ou',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 11),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.line)),
                ]),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  key: const Key('btn_google'),
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata,
                      size: 20, color: AppColors.hintText),
                  label: const Text(
                    'Entrar com Google',
                    style: TextStyle(
                        color: AppColors.bodyText, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    side: const BorderSide(color: AppColors.inputBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                            fontSize: 12, color: AppColors.hintText),
                        children: [
                          TextSpan(text: 'Já tem conta? '),
                          TextSpan(
                            text: 'Entrar',
                            style: TextStyle(color: AppColors.spotlight),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
