import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../notifiers/agenda_notifier.dart';


class AgendaPage extends ConsumerStatefulWidget {
  const AgendaPage({super.key});

  @override
  ConsumerState<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends ConsumerState<AgendaPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(agendaNotifierProvider.notifier).carregar());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agendaNotifierProvider);

    // Combine and sort upcoming items
    final now = DateTime.now();
    final items = <_AgendaItem>[];
    for (final e in state.eventos) {
      if (e.dataHoraInicio.isAfter(now)) {
        items.add(_AgendaItem(date: e.dataHoraInicio, title: e.titulo, type: e.tipo, isEvento: true));
      }
    }
    for (final b in state.bloqueios) {
      if (b.dataHoraFim.isAfter(now)) {
        items.add(_AgendaItem(date: b.dataHoraInicio, title: b.titulo, type: 'bloqueio', isEvento: false));
      }
    }
    items.sort((a, b) => a.date.compareTo(b.date));

    // Group by date
    final grouped = <String, List<_AgendaItem>>{};
    for (final item in items) {
      final weekdays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
      final months = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
      final key = '${weekdays[item.date.weekday - 1]}, ${item.date.day} ${months[item.date.month - 1]}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: state.isLoading
          ? const LoadingOverlay()
          : items.isEmpty
              ? const EmptyState(
                  icon: Icons.calendar_month,
                  title: 'Agenda vazia',
                  subtitle: 'Sem compromissos próximos.',
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(entry.key, style: const TextStyle(
                          color: AppColors.spotlight, fontWeight: FontWeight.w700, fontSize: 13,
                        )),
                      ),
                      ...entry.value.map((item) => Card(
                        color: AppColors.stageBlack2,
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          leading: Icon(
                            item.isEvento ? Icons.event : Icons.block,
                            color: item.isEvento ? AppColors.spotlight : AppColors.danger,
                          ),
                          title: Text(item.title, style: const TextStyle(color: AppColors.warmWhite)),
                          subtitle: Text(
                            '${item.date.hour.toString().padLeft(2, '0')}:${item.date.minute.toString().padLeft(2, '0')} · ${item.type}',
                            style: const TextStyle(color: AppColors.bodyText),
                          ),
                        ),
                      )),
                    ],
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.spotlight,
        foregroundColor: AppColors.stageBlack,
        onPressed: () => context.push('/novo-bloqueio'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AgendaItem {
  const _AgendaItem({required this.date, required this.title, required this.type, required this.isEvento});
  final DateTime date;
  final String title, type;
  final bool isEvento;
}
