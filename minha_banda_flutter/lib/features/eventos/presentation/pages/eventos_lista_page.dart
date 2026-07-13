import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/ticket_card.dart';
import '../notifiers/eventos_notifier.dart';
import '../../domain/entities/evento.dart';

enum _Filtro { proximos, passados }

class EventosListaPage extends ConsumerStatefulWidget {
  const EventosListaPage({super.key, required this.bandaId});
  final String bandaId;

  @override
  ConsumerState<EventosListaPage> createState() => _EventosListaPageState();
}

class _EventosListaPageState extends ConsumerState<EventosListaPage> {
  _Filtro _filtro = _Filtro.proximos;

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
    final agora = DateTime.now();
    final proximos = state.eventos
        .where((e) => e.dataHoraInicio.isAfter(agora))
        .toList()
      ..sort((a, b) => a.dataHoraInicio.compareTo(b.dataHoraInicio));
    final passados = state.eventos
        .where((e) => !e.dataHoraInicio.isAfter(agora))
        .toList()
      ..sort((a, b) => b.dataHoraInicio.compareTo(a.dataHoraInicio));
    final lista = _filtro == _Filtro.proximos ? proximos : passados;

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Eventos',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      color: AppColors.warmWhite,
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.warmWhite),
                    onPressed: () => context.push('/evento-form/${widget.bandaId}'),
                  ),
                ],
              ),
            ),

            // Filtro pills
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  _FilterPill(
                    label: 'Próximos',
                    selected: _filtro == _Filtro.proximos,
                    onTap: () => setState(() => _filtro = _Filtro.proximos),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Passados',
                    selected: _filtro == _Filtro.passados,
                    onTap: () => setState(() => _filtro = _Filtro.passados),
                  ),
                ],
              ),
            ),

            // Lista
            Expanded(
              child: state.isLoading
                  ? const LoadingOverlay()
                  : state.hasError
                      ? Center(
                          child: Text(
                            state.erro ?? '',
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        )
                      : lista.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.event, size: 48, color: AppColors.hintText),
                                  const SizedBox(height: 12),
                                  Text(
                                    _filtro == _Filtro.proximos
                                        ? 'Nenhum evento próximo'
                                        : 'Nenhum evento passado',
                                    style: const TextStyle(color: AppColors.bodyText),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              itemCount: lista.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (ctx, i) => _EventoTicket(
                                evento: lista[i],
                                onTap: () {
                                  ref
                                      .read(eventosNotifierProvider.notifier)
                                      .selecionarEvento(lista[i]);
                                  context.push('/evento/${lista[i].id}');
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.spotlight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.spotlight : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.stageBlack : AppColors.bodyText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EventoTicket extends StatelessWidget {
  const _EventoTicket({required this.evento, required this.onTap});
  final Evento evento;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = evento.dataHoraInicio;
    final dias = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];
    final meses = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
    final label =
        '${dias[d.weekday % 7]} ${d.day} ${meses[d.month - 1]} · ${d.hour.toString().padLeft(2, '0')}H';

    return TicketCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.spotlight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.04,
                  ),
                ),
              ),
              _StatusPill(status: evento.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_tipoLabel(evento.tipo)} — ${evento.titulo}',
            style: GoogleFonts.bebasNeue(
              fontSize: 19,
              color: AppColors.warmWhite,
              letterSpacing: 0.5,
            ),
          ),
          if (evento.notas != null && evento.notas!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              evento.notas!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.bodyText),
            ),
          ],
        ],
      ),
    );
  }

  String _tipoLabel(String tipo) {
    switch (tipo) {
      case 'show': return 'Show';
      case 'ensaio': return 'Ensaio';
      case 'reuniao': return 'Reunião';
      default: return tipo;
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final Map<String, _PillStyle> styles = {
      'confirmado': _PillStyle(bg: const Color(0x384C7A5E), fg: const Color(0xFF8FD1A8), label: 'Confirmado'),
      'proposto': _PillStyle(bg: const Color(0x308A7F6B), fg: const Color(0xFFD8CDB8), label: 'Proposto'),
      'cancelado': _PillStyle(bg: const Color(0x30C0503C), fg: const Color(0xFFF2A08F), label: 'Cancelado'),
      'realizado': _PillStyle(bg: const Color(0x384C7A5E), fg: const Color(0xFF8FD1A8), label: 'Realizado'),
      'agendado': _PillStyle(bg: const Color(0x30F2A93B), fg: AppColors.spotlight, label: 'Agendado'),
    };
    final style = styles[status] ?? _PillStyle(bg: const Color(0x308A7F6B), fg: const Color(0xFFD8CDB8), label: status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: style.bg, borderRadius: BorderRadius.circular(20)),
      child: Text(style.label, style: TextStyle(color: style.fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _PillStyle {
  const _PillStyle({required this.bg, required this.fg, required this.label});
  final Color bg, fg;
  final String label;
}
