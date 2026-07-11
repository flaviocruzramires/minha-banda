import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../notifiers/eventos_notifier.dart';
import '../../domain/entities/checklist_item.dart';
import '../../domain/entities/evento_confirmacao.dart';

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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.stageBlack,
        appBar: AppBar(
          backgroundColor: AppColors.stageBlack2,
          title: Text(evento?.titulo ?? 'Evento', style: const TextStyle(color: AppColors.warmWhite)),
          iconTheme: const IconThemeData(color: AppColors.warmWhite),
          bottom: const TabBar(
            labelColor: AppColors.spotlight,
            unselectedLabelColor: AppColors.bodyText,
            indicatorColor: AppColors.spotlight,
            tabs: [
              Tab(text: 'Info'),
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

class _InfoTab extends StatelessWidget {
  const _InfoTab({this.evento});
  final dynamic evento;

  @override
  Widget build(BuildContext context) {
    if (evento == null) {
      return const Center(child: Text('Nenhum evento selecionado.', style: TextStyle(color: AppColors.bodyText)));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow('Título', evento.titulo),
        _InfoRow('Tipo', evento.tipo),
        _InfoRow('Data', _fmt(evento.dataHoraInicio)),
        _InfoRow('Status', evento.status),
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

class _ConfirmacoesTab extends StatelessWidget {
  const _ConfirmacoesTab({required this.confirmacoes});
  final List<EventoConfirmacao> confirmacoes;

  Color _badgeColor(String s) {
    switch (s) {
      case 'confirmado': return AppColors.confirmed;
      case 'recusado': return AppColors.danger;
      default: return AppColors.spotlight;
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
