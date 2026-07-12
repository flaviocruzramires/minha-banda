import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../notifiers/eventos_notifier.dart';
import '../../domain/entities/evento.dart';

class EventosListaPage extends ConsumerStatefulWidget {
  const EventosListaPage({super.key, required this.bandaId});
  final String bandaId;

  @override
  ConsumerState<EventosListaPage> createState() => _EventosListaPageState();
}

class _EventosListaPageState extends ConsumerState<EventosListaPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(eventosNotifierProvider.notifier).carregar(widget.bandaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventosNotifierProvider);
    final now = DateTime.now();
    final proximos = state.eventos.where((e) => e.dataHoraInicio.isAfter(now)).toList()
      ..sort((a, b) => a.dataHoraInicio.compareTo(b.dataHoraInicio));
    final passados = state.eventos.where((e) => !e.dataHoraInicio.isAfter(now)).toList()
      ..sort((a, b) => b.dataHoraInicio.compareTo(a.dataHoraInicio));

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: state.isLoading
          ? const LoadingOverlay()
          : state.hasError
              ? Center(child: Text(state.erro ?? '', style: const TextStyle(color: AppColors.danger)))
              : state.eventos.isEmpty
                  ? const EmptyState(
                      icon: Icons.event,
                      title: 'Nenhum evento',
                      subtitle: 'Crie o primeiro evento da banda.',
                    )
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        if (proximos.isNotEmpty) ...[
                          const _SectionHeader(title: 'Próximos'),
                          ...proximos.map((e) => _EventoCard(evento: e)),
                        ],
                        if (passados.isNotEmpty) ...[
                          const _SectionHeader(title: 'Passados'),
                          ...passados.map((e) => _EventoCard(evento: e)),
                        ],
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.spotlight,
        foregroundColor: AppColors.stageBlack,
        onPressed: () => context.push('/evento-form/${widget.bandaId}'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(title, style: const TextStyle(
        color: AppColors.spotlight, fontWeight: FontWeight.w700, fontSize: 13,
      )),
    );
  }
}

class _EventoCard extends StatelessWidget {
  const _EventoCard({required this.evento});
  final Evento evento;

  IconData _icon() {
    switch (evento.tipo) {
      case 'show': return Icons.music_note;
      case 'ensaio': return Icons.headphones;
      default: return Icons.groups;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.stageBlack2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(_icon(), color: AppColors.spotlight),
        title: Text(evento.titulo, style: const TextStyle(color: AppColors.warmWhite)),
        subtitle: Text(
          '${evento.tipo} · ${_formatDate(evento.dataHoraInicio)}',
          style: const TextStyle(color: AppColors.bodyText),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.hintText),
        onTap: () => context.push('/evento/${evento.id}'),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
