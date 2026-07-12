import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/eventos_notifier.dart';
import '../../../conflitos/domain/entities/conflito.dart';
import '../../../conflitos/presentation/notifiers/conflitos_notifier.dart';

class EventoFormPage extends ConsumerStatefulWidget {
  const EventoFormPage({super.key, required this.bandaId});
  final String bandaId;

  @override
  ConsumerState<EventoFormPage> createState() => _EventoFormPageState();
}

class _EventoFormPageState extends ConsumerState<EventoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _notas = TextEditingController();
  String _tipo = 'show';
  String _status = 'proposto';
  DateTime _dataHoraInicio = DateTime.now().add(const Duration(days: 1));
  DateTime _dataHoraFim = DateTime.now().add(const Duration(days: 1, hours: 2));
  bool _salvando = false;

  @override
  void dispose() {
    _titulo.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _pickDateHora({required bool isFim}) async {
    final initial = isFim ? _dataHoraFim : _dataHoraInicio;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.spotlight),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.spotlight),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isFim) {
        _dataHoraFim = dt;
      } else {
        _dataHoraInicio = dt;
        if (_dataHoraFim.isBefore(dt)) {
          _dataHoraFim = dt.add(const Duration(hours: 2));
        }
      }
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // Verificar conflitos antes de salvar
    final conflitos = await ref.read(conflitosNotifierProvider.notifier).verificar(
          bandaId: widget.bandaId,
          inicio: _dataHoraInicio,
          fim: _dataHoraFim,
        );

    if (conflitos.isNotEmpty && mounted) {
      final continuar = await _mostrarDialogConflitos(conflitos);
      if (!continuar) return;
    }

    if (!mounted) return;
    setState(() => _salvando = true);
    try {
      await ref.read(eventosNotifierProvider.notifier).criar(
            bandaId: widget.bandaId,
            tipo: _tipo,
            titulo: _titulo.text.trim(),
            dataHoraInicio: _dataHoraInicio,
            dataHoraFim: _dataHoraFim,
            status: _status,
            notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<bool> _mostrarDialogConflitos(List<Conflito> conflitos) async {
    final totalConflitos = conflitos.fold<int>(
      0,
      (acc, c) => acc + c.eventosConflitantes.length + c.bloqueiosConflitantes.length,
    );

    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.stageBlack2,
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.spotlight),
                const SizedBox(width: 8),
                const Text('Conflito de agenda', style: TextStyle(color: AppColors.warmWhite, fontSize: 16)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$totalConflitos conflito${totalConflitos != 1 ? 's' : ''} encontrado${totalConflitos != 1 ? 's' : ''} para esta data:',
                    style: const TextStyle(color: AppColors.bodyText, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ...conflitos.expand((c) => [
                        ...c.eventosConflitantes.map((e) => _ConflitoBullet(
                              icon: Icons.event,
                              texto: '${e.titulo} — ${_fmtHora(e.dataHoraInicio)}',
                            )),
                        ...c.bloqueiosConflitantes.map((b) => _ConflitoBullet(
                              icon: Icons.block,
                              texto: b,
                            )),
                      ]),
                  const SizedBox(height: 8),
                  const Text(
                    'O conflito não bloqueia a criação — você pode criar mesmo assim.',
                    style: TextStyle(color: AppColors.hintText, fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.bodyText)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.spotlight,
                  foregroundColor: AppColors.stageBlack,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text('Criar mesmo assim'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _fmtHora(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _fmtDt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stageBlack,
      appBar: AppBar(
        backgroundColor: AppColors.stageBlack2,
        title: const Text('Novo Evento', style: TextStyle(color: AppColors.warmWhite)),
        iconTheme: const IconThemeData(color: AppColors.warmWhite),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _tipo,
              dropdownColor: AppColors.stageBlack2,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Tipo', labelStyle: TextStyle(color: AppColors.hintText)),
              items: const [
                DropdownMenuItem(value: 'show', child: Text('Show')),
                DropdownMenuItem(value: 'ensaio', child: Text('Ensaio')),
                DropdownMenuItem(value: 'reuniao', child: Text('Reunião')),
              ],
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titulo,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Título *', labelStyle: TextStyle(color: AppColors.hintText)),
              validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              dropdownColor: AppColors.stageBlack2,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Status', labelStyle: TextStyle(color: AppColors.hintText)),
              items: const [
                DropdownMenuItem(value: 'proposto', child: Text('Proposto')),
                DropdownMenuItem(value: 'confirmado', child: Text('Confirmado')),
                DropdownMenuItem(value: 'realizado', child: Text('Realizado')),
                DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Início', style: TextStyle(color: AppColors.hintText, fontSize: 12)),
              subtitle: Text(_fmtDt(_dataHoraInicio), style: const TextStyle(color: AppColors.warmWhite, fontSize: 16)),
              trailing: const Icon(Icons.calendar_today, color: AppColors.spotlight),
              onTap: () => _pickDateHora(isFim: false),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Término', style: TextStyle(color: AppColors.hintText, fontSize: 12)),
              subtitle: Text(_fmtDt(_dataHoraFim), style: const TextStyle(color: AppColors.warmWhite, fontSize: 16)),
              trailing: const Icon(Icons.calendar_today, color: AppColors.spotlight),
              onTap: () => _pickDateHora(isFim: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notas,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Notas', labelStyle: TextStyle(color: AppColors.hintText)),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.stageBlack))
                  : const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflitoBullet extends StatelessWidget {
  const _ConflitoBullet({required this.icon, required this.texto});
  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.spotlight, size: 14),
          const SizedBox(width: 6),
          Expanded(child: Text(texto, style: const TextStyle(color: AppColors.warmWhite, fontSize: 13))),
        ],
      ),
    );
  }
}
