import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../contexto/presentation/notifiers/contexto_notifier.dart';
import '../notifiers/cadastro_notifier.dart';
import '../widgets/indicador_passos.dart';

class CadastroConvitesPage extends ConsumerStatefulWidget {
  const CadastroConvitesPage({super.key});

  static const routeName = '/cadastro/convites';

  @override
  ConsumerState<CadastroConvitesPage> createState() =>
      _CadastroConvitesPageState();
}

class _CadastroConvitesPageState extends ConsumerState<CadastroConvitesPage> {
  final _emailCtrl = TextEditingController();
  String? _erroEmail;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _convidar() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _erroEmail = 'E-mail inválido');
      return;
    }
    setState(() => _erroEmail = null);
    await ref.read(cadastroNotifierProvider.notifier).convidarPorEmail(email);
    _emailCtrl.clear();
  }

  void _copiarLink(String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copiado!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _concluir() {
    ref.read(contextoNotifierProvider.notifier).carregar();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cadastroNotifierProvider);
    final linkConvite = state.linkConvite;

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IndicadorPassos(total: 3, atual: 3),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, size: 18, color: AppColors.hintText),
                    SizedBox(width: 4),
                    Text('Voltar',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.hintText)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text('PASSO 3 DE 3',
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Text('Convide a galera',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'Mande o link ou busque por e-mail.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('campo_email_convite'),
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _convidar(),
                      style: const TextStyle(
                          color: AppColors.warmWhite, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'email do integrante',
                        prefixIcon: const Icon(Icons.search,
                            size: 18, color: AppColors.hintText),
                        errorText: _erroEmail,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    key: const Key('btn_convidar'),
                    onPressed: _convidar,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Convidar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (state.convites.isNotEmpty) ...[
                Text(
                  'CONVITES ENVIADOS',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.hintText,
                    letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(height: 8),
                ...state.convites.map((c) => _ConviteCard(email: c.email)),
                const SizedBox(height: 12),
              ],

              if (linkConvite != null)
                _LinkConviteCard(
                  link: linkConvite,
                  onCopiar: () => _copiarLink(linkConvite),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                key: const Key('btn_concluir'),
                onPressed: _concluir,
                child: const Text('Concluir cadastro'),
              ),
              const SizedBox(height: 12),

              Center(
                child: GestureDetector(
                  key: const Key('btn_convidar_depois'),
                  onTap: _concluir,
                  child: const Text(
                    'Convidar depois',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.hintText,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.hintText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConviteCard extends StatelessWidget {
  const _ConviteCard({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final iniciais = email.substring(0, 2).toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.curtainWine.withValues(alpha: 0.4),
              border: Border.all(
                  color: AppColors.curtainWine.withValues(alpha: 0.5)),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              iniciais,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.spotlight,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(email,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.warmWhite)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.confirmed.withValues(alpha: 0.2),
              border: Border.all(
                  color: AppColors.confirmed.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Convite enviado',
              style: TextStyle(fontSize: 10, color: Color(0xFF7FBFAA)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkConviteCard extends StatelessWidget {
  const _LinkConviteCard({required this.link, required this.onCopiar});
  final String link;
  final VoidCallback onCopiar;

  @override
  Widget build(BuildContext context) {
    final linkCurto =
        link.length > 32 ? '${link.substring(0, 32)}…' : link;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.spotlight.withValues(alpha: 0.06),
        border: Border.all(
            color: AppColors.spotlight.withValues(alpha: 0.25),
            style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.link,
              size: 18, color: AppColors.spotlight),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Link de convite da banda',
                  style: TextStyle(fontSize: 12, color: AppColors.hintText),
                ),
                Text(
                  linkCurto,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.spotlight),
                ),
              ],
            ),
          ),
          GestureDetector(
            key: const Key('btn_copiar_link'),
            onTap: onCopiar,
            child: const Icon(Icons.copy_outlined,
                size: 18, color: AppColors.hintText),
          ),
        ],
      ),
    );
  }
}
