import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/eventos_notifier.dart';

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
  DateTime _dataHoraInicio = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _titulo.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dataHoraInicio,
      firstDate: DateTime.now(),
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
      initialTime: TimeOfDay.fromDateTime(_dataHoraInicio),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.spotlight),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() {
      _dataHoraInicio = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(eventosNotifierProvider.notifier).criar(
      bandaId: widget.bandaId,
      tipo: _tipo,
      titulo: _titulo.text.trim(),
      dataHoraInicio: _dataHoraInicio,
      notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_dataHoraInicio.day.toString().padLeft(2, '0')}/${_dataHoraInicio.month.toString().padLeft(2, '0')}/${_dataHoraInicio.year} ${_dataHoraInicio.hour.toString().padLeft(2, '0')}:${_dataHoraInicio.minute.toString().padLeft(2, '0')}';

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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data e hora', style: TextStyle(color: AppColors.hintText, fontSize: 12)),
              subtitle: Text(dateStr, style: const TextStyle(color: AppColors.warmWhite, fontSize: 16)),
              trailing: const Icon(Icons.calendar_today, color: AppColors.spotlight),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notas,
              style: const TextStyle(color: AppColors.warmWhite),
              decoration: const InputDecoration(labelText: 'Notas', labelStyle: TextStyle(color: AppColors.hintText)),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _salvar, child: const Text('Criar')),
          ],
        ),
      ),
    );
  }
}
