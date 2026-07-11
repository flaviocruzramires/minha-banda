import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../notifiers/integrantes_notifier.dart';
import '../../domain/entities/integrante.dart';

class IntegrantesListaPage extends ConsumerStatefulWidget {
  const IntegrantesListaPage({super.key, required this.bandaId});
  final String bandaId;

  @override
  ConsumerState<IntegrantesListaPage> createState() => _IntegrantesListaPageState();
}

class _IntegrantesListaPageState extends ConsumerState<IntegrantesListaPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(integrantesNotifierProvider.notifier).carregar(widget.bandaId),
    );
  }

  String _displayName(Integrante i) => i.apelido ?? i.nomeArtistico ?? 'U';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(integrantesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      appBar: AppBar(
        backgroundColor: AppColors.stageBlack2,
        title: const Text('Integrantes', style: TextStyle(color: AppColors.warmWhite)),
        iconTheme: const IconThemeData(color: AppColors.warmWhite),
      ),
      body: state.isLoading
          ? const LoadingOverlay()
          : state.hasError
              ? Center(child: Text(state.erro ?? '', style: const TextStyle(color: AppColors.danger)))
              : state.integrantes.isEmpty
                  ? const EmptyState(icon: Icons.group, title: 'Nenhum integrante', subtitle: 'Sem membros na banda.')
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.integrantes.length,
                      separatorBuilder: (_, __) => const Divider(color: AppColors.line),
                      itemBuilder: (ctx, i) {
                        final integrante = state.integrantes[i];
                        final name = _displayName(integrante);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.spotlight,
                            child: Text(
                              name[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.stageBlack, fontWeight: FontWeight.w700),
                            ),
                          ),
                          title: Text(name, style: const TextStyle(color: AppColors.warmWhite)),
                          subtitle: Text(
                            '${integrante.instrumento ?? ''} · ${integrante.papel}',
                            style: const TextStyle(color: AppColors.bodyText),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.hintText),
                          onTap: () => context.push('/integrante-perfil', extra: integrante),
                        );
                      },
                    ),
    );
  }
}
