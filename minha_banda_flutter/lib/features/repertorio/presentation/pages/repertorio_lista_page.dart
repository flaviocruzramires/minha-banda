import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../notifiers/repertorio_notifier.dart';
import '../../domain/entities/musica.dart';

class RepertorioListaPage extends ConsumerStatefulWidget {
  const RepertorioListaPage({super.key, required this.bandaId});
  final String bandaId;

  @override
  ConsumerState<RepertorioListaPage> createState() => _RepertorioListaPageState();
}

class _RepertorioListaPageState extends ConsumerState<RepertorioListaPage> {
  String _busca = '';
  String _filtro = 'Todos';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(repertorioNotifierProvider.notifier).carregar(widget.bandaId),
    );
  }

  List<Musica> _filtrar(List<Musica> musicas) {
    return musicas.where((m) {
      final matchBusca = _busca.isEmpty ||
          m.titulo.toLowerCase().contains(_busca.toLowerCase()) ||
          (m.artistaOriginal?.toLowerCase().contains(_busca.toLowerCase()) ?? false);
      final matchFiltro = _filtro == 'Todos' ||
          (_filtro == 'Pronto para show' && m.status == 'pronto_para_show') ||
          (_filtro == 'Em aprendizado' && m.status == 'em_aprendizado');
      return matchBusca && matchFiltro;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(repertorioNotifierProvider);
    final filtradas = _filtrar(state.musicas);

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(
                hintText: 'Buscar música...',
                prefixIcon: Icon(Icons.search, color: AppColors.hintText),
              ),
              onChanged: (v) => setState(() => _busca = v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['Todos', 'Pronto para show', 'Em aprendizado'].map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: _filtro == f,
                    onSelected: (_) => setState(() => _filtro = f),
                    selectedColor: AppColors.spotlight,
                    labelStyle: TextStyle(
                      color: _filtro == f ? AppColors.stageBlack : AppColors.warmWhite,
                    ),
                    backgroundColor: AppColors.stageBlack2,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const LoadingOverlay()
                : state.hasError
                    ? Center(child: Text(state.erro ?? '', style: const TextStyle(color: AppColors.danger)))
                    : filtradas.isEmpty
                        ? EmptyState(
                            icon: Icons.music_note,
                            title: 'Nenhuma música',
                            subtitle: 'Adicione músicas ao repertório.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: filtradas.length,
                            separatorBuilder: (_, __) => const Divider(color: AppColors.line),
                            itemBuilder: (ctx, i) {
                              final m = filtradas[i];
                              return ListTile(
                                title: Text(m.titulo, style: const TextStyle(color: AppColors.warmWhite)),
                                subtitle: Text(
                                  m.artistaOriginal ?? '',
                                  style: const TextStyle(color: AppColors.bodyText),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: m.status == 'pronto_para_show'
                                        ? AppColors.confirmed.withValues(alpha: 0.2)
                                        : AppColors.spotlight.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    m.status == 'pronto_para_show' ? 'Show' : 'Aprendendo',
                                    style: TextStyle(
                                      color: m.status == 'pronto_para_show'
                                          ? AppColors.confirmed
                                          : AppColors.spotlight,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                onTap: () => context.push('/musica-form/${widget.bandaId}', extra: m),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.spotlight,
        foregroundColor: AppColors.stageBlack,
        onPressed: () => context.push('/musica-form/${widget.bandaId}'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
