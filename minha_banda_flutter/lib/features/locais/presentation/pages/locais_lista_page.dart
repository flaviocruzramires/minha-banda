import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../notifiers/locais_notifier.dart';

class LocaisListaPage extends ConsumerStatefulWidget {
  const LocaisListaPage({super.key});

  @override
  ConsumerState<LocaisListaPage> createState() => _LocaisListaPageState();
}

class _LocaisListaPageState extends ConsumerState<LocaisListaPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(locaisNotifierProvider.notifier).carregar());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locaisNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      appBar: AppBar(
        backgroundColor: AppColors.stageBlack2,
        title: const Text('Locais', style: TextStyle(color: AppColors.warmWhite)),
        iconTheme: const IconThemeData(color: AppColors.warmWhite),
      ),
      body: state.isLoading
          ? const LoadingOverlay()
          : state.hasError
              ? Center(child: Text(state.erro ?? '', style: const TextStyle(color: AppColors.danger)))
              : state.locais.isEmpty
                  ? const EmptyState(icon: Icons.place, title: 'Nenhum local', subtitle: 'Adicione locais de apresentação.')
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.locais.length,
                      separatorBuilder: (_, __) => const Divider(color: AppColors.line),
                      itemBuilder: (ctx, i) {
                        final l = state.locais[i];
                        return ListTile(
                          leading: const Icon(Icons.place, color: AppColors.spotlight),
                          title: Text(l.nome, style: const TextStyle(color: AppColors.warmWhite)),
                          subtitle: Text(l.cidade, style: const TextStyle(color: AppColors.bodyText)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.spotlight.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(l.tipo, style: const TextStyle(color: AppColors.spotlight, fontSize: 11)),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.spotlight,
        foregroundColor: AppColors.stageBlack,
        onPressed: () => context.push('/local-form'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
