import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../notifiers/eventos_notifier.dart';
import '../../domain/entities/checklist_item.dart';
import '../../domain/entities/evento_confirmacao.dart';
import '../../../setlist/presentation/notifiers/setlist_notifier.dart';
import '../../../setlist/domain/entities/setlist_entry.dart';

class EventoDetalhePage extends ConsumerStatefulWidget {
  const EventoDetalhePage({super.key, required this.eventoId});
  final String eventoId;

  @override
  ConsumerState<EventoDetalhePage> createState() => _EventoDetalhePageState();
}

class _EventoDetalhePageState extends ConsumerState<EventoDetalhePage> {
  final _checkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(eventosNotifierProvider.notifier).carregarDetalhes(widget.eventoId),
    );
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventosNotifierProvider);
    final evento = state.eventoSelecionado;

    // Carrega setlist quando o evento estiver disponível
    if (evento != null) {
      ref.listen<EventosState>(eventosNotifierProvider, (prev, next) {
        if (prev?.eventoSelecionado == null && next.eventoSelecionado != null) {
          ref.read(setlistNotifierProvider.notifier).carregar(
                eventoId: next.eventoSelecionado!.id,
                bandaId: next.eventoSelecionado!.bandaId,
              );
        }
      });
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.stageBlack,
        appBar: AppBar(
          backgroundColor: AppColors.stageBlack2,
          title: Text(evento?.titulo ?? 'Evento', style: const TextStyle(color: AppColors.warmWhite)),
          iconTheme: const IconThemeData(color: AppColors.warmWhite),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.warmWhite),
              tooltip: 'Editar evento',
              onPressed: evento == null
                  ? null
                  : () => context.push(
                        '/evento-form/${evento.bandaId}',
                        extra: {'evento': evento},
                      ),
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_outline, color: AppColors.spotlight),
              tooltip: 'Teleprompter',
              onPressed: evento == null ? null : () => context.push('/teleprompter/${evento.id}'),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.spotlight,
            unselectedLabelColor: AppColors.bodyText,
            indicatorColor: AppColors.spotlight,
            isScrollable: true,
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'Setlist'),
              Tab(text: 'Checklist'),
              Tab(text: 'Confirmações'),
            ],
          ),
        ),
        body: state.isLoading
            ? const LoadingOverlay()
            : TabBarView(
                children: [
                  _InfoTab(evento: evento),
                  _SetlistTab(evento: evento),
                  _ChecklistTab(
                    checklist: state.checklist,
                    eventoId: widget.eventoId,
                    controller: _checkCtrl,
                    onToggle: (item) => ref.read(eventosNotifierProvider.notifier).toggleChecklist(item),
                    onAdd: (desc) => ref.read(eventosNotifierProvider.notifier).addChecklist(eventoId: widget.eventoId, descricao: desc),
                  ),
                  _ConfirmacoesTab(confirmacoes: state.confirmacoes),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Aba Info
// ---------------------------------------------------------------------------

class _InfoTab extends StatelessWidget {
  const _InfoTab({this.evento});
  final dynamic evento;

  @override
  Widget build(BuildContext context) {
    if (evento == null) {
      return const Center(child: Text('Nenhum evento selecionado.', style: TextStyle(color: AppColors.bodyText)));
    }
    final statusLabels = {
      'proposto': 'Proposto',
      'confirmado': 'Confirmado',
      'realizado': 'Realizado',
      'cancelado': 'Cancelado',
      'agendado': 'Agendado',
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow('Título', evento.titulo),
        _InfoRow('Tipo', evento.tipo == 'show' ? 'Show' : evento.tipo == 'ensaio' ? 'Ensaio' : evento.tipo),
        _InfoRow('Data', _fmt(evento.dataHoraInicio)),
        if (evento.dataHoraFim != null) _InfoRow('Término', _fmt(evento.dataHoraFim!)),
        _InfoRow('Status', statusLabels[evento.status] ?? evento.status),
        if (evento.localId != null) _InfoRow('Local', evento.localId!),
        if (evento.notas != null) _InfoRow('Notas', evento.notas!),
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.hintText, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.warmWhite, fontSize: 16)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Aba Setlist
// ---------------------------------------------------------------------------

class _SetlistTab extends ConsumerWidget {
  const _SetlistTab({this.evento});
  final dynamic evento;

  String _fmtDuracao(int seg) {
    final m = seg ~/ 60;
    final s = seg % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setlistState = ref.watch(setlistNotifierProvider);
    final setlist = setlistState.setlist;
    final total = setlistState.totalDuracaoSeg;

    if (evento == null) {
      return const Center(child: Text('Evento não carregado.', style: TextStyle(color: AppColors.bodyText)));
    }

    return Column(
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
                Text('Duração total: ${_fmtDuracao(total)}',
                    style: const TextStyle(color: AppColors.bodyText, fontSize: 13)),
              ],
            ),
          ),
        Expanded(
          child: setlist.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.queue_music, size: 48, color: AppColors.spotlight),
                      const SizedBox(height: 12),
                      const Text('Setlist vazio', style: TextStyle(color: AppColors.warmWhite, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text('Monte o setlist na tela de edição.', style: TextStyle(color: AppColors.bodyText)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => context.push(
                          '/setlist/${evento.id}',
                          extra: {'bandaId': evento.bandaId, 'titulo': evento.titulo},
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar setlist'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: setlist.length,
                        itemBuilder: (_, i) => _SetlistItemTile(entry: setlist[i], numero: i + 1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(
                          '/setlist/${evento.id}',
                          extra: {'bandaId': evento.bandaId, 'titulo': evento.titulo},
                        ),
                        icon: const Icon(Icons.edit, color: AppColors.spotlight),
                        label: const Text('Editar setlist', style: TextStyle(color: AppColors.spotlight)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.spotlight),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _SetlistItemTile extends StatelessWidget {
  const _SetlistItemTile({required this.entry, required this.numero});
  final SetlistEntry entry;
  final int numero;

  String _fmtDuracao(int seg) {
    final m = seg ~/ 60;
    final s = seg % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.spotlight.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('$numero',
            style: const TextStyle(color: AppColors.spotlight, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
      title: Text(entry.titulo, style: const TextStyle(color: AppColors.warmWhite)),
      subtitle: entry.artistaOriginal != null
          ? Text(entry.artistaOriginal!, style: const TextStyle(color: AppColors.bodyText))
          : null,
      trailing: entry.duracaoSeg != null
          ? Text(_fmtDuracao(entry.duracaoSeg!), style: const TextStyle(color: AppColors.hintText, fontSize: 12))
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Aba Checklist
// ---------------------------------------------------------------------------

class _ChecklistTab extends StatelessWidget {
  const _ChecklistTab({
    required this.checklist,
    required this.eventoId,
    required this.controller,
    required this.onToggle,
    required this.onAdd,
  });
  final List<ChecklistItem> checklist;
  final String eventoId;
  final TextEditingController controller;
  final void Function(ChecklistItem) onToggle;
  final void Function(String) onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: checklist.isEmpty
              ? const Center(child: Text('Nenhum item.', style: TextStyle(color: AppColors.bodyText)))
              : ListView.builder(
                  itemCount: checklist.length,
                  itemBuilder: (ctx, i) {
                    final item = checklist[i];
                    return CheckboxListTile(
                      value: item.concluido,
                      onChanged: (_) => onToggle(item),
                      title: Text(item.descricao, style: TextStyle(
                        color: item.concluido ? AppColors.hintText : AppColors.warmWhite,
                        decoration: item.concluido ? TextDecoration.lineThrough : null,
                      )),
                      activeColor: AppColors.spotlight,
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: AppColors.warmWhite),
                  decoration: const InputDecoration(hintText: 'Novo item...'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.spotlight),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    onAdd(controller.text.trim());
                    controller.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Aba Confirmações
// ---------------------------------------------------------------------------

class _ConfirmacoesTab extends StatelessWidget {
  const _ConfirmacoesTab({required this.confirmacoes});
  final List<EventoConfirmacao> confirmacoes;

  Color _badgeColor(String s) {
    switch (s) {
      case 'confirmado':
        return AppColors.confirmed;
      case 'recusado':
        return AppColors.danger;
      default:
        return AppColors.spotlight;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (confirmacoes.isEmpty) {
      return const Center(child: Text('Sem confirmações.', style: TextStyle(color: AppColors.bodyText)));
    }
    return ListView.builder(
      itemCount: confirmacoes.length,
      itemBuilder: (ctx, i) {
        final c = confirmacoes[i];
        return ListTile(
          title: Text(c.userId, style: const TextStyle(color: AppColors.warmWhite)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _badgeColor(c.status).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(c.status, style: TextStyle(color: _badgeColor(c.status), fontSize: 12)),
          ),
        );
      },
    );
  }
}
