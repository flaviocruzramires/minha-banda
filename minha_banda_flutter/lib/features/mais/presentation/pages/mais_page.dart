import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../contexto/presentation/notifiers/contexto_notifier.dart';
import '../../../../core/providers/auth_token_provider.dart';

class MaisPage extends ConsumerWidget {
  const MaisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contexto = ref.watch(contextoNotifierProvider);
    final bandaId = contexto.ativo?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const SizedBox(height: 8),
            _MaisSection(
              title: 'Banda',
              items: [
                _MaisItem(
                  icon: Icons.library_music,
                  label: 'Repertório',
                  onTap: bandaId.isEmpty ? null : () => context.go('/repertorio/$bandaId'),
                ),
                _MaisItem(
                  icon: Icons.group,
                  label: 'Integrantes',
                  onTap: bandaId.isEmpty ? null : () => context.go('/integrantes/$bandaId'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _MaisSection(
              title: 'Locais',
              items: [
                _MaisItem(
                  icon: Icons.place,
                  label: 'Meus locais',
                  onTap: () => context.go('/locais'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _MaisSection(
              title: 'Conta',
              items: [
                if ((contexto.vinculos.length) > 1)
                  _MaisItem(
                    icon: Icons.swap_horiz,
                    label: 'Trocar banda',
                    iconColor: AppColors.spotlight,
                    onTap: () async {
                      ref.read(contextoNotifierProvider.notifier).limpar();
                      await ref.read(contextoNotifierProvider.notifier).carregar();
                      if (context.mounted) context.go('/seletor-contexto');
                    },
                  ),
                _MaisItem(
                  icon: Icons.logout,
                  label: 'Sair',
                  labelColor: AppColors.danger,
                  iconColor: AppColors.danger,
                  onTap: () async {
                    await ref.read(authTokenProvider.notifier).clearToken();
                    ref.read(contextoNotifierProvider.notifier).limpar();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MaisSection extends StatelessWidget {
  const _MaisSection({required this.title, required this.items});
  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.10,
            color: Color(0x66F7F3EC),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.stageBlack2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _MaisItem extends StatelessWidget {
  const _MaisItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.labelColor,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.warmWhite, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor ?? AppColors.warmWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.hintText, size: 20),
          ],
        ),
      ),
    );
  }
}
