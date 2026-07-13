import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ticket_card.dart';
import '../../../contexto/presentation/notifiers/contexto_notifier.dart';
import '../../../eventos/presentation/notifiers/eventos_notifier.dart';
import '../../../repertorio/presentation/notifiers/repertorio_notifier.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_carregarDados);
  }

  void _carregarDados() {
    final bandaId = ref.read(contextoNotifierProvider).ativo?.id ?? '';
    if (bandaId.isEmpty) return;
    ref.read(eventosNotifierProvider.notifier).carregar(bandaId);
    ref.read(repertorioNotifierProvider.notifier).carregar(bandaId);
  }

  @override
  Widget build(BuildContext context) {
    final contexto = ref.watch(contextoNotifierProvider);
    final eventosState = ref.watch(eventosNotifierProvider);
    final repertorioState = ref.watch(repertorioNotifierProvider);
    final bandaId = contexto.ativo?.id ?? '';
    final nomeUsuario = contexto.ativo?.nome.split(' ').first ?? 'Músico';

    final agora = DateTime.now();
    final proximoEvento = eventosState.eventos
        .where((e) => e.dataHoraInicio.isAfter(agora))
        .toList()
      ..sort((a, b) => a.dataHoraInicio.compareTo(b.dataHoraInicio));

    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const SizedBox(height: 8),
            Text(
              'Boa ${_periodo()},',
              style: const TextStyle(color: AppColors.bodyText, fontSize: 13),
            ),
            Text(
              'E aí, $nomeUsuario 🤘',
              style: GoogleFonts.bebasNeue(
                fontSize: 32,
                color: AppColors.warmWhite,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Próximo compromisso
            _SectionTitle(title: 'Próximo compromisso'),
            const SizedBox(height: 10),
            if (proximoEvento.isEmpty)
              _EmptyCard(
                label: 'Nenhum evento agendado',
                onTap: bandaId.isEmpty ? null : () => context.go('/eventos/$bandaId'),
              )
            else
              TicketCard(
                onTap: () {
                  ref.read(eventosNotifierProvider.notifier).selecionarEvento(proximoEvento.first);
                  context.push('/evento/${proximoEvento.first.id}');
                },
                child: _ProximoEventoContent(evento: proximoEvento.first),
              ),

            const SizedBox(height: 28),
            _SectionTitle(title: 'Atalhos'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _AtalhoCard(
                    emoji: '🎤',
                    label: 'Teleprompter',
                    onTap: proximoEvento.isEmpty
                        ? null
                        : () => context.push('/teleprompter/${proximoEvento.first.id}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AtalhoCard(
                    emoji: '🎵',
                    label: 'Repertório · ${repertorioState.musicas.length}',
                    onTap: bandaId.isEmpty
                        ? null
                        : () => context.go('/repertorio/$bandaId'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _periodo() {
    final h = DateTime.now().hour;
    if (h < 12) return 'manhã';
    if (h < 18) return 'tarde';
    return 'noite';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.10,
        color: Color(0x66F7F3EC),
      ),
    );
  }
}

class _ProximoEventoContent extends StatelessWidget {
  const _ProximoEventoContent({required this.evento});
  final dynamic evento;

  @override
  Widget build(BuildContext context) {
    final d = evento.dataHoraInicio as DateTime;
    final dias = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];
    final meses = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
    final label =
        '${dias[d.weekday % 7]} ${d.day} ${meses[d.month - 1]} · ${d.hour.toString().padLeft(2, '0')}H';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.spotlight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.04,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_tipoLabel(evento.tipo)} — ${evento.titulo}',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 20,
                      color: AppColors.warmWhite,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Ver detalhes →',
              style: const TextStyle(
                color: AppColors.spotlight,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
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

class _AtalhoCard extends StatelessWidget {
  const _AtalhoCard({required this.emoji, required this.label, this.onTap});
  final String emoji, label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.stageBlack2,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.warmWhite,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.stageBlack2,
          border: Border.all(color: AppColors.line, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.bodyText, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
