import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../notifiers/setlist_notifier.dart';

class SetlistPage extends ConsumerStatefulWidget {
  const SetlistPage({super.key, required this.eventoId, required this.bandaId, required this.tituloEvento});

  final String eventoId;
  final String bandaId;
  final String tituloEvento;

  @override
  ConsumerState<SetlistPage> createState() => _SetlistPageState();
}

class _SetlistPageState extends ConsumerState<SetlistPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(setlistNotifierProvider.notifier)
        .carregar(eventoId: widget.eventoId, bandaId: widget.bandaId));
  }

  Future<void> _salvar() async {
    final ok = await ref.read(setlistNotifierProvider.notifier).salvar(widget.eventoId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Setlist salvo!' : 'Erro ao salvar setlist.'),
        backgroundColor: ok ? AppColors.confirmed : AppColors.danger,
      ));
    }
  }

  void _mostrarRepertorio() {
    final state = ref.read(setlistNotifierProvider);
    final disponiveis = state.musicasForaDoSetlist;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.stageBlack2,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Adicionar ao setlist',
                  style: const TextStyle(color: AppColors.warmWhite, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const Divider(color: AppColors.line),
            if (disponiveis.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Todas as músicas já estão no setlist.',
                      style: TextStyle(color: AppColors.bodyText)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: disponiveis.length,
                  itemBuilder: (_, i) {
                    final m = disponiveis[i];
                    return ListTile(
                      title: Text(m.titulo, style: const TextStyle(color: AppColors.warmWhite)),
                      subtitle: m.artistaOriginal != null
                          ? Text(m.artistaOriginal!, style: const TextStyle(color: AppColors.bodyText))
                          : null,
                      trailing: m.duracaoSeg != null
                          ? Text(_fmtDuracao(m.duracaoSeg!),
                              style: const TextStyle(color: AppColors.hintText, fontSize: 12))
                          : null,
                      onTap: () {
                        ref.read(setlistNotifierProvider.notifier).adicionar(m.id);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _fmtDuracao(int seg) {
    final m = seg ~/ 60;
    final s = seg % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setlistNotifierProvider);
    final setlist = state.setlist;
    final total = state.totalDuracaoSeg;

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      appBar: AppBar(
        backgroundColor: AppColors.stageBlack2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Setlist', style: TextStyle(color: AppColors.warmWhite, fontSize: 16)),
            Text(widget.tituloEvento,
                style: const TextStyle(color: AppColors.bodyText, fontSize: 12)),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.warmWhite),
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.spotlight)),
            )
          else
            TextButton(
              onPressed: _salvar,
              child: const Text('Salvar', style: TextStyle(color: AppColors.spotlight, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: state.isLoading
          ? const LoadingOverlay()
          : Column(
              children: [
                if (total > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.stageBlack2,
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: AppColors.hintText, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Duração total: ${_fmtDuracao(total)}',
                          style: const TextStyle(color: AppColors.bodyText, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          '${setlist.length} música${setlist.length != 1 ? 's' : ''}',
                          style: const TextStyle(color: AppColors.hintText, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: setlist.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.queue_music, size: 64, color: AppColors.spotlight),
                              const SizedBox(height: 16),
                              const Text('Setlist vazio',
                                  style: TextStyle(color: AppColors.warmWhite, fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              const Text('Toque em + para adicionar músicas.',
                                  style: TextStyle(color: AppColors.bodyText)),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _mostrarRepertorio,
                                icon: const Icon(Icons.add),
                                label: const Text('Adicionar músicas'),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: setlist.length,
                          onReorder: (old, novo) =>
                              ref.read(setlistNotifierProvider.notifier).reordenar(old, novo),
                          itemBuilder: (_, i) {
                            final entry = setlist[i];
                            return Dismissible(
                              key: ValueKey(entry.musicaId),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                color: AppColors.danger,
                                child: const Icon(Icons.delete_outline, color: Colors.white),
                              ),
                              onDismissed: (_) =>
                                  ref.read(setlistNotifierProvider.notifier).remover(entry.musicaId),
                              child: ListTile(
                                key: ValueKey('tile_${entry.musicaId}'),
                                leading: Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.spotlight.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(color: AppColors.spotlight, fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ),
                                title: Text(entry.titulo,
                                    style: const TextStyle(color: AppColors.warmWhite)),
                                subtitle: entry.artistaOriginal != null
                                    ? Text(entry.artistaOriginal!,
                                        style: const TextStyle(color: AppColors.bodyText))
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (entry.duracaoSeg != null)
                                      Text(_fmtDuracao(entry.duracaoSeg!),
                                          style: const TextStyle(color: AppColors.hintText, fontSize: 12)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.drag_handle, color: AppColors.hintText),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: setlist.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: AppColors.spotlight,
              foregroundColor: AppColors.stageBlack,
              onPressed: _mostrarRepertorio,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
