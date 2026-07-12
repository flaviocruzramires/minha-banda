import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/vinculo_contexto.dart';
import '../notifiers/contexto_notifier.dart';

class SeletorContextoPage extends ConsumerWidget {
  const SeletorContextoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contextoNotifierProvider);
    final vinculos = state.vinculos;

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      appBar: AppBar(
        backgroundColor: AppColors.stageBlack2,
        automaticallyImplyLeading: false,
        title: const Text('Escolha seu perfil', style: TextStyle(color: AppColors.warmWhite)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'Você tem mais de um vínculo. Com qual deseja entrar?',
              style: TextStyle(color: AppColors.bodyText, fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: vinculos.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.line),
              itemBuilder: (_, i) {
                final v = vinculos[i];
                return _VinculoCard(
                  vinculo: v,
                  onTap: () {
                    ref.read(contextoNotifierProvider.notifier).selecionar(v);
                    context.go('/');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VinculoCard extends StatelessWidget {
  const _VinculoCard({required this.vinculo, required this.onTap});

  final VinculoContexto vinculo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = vinculo.isBanda ? Icons.music_note : Icons.location_on;
    final label = vinculo.isBanda ? 'Banda' : 'Local';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.stageBlack2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.spotlight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.spotlight, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vinculo.nome,
                      style: const TextStyle(color: AppColors.warmWhite, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('$label · ${vinculo.papel}',
                      style: const TextStyle(color: AppColors.bodyText, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.hintText, size: 16),
          ],
        ),
      ),
    );
  }
}
